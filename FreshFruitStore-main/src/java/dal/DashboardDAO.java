package dal;

import model.Order;
import model.TopProduct;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO extends DBContext {

    public DashboardDAO() {
        super();
    }

    // 1. Thẻ tổng doanh thu thực tế (đơn đã thanh toán, đã giao, hoàn thành)
    public double getTotalRevenue() {
        if (connection == null) return 0.0;
        String sql = "SELECT COALESCE(SUM(TotalAmount), 0) FROM Orders "
                   + "WHERE OrderStatus IN (N'Hoàn thành', N'Đã thanh toán', N'Đã giao')";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getTotalRevenue: " + e.getMessage());
        }
        return 0.0;
    }

    // 2. Thẻ đếm số đơn hàng mới đang chờ xử lý
    public int getPendingOrdersCount() {
        if (connection == null) return 0;
        String sql = "SELECT COUNT(*) FROM Orders WHERE OrderStatus IN (N'Chờ xác nhận', N'Đã chuyển khoản')";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getPendingOrdersCount: " + e.getMessage());
        }
        return 0;
    }

    // 3. Tổng số đơn hàng trong hệ thống
    public int getTotalOrdersCount() {
        if (connection == null) return 0;
        String sql = "SELECT COUNT(*) FROM Orders";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getTotalOrdersCount: " + e.getMessage());
        }
        return 0;
    }

    // 4. Tổng số khách hàng
    public int getTotalCustomersCount() {
        if (connection == null) return 0;
        String sql = "SELECT COUNT(*) FROM Users WHERE Role = 'Customer' OR Role = 'customer'";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getTotalCustomersCount: " + e.getMessage());
        }
        return 0;
    }

    // 5. Tổng số sản phẩm đang kinh doanh
    public int getTotalProductsCount() {
        if (connection == null) return 0;
        String sql = "SELECT COUNT(*) FROM Products WHERE IsActive = 1";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getTotalProductsCount: " + e.getMessage());
        }
        return 0;
    }

    // 6. Số sản phẩm cảnh báo tồn kho thấp (Stock <= 10)
    public int getLowStockProductsCount() {
        if (connection == null) return 0;
        String sql = "SELECT COUNT(*) FROM Products WHERE IsActive = 1 AND StockQuantity <= 10";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getLowStockProductsCount: " + e.getMessage());
        }
        return 0;
    }

    // 7. Bảng Top 5 mặt hàng bán chạy nhất (JOIN OrderDetails, Products, Orders)
    public List<TopProduct> getTop5BestSellers() {
        List<TopProduct> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT TOP 5 "
                   + "    p.ProductID, "
                   + "    p.ProductName, "
                   + "    p.ImageUrl, "
                   + "    p.Price, "
                   + "    p.Unit, "
                   + "    COALESCE(c.CategoryName, N'Khác') AS CategoryName, "
                   + "    SUM(od.Quantity) AS TotalSold, "
                   + "    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue "
                   + "FROM OrderDetails od "
                   + "JOIN Products p ON od.ProductID = p.ProductID "
                   + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                   + "JOIN Orders o ON od.OrderID = o.OrderID "
                   + "WHERE o.OrderStatus NOT IN (N'Đã hủy') "
                   + "GROUP BY p.ProductID, p.ProductName, p.ImageUrl, p.Price, p.Unit, c.CategoryName "
                   + "ORDER BY TotalSold DESC";

        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                TopProduct tp = new TopProduct();
                tp.setProductId(rs.getInt("ProductID"));
                tp.setProductName(rs.getString("ProductName"));
                tp.setImageUrl(rs.getString("ImageUrl"));
                tp.setPrice(rs.getDouble("Price"));
                tp.setUnit(rs.getString("Unit"));
                tp.setCategoryName(rs.getString("CategoryName"));
                tp.setTotalSold(rs.getInt("TotalSold"));
                tp.setTotalRevenue(rs.getDouble("TotalRevenue"));
                list.add(tp);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getTop5BestSellers: " + e.getMessage());
        }

        // Nếu hệ thống mới ít đơn, bổ sung thêm các sản phẩm có sẵn để bảng Top 5 luôn có dữ liệu đẹp
        if (list.size() < 5) {
            String fallbackSql = "SELECT TOP " + (5 - list.size()) + " p.ProductID, p.ProductName, p.ImageUrl, p.Price, p.Unit, "
                               + "COALESCE(c.CategoryName, N'Khác') AS CategoryName "
                               + "FROM Products p LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                               + "WHERE p.IsActive = 1 ";
            if (!list.isEmpty()) {
                fallbackSql += "AND p.ProductID NOT IN (";
                for (int i = 0; i < list.size(); i++) {
                    fallbackSql += (i == 0 ? "?" : ", ?");
                }
                fallbackSql += ") ";
            }
            fallbackSql += "ORDER BY p.ProductID ASC";

            try (PreparedStatement stFallback = connection.prepareStatement(fallbackSql)) {
                for (int i = 0; i < list.size(); i++) {
                    stFallback.setInt(i + 1, list.get(i).getProductId());
                }
                try (ResultSet rsFallback = stFallback.executeQuery()) {
                    while (rsFallback.next()) {
                        TopProduct tp = new TopProduct();
                        tp.setProductId(rsFallback.getInt("ProductID"));
                        tp.setProductName(rsFallback.getString("ProductName"));
                        tp.setImageUrl(rsFallback.getString("ImageUrl"));
                        tp.setPrice(rsFallback.getDouble("Price"));
                        tp.setUnit(rsFallback.getString("Unit"));
                        tp.setCategoryName(rsFallback.getString("CategoryName"));
                        tp.setTotalSold(0);
                        tp.setTotalRevenue(0.0);
                        list.add(tp);
                    }
                }
            } catch (SQLException e) {
                System.err.println("Lỗi fallback Top 5: " + e.getMessage());
            }
        }

        return list;
    }

    // 8. Lấy N đơn hàng gần nhất cho Dashboard
    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT TOP " + limit + " * FROM Orders ORDER BY OrderID DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            OrderDAO orderDao = new OrderDAO();
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
                o.setDetails(orderDao.getOrderDetails(o.getOrderId()));
                list.add(o);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getRecentOrders: " + e.getMessage());
        }
        return list;
    }
}
