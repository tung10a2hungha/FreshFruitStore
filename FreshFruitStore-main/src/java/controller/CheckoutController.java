package controller;

import dal.OrderDAO;
import model.Cart;
import model.Order;
import model.User;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class CheckoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        // Xử lý xem trang Đặt Hàng Thành Công: /order-success
        if ("/order-success".equalsIgnoreCase(servletPath)) {
            String oidRaw = req.getParameter("orderId");
            if (oidRaw != null) {
                try {
                    int orderId = Integer.parseInt(oidRaw.trim());
                    OrderDAO dao = new OrderDAO();
                    Order order = dao.getOrderById(orderId);
                    if (order != null) {
                        req.setAttribute("order", order);
                        req.getRequestDispatcher("/order-success.jsp").forward(req, resp);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        // Mặc định: Xem trang Checkout (/checkout)
        HttpSession session = req.getSession(false);
        Cart cart = (session != null) ? (Cart) session.getAttribute("cart") : null;

        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        Cart cart = (Cart) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        String receiverName = req.getParameter("receiverName");
        String receiverPhone = req.getParameter("receiverPhone");
        String shippingAddress = req.getParameter("shippingAddress");
        String orderNote = req.getParameter("orderNote");
        String paymentMethod = req.getParameter("paymentMethod");

        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "COD";
        }

        User account = (User) session.getAttribute("account");
        Integer userId = (account != null) ? account.getUserId() : null;

        Order order = new Order();
        order.setUserId(userId);
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setShippingAddress(shippingAddress);
        order.setOrderNote(orderNote);
        order.setTotalAmount(cart.getTotalAmount());
        order.setPaymentMethod(paymentMethod);
        order.setOrderStatus("Chờ xác nhận");

        OrderDAO orderDao = new OrderDAO();
        try {
            // Chạy Transaction tạo đơn hàng và trừ kho
            int orderId = orderDao.createOrder(order, cart);

            if (orderId > 0) {
                // Xóa rỗng giỏ hàng sau khi đặt thành công
                cart.clear();
                session.setAttribute("cart", cart);

                // Điều hướng theo phương thức thanh toán
                if ("BANK_TRANSFER".equalsIgnoreCase(paymentMethod)) {
                    // Chuyển sang màn hình quét mã VietQR (Bước 5)
                    resp.sendRedirect(req.getContextPath() + "/payment?orderId=" + orderId);
                } else {
                    // Chuyển sang màn hình Đặt hàng thành công
                    resp.sendRedirect(req.getContextPath() + "/order-success?orderId=" + orderId);
                }
            } else {
                req.setAttribute("error", "Không thể tạo đơn hàng, vui lòng thử lại!");
                req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
            }

        } catch (SQLException e) {
            req.setAttribute("error", "Lỗi xử lý kho hoặc giao dịch: " + e.getMessage());
            req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
        }
    }
}
