package dal;

import model.Cart;
import model.CartItem;
import model.Order;
import model.OrderDetail;
import model.Payment;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO extends DBContext {

    public OrderDAO() {
        super();
    }

    // 1. TẠO ĐƠN HÀNG MỚI (DATABASE TRANSACTION: Orders + OrderDetails + Trừ Kho + Payment)
    public int createOrder(Order order, Cart cart) throws SQLException {
        if (connection == null || order == null || cart == null || cart.isEmpty()) {
            return -1;
        }

        int generatedOrderId = -1;
        boolean originalAutoCommit = connection.getAutoCommit();

        try {
            // Bắt đầu Transaction
            connection.setAutoCommit(false);

            // Bước 1: Insert vào bảng Orders
            String sqlOrder = "INSERT INTO Orders (UserID, ReceiverName, ReceiverPhone, ShippingAddress, OrderNote, "
                            + "TotalAmount, PaymentMethod, OrderStatus, OrderDate) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

            try (PreparedStatement stOrder = connection.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                if (order.getUserId() != null && order.getUserId() > 0) {
                    stOrder.setInt(1, order.getUserId());
                } else {
                    stOrder.setNull(1, java.sql.Types.INTEGER);
                }
                stOrder.setString(2, order.getReceiverName());
                stOrder.setString(3, order.getReceiverPhone());
                stOrder.setString(4, order.getShippingAddress());
                stOrder.setString(5, order.getOrderNote());
                stOrder.setDouble(6, order.getTotalAmount());
                stOrder.setString(7, order.getPaymentMethod());
                stOrder.setString(8, order.getOrderStatus() != null ? order.getOrderStatus() : "Chờ xác nhận");

                stOrder.executeUpdate();

                try (ResultSet rs = stOrder.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedOrderId = rs.getInt(1);
                    }
                }
            }

            if (generatedOrderId <= 0) {
                connection.rollback();
                return -1;
            }

            // Bước 2: Insert từng mặt hàng vào OrderDetails & Trừ số lượng tồn kho Products
            String sqlDetail = "INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES (?, ?, ?, ?)";
            String sqlUpdateStock = "UPDATE Products SET StockQuantity = StockQuantity - ? WHERE ProductID = ? AND StockQuantity >= ?";

            try (PreparedStatement stDetail = connection.prepareStatement(sqlDetail);
                 PreparedStatement stStock = connection.prepareStatement(sqlUpdateStock)) {

                for (CartItem item : cart.getItems()) {
                    // 2a. Insert OrderDetails
                    stDetail.setInt(1, generatedOrderId);
                    stDetail.setInt(2, item.getProductId());
                    stDetail.setInt(3, item.getQuantity());
                    stDetail.setDouble(4, item.getUnitPrice());
                    stDetail.executeUpdate();

                    // 2b. Trừ kho an toàn (chỉ trừ khi StockQuantity >= số lượng mua)
                    stStock.setInt(1, item.getQuantity());
                    stStock.setInt(2, item.getProductId());
                    stStock.setInt(3, item.getQuantity());
                    int affected = stStock.executeUpdate();

                    if (affected <= 0) {
                        connection.rollback();
                        throw new SQLException("Sản phẩm '" + item.getProductName() + "' không đủ số lượng trong kho!");
                    }
                }
            }

            // Bước 3: Tạo bản ghi thanh toán khởi tạo trong bảng Payments
            String sqlPayment = "INSERT INTO Payments (OrderID, TransactionID, Amount, PaymentDate, PaymentStatus) "
                              + "VALUES (?, ?, ?, GETDATE(), ?)";
            try (PreparedStatement stPay = connection.prepareStatement(sqlPayment)) {
                stPay.setInt(1, generatedOrderId);
                if ("COD".equalsIgnoreCase(order.getPaymentMethod())) {
                    stPay.setString(2, "COD-" + generatedOrderId);
                    stPay.setDouble(3, order.getTotalAmount());
                    stPay.setString(4, "Chờ xác nhận");
                } else {
                    stPay.setString(2, "VQR-" + generatedOrderId);
                    stPay.setDouble(3, order.getTotalAmount());
                    stPay.setString(4, "Chờ thanh toán");
                }
                stPay.executeUpdate();
            }

            // Hoàn tất Transaction
            connection.commit();
            return generatedOrderId;

        } catch (SQLException ex) {
            connection.rollback();
            System.err.println("Lỗi Transaction tạo đơn hàng: " + ex.getMessage());
            throw ex;
        } finally {
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    // 2. Lấy thông tin đơn hàng theo OrderID
    public Order getOrderById(int orderId) {
        if (connection == null) return null;

        String sql = "SELECT * FROM Orders WHERE OrderID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, orderId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("OrderID"));
                    int uid = rs.getInt("UserID");
                    if (!rs.wasNull()) o.setUserId(uid);
                    o.setReceiverName(rs.getString("ReceiverName"));
                    o.setReceiverPhone(rs.getString("ReceiverPhone"));
                    o.setShippingAddress(rs.getString("ShippingAddress"));
                    o.setOrderNote(rs.getString("OrderNote"));
                    o.setTotalAmount(rs.getDouble("TotalAmount"));
                    o.setPaymentMethod(rs.getString("PaymentMethod"));
                    o.setOrderStatus(rs.getString("OrderStatus"));
                    o.setOrderDate(rs.getTimestamp("OrderDate"));
                    o.setDetails(getOrderDetails(orderId));
                    return o;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getOrderById: " + e.getMessage());
        }
        return null;
    }

    // 3. Lấy danh sách chi tiết các món trong đơn hàng (kèm tên, ảnh, đơn vị)
    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT od.*, p.ProductName, p.Unit, p.ImageUrl FROM OrderDetails od "
                   + "LEFT JOIN Products p ON od.ProductID = p.ProductID "
                   + "WHERE od.OrderID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, orderId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    OrderDetail d = new OrderDetail();
                    d.setOrderDetailId(rs.getInt("OrderDetailID"));
                    d.setOrderId(rs.getInt("OrderID"));
                    d.setProductId(rs.getInt("ProductID"));
                    d.setQuantity(rs.getInt("Quantity"));
                    d.setUnitPrice(rs.getDouble("UnitPrice"));
                    d.setProductName(rs.getString("ProductName"));
                    d.setUnit(rs.getString("Unit"));
                    d.setImageUrl(rs.getString("ImageUrl"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getOrderDetails: " + e.getMessage());
        }
        return list;
    }

    // 4. Lấy lịch sử đơn hàng của 1 khách hàng (User)
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT * FROM Orders WHERE UserID = ? ORDER BY OrderID DESC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("OrderID"));
                    o.setUserId(userId);
                    o.setReceiverName(rs.getString("ReceiverName"));
                    o.setReceiverPhone(rs.getString("ReceiverPhone"));
                    o.setShippingAddress(rs.getString("ShippingAddress"));
                    o.setOrderNote(rs.getString("OrderNote"));
                    o.setTotalAmount(rs.getDouble("TotalAmount"));
                    o.setPaymentMethod(rs.getString("PaymentMethod"));
                    o.setOrderStatus(rs.getString("OrderStatus"));
                    o.setOrderDate(rs.getTimestamp("OrderDate"));
                    o.setDetails(getOrderDetails(o.getOrderId()));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getOrdersByUserId: " + e.getMessage());
        }
        return list;
    }

    // 4b. Khách hàng tự hủy đơn hàng của mình khi đơn còn ở trạng thái chờ
    public boolean cancelOrderByCustomer(int orderId, int userId) {
        Order o = getOrderById(orderId);
        if (o == null || o.getUserId() == null || o.getUserId() != userId) {
            return false;
        }
        String st = o.getOrderStatus();
        if ("Chờ xác nhận".equalsIgnoreCase(st) || "Đã chuyển khoản".equalsIgnoreCase(st)) {
            return updateOrderStatus(orderId, "Đã hủy");
        }
        return false;
    }

    // 5. Lọc danh sách đơn hàng cho Admin (Lọc theo trạng thái & Tìm kiếm từ khóa)
    public List<Order> getOrdersByFilter(String statusFilter, String keyword) {
        List<Order> list = new ArrayList<>();
        if (connection == null) return list;

        StringBuilder sql = new StringBuilder("SELECT * FROM Orders WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND OrderStatus = ? ");
            params.add(statusFilter.trim());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (ReceiverName LIKE ? OR ReceiverPhone LIKE ? OR CAST(OrderID AS VARCHAR) LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY OrderID DESC");

        try (PreparedStatement st = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("OrderID"));
                    int uid = rs.getInt("UserID");
                    if (!rs.wasNull()) o.setUserId(uid);
                    o.setReceiverName(rs.getString("ReceiverName"));
                    o.setReceiverPhone(rs.getString("ReceiverPhone"));
                    o.setShippingAddress(rs.getString("ShippingAddress"));
                    o.setOrderNote(rs.getString("OrderNote"));
                    o.setTotalAmount(rs.getDouble("TotalAmount"));
                    o.setPaymentMethod(rs.getString("PaymentMethod"));
                    o.setOrderStatus(rs.getString("OrderStatus"));
                    o.setOrderDate(rs.getTimestamp("OrderDate"));
                    o.setDetails(getOrderDetails(o.getOrderId()));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getOrdersByFilter: " + e.getMessage());
        }
        return list;
    }

    // 6. Lấy toàn bộ đơn hàng
    public List<Order> getAllOrdersAdmin() {
        return getOrdersByFilter(null, null);
    }

    // 7. Cập nhật trạng thái đơn hàng (Tự động hoàn kho khi Hủy đơn và đồng bộ Payments)
    public boolean updateOrderStatus(int orderId, String newStatus) {
        if (connection == null || newStatus == null) return false;

        Order currentOrder = getOrderById(orderId);
        if (currentOrder == null) return false;

        String oldStatus = currentOrder.getOrderStatus();

        String sql = "UPDATE Orders SET OrderStatus = ? WHERE OrderID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, newStatus);
            st.setInt(2, orderId);
            boolean updated = st.executeUpdate() > 0;

            if (updated) {
                // Nếu chuyển sang trạng thái "Đã hủy" và trước đó chưa hủy -> Hoàn lại tồn kho
                if ("Đã hủy".equalsIgnoreCase(newStatus) && !"Đã hủy".equalsIgnoreCase(oldStatus)) {
                    restoreStockOnCancel(orderId);
                    updatePaymentStatus(orderId, "Đã hủy");
                }

                // Nếu xác nhận thanh toán hoặc hoàn thành -> Đồng bộ Payments
                if ("Đã thanh toán".equalsIgnoreCase(newStatus) || "Hoàn thành".equalsIgnoreCase(newStatus)) {
                    updatePaymentStatus(orderId, "Đã thanh toán");
                }
            }
            return updated;
        } catch (SQLException e) {
            System.err.println("Lỗi updateOrderStatus: " + e.getMessage());
        }
        return false;
    }

    // 8. Hoàn lại số lượng tồn kho vào Products khi Hủy đơn hàng
    public boolean restoreStockOnCancel(int orderId) {
        if (connection == null) return false;

        List<OrderDetail> details = getOrderDetails(orderId);
        String sql = "UPDATE Products SET StockQuantity = StockQuantity + ? WHERE ProductID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            for (OrderDetail d : details) {
                st.setInt(1, d.getQuantity());
                st.setInt(2, d.getProductId());
                st.addBatch();
            }
            st.executeBatch();
            return true;
        } catch (SQLException e) {
            System.err.println("Lỗi restoreStockOnCancel: " + e.getMessage());
        }
        return false;
    }

    // 9. Lấy thông tin thanh toán Payment theo OrderID
    public Payment getPaymentByOrderId(int orderId) {
        if (connection == null) return null;

        String sql = "SELECT * FROM Payments WHERE OrderID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, orderId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Payment p = new Payment();
                    p.setPaymentId(rs.getInt("PaymentID"));
                    p.setOrderId(rs.getInt("OrderID"));
                    p.setTransactionId(rs.getString("TransactionID"));
                    p.setAmount(rs.getDouble("Amount"));
                    p.setPaymentDate(rs.getTimestamp("PaymentDate"));
                    p.setPaymentStatus(rs.getString("PaymentStatus"));
                    return p;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getPaymentByOrderId: " + e.getMessage());
        }
        return null;
    }

    // 10. Cập nhật trạng thái thanh toán
    public boolean updatePaymentStatus(int orderId, String paymentStatus) {
        if (connection == null) return false;

        String sql = "UPDATE Payments SET PaymentStatus = ? WHERE OrderID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, paymentStatus);
            st.setInt(2, orderId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updatePaymentStatus: " + e.getMessage());
        }
        return false;
    }

    // 11. Khách hàng xác nhận đã chuyển khoản
    public boolean confirmCustomerTransfer(int orderId, String transactionRef) {
        if (connection == null) return false;

        String sql = "UPDATE Payments SET TransactionID = ?, PaymentStatus = N'Chờ xác nhận' WHERE OrderID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, (transactionRef != null && !transactionRef.trim().isEmpty()) ? transactionRef.trim() : ("VQR-" + orderId));
            st.setInt(2, orderId);
            boolean ok = st.executeUpdate() > 0;
            if (ok) {
                // Đổi trạng thái Order sang "Đã chuyển khoản"
                updateOrderStatus(orderId, "Đã chuyển khoản");
            }
            return ok;
        } catch (SQLException e) {
            System.err.println("Lỗi confirmCustomerTransfer: " + e.getMessage());
        }
        return false;
    }
}
