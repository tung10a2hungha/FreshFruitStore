package controller;

import dal.OrderDAO;
import model.Order;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AdminOrderController extends HttpServlet {

    private boolean ensureAdmin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAccount = (session != null) ? (User) session.getAttribute("account") : null;

        if (currentAccount == null) {
            req.setAttribute("error", "Vui lòng đăng nhập bằng tài khoản Admin để truy cập khu vực Quản trị!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return false;
        }
        if (currentAccount.getRole() == null || !currentAccount.getRole().trim().equalsIgnoreCase("Admin")) {
            req.getRequestDispatcher("/access-denied.jsp").forward(req, resp);
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!ensureAdmin(req, resp)) return;

        HttpSession session = req.getSession(false);
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

        String statusFilter = req.getParameter("status");
        String keyword = req.getParameter("keyword");

        OrderDAO dao = new OrderDAO();
        List<Order> listAll = dao.getAllOrdersAdmin();

        // Tính toán thống kê theo dữ liệu thực
        int totalOrders = listAll.size();
        int pendingOrders = 0;
        int shippingOrders = 0;
        int completedOrders = 0;
        int cancelledOrders = 0;
        double totalRevenue = 0.0;

        for (Order o : listAll) {
            String st = o.getOrderStatus();
            if (st != null) {
                if (st.equalsIgnoreCase("Chờ xác nhận") || st.equalsIgnoreCase("Đã chuyển khoản")) {
                    pendingOrders++;
                } else if (st.equalsIgnoreCase("Đang giao hàng") || st.equalsIgnoreCase("Đã xác nhận") || st.equalsIgnoreCase("Đã thanh toán")) {
                    shippingOrders++;
                } else if (st.equalsIgnoreCase("Hoàn thành")) {
                    completedOrders++;
                    totalRevenue += o.getTotalAmount();
                } else if (st.equalsIgnoreCase("Đã hủy")) {
                    cancelledOrders++;
                }
            }
        }

        // Lọc danh sách theo yêu cầu của Admin
        List<Order> filteredList = dao.getOrdersByFilter(statusFilter, keyword);

        req.setAttribute("listOrder", filteredList);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("keyword", keyword);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("pendingOrders", pendingOrders);
        req.setAttribute("shippingOrders", shippingOrders);
        req.setAttribute("completedOrders", completedOrders);
        req.setAttribute("cancelledOrders", cancelledOrders);
        req.setAttribute("totalRevenue", totalRevenue);

        req.getRequestDispatcher("/admin-order.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!ensureAdmin(req, resp)) return;

        HttpSession session = req.getSession();
        String orderIdRaw = req.getParameter("orderId");
        String newStatus = req.getParameter("newStatus");

        if (orderIdRaw != null && newStatus != null) {
            try {
                int orderId = Integer.parseInt(orderIdRaw.trim());
                OrderDAO dao = new OrderDAO();
                boolean ok = dao.updateOrderStatus(orderId, newStatus.trim());

                if (ok) {
                    session.setAttribute("flashOrderMessage", "Đã cập nhật đơn hàng #" + orderId + " sang trạng thái '" + newStatus + "' thành công!");
                } else {
                    session.setAttribute("flashOrderError", "Không thể cập nhật trạng thái đơn hàng #" + orderId + "!");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("flashOrderError", "Mã đơn hàng không hợp lệ!");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/orders");
    }
}
