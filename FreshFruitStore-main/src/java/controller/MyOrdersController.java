package controller;

import dal.OrderDAO;
import dal.ProductDAO;
import model.Cart;
import model.Order;
import model.OrderDetail;
import model.Product;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class MyOrdersController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User account = (session != null) ? (User) session.getAttribute("account") : null;

        // Nếu chưa đăng nhập -> Chuyển về trang login
        if (account == null) {
            req.setAttribute("error", "Vui lòng đăng nhập để xem lịch sử đơn hàng của bạn!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // Đọc flash message nếu có
        if (session != null) {
            Object msg = session.getAttribute("flashOrderMessage");
            Object err = session.getAttribute("flashOrderError");
            if (msg != null) {
                req.setAttribute("message", msg);
                session.removeAttribute("flashOrderMessage");
            }
            if (err != null) {
                req.setAttribute("error", err);
                session.removeAttribute("flashOrderError");
            }
        }

        OrderDAO dao = new OrderDAO();
        List<Order> orders = dao.getOrdersByUserId(account.getUserId());

        // Thống kê nhanh đơn hàng của khách hàng
        int totalOrders = orders.size();
        int pendingCount = 0;
        int completedCount = 0;
        int cancelledCount = 0;

        for (Order o : orders) {
            String st = o.getOrderStatus();
            if (st != null) {
                if (st.equalsIgnoreCase("Hoàn thành")) {
                    completedCount++;
                } else if (st.equalsIgnoreCase("Đã hủy")) {
                    cancelledCount++;
                } else {
                    pendingCount++;
                }
            }
        }

        req.setAttribute("orders", orders);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("completedCount", completedCount);
        req.setAttribute("cancelledCount", cancelledCount);

        req.getRequestDispatcher("/my-orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User account = (session != null) ? (User) session.getAttribute("account") : null;

        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String oidRaw = req.getParameter("orderId");

        if (oidRaw != null) {
            try {
                int orderId = Integer.parseInt(oidRaw.trim());
                OrderDAO orderDao = new OrderDAO();

                if ("cancel".equalsIgnoreCase(action)) {
                    // Khách hàng yêu cầu hủy đơn hàng của chính mình
                    boolean ok = orderDao.cancelOrderByCustomer(orderId, account.getUserId());
                    if (ok) {
                        session.setAttribute("flashOrderMessage", "Đã hủy đơn hàng #" + orderId + " thành công!");
                    } else {
                        session.setAttribute("flashOrderError", "Không thể hủy đơn hàng #" + orderId + " do đơn đã được tiếp nhận xử lý hoặc không hợp lệ!");
                    }
                    resp.sendRedirect(req.getContextPath() + "/my-orders");
                    return;

                } else if ("reorder".equalsIgnoreCase(action)) {
                    // Mua lại các mặt hàng trong đơn hàng cũ: thêm lại vào giỏ hàng
                    Order oldOrder = orderDao.getOrderById(orderId);
                    if (oldOrder != null && oldOrder.getUserId() != null && oldOrder.getUserId() == account.getUserId()) {
                        Cart cart = (Cart) session.getAttribute("cart");
                        if (cart == null) {
                            cart = new Cart();
                            session.setAttribute("cart", cart);
                        }

                        ProductDAO prodDao = new ProductDAO();
                        int addedCount = 0;
                        for (OrderDetail d : oldOrder.getDetails()) {
                            Product p = prodDao.getProductById(d.getProductId());
                            if (p != null && p.getStockQuantity() > 0) {
                                cart.addItem(p, d.getQuantity());
                                addedCount++;
                            }
                        }

                        if (addedCount > 0) {
                            session.setAttribute("flashCartMessage", "Đã thêm các món từ đơn #" + orderId + " vào giỏ hàng của bạn!");
                            resp.sendRedirect(req.getContextPath() + "/cart");
                            return;
                        } else {
                            session.setAttribute("flashOrderError", "Các mặt hàng trong đơn này hiện đã tạm hết hàng trong kho!");
                        }
                    }
                }
            } catch (NumberFormatException ignored) {}
        }

        resp.sendRedirect(req.getContextPath() + "/my-orders");
    }
}
