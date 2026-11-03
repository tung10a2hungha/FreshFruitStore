package controller;

import dal.DashboardDAO;
import model.Order;
import model.TopProduct;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AdminDashboardController extends HttpServlet {

    private boolean ensureAdmin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAccount = (session != null) ? (User) session.getAttribute("account") : null;

        if (currentAccount == null) {
            req.setAttribute("error", "Vui lòng đăng nhập bằng tài khoản Quản trị viên để truy cập Dashboard!");
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

        DashboardDAO dao = new DashboardDAO();

        double totalRevenue = dao.getTotalRevenue();
        int pendingOrders = dao.getPendingOrdersCount();
        int totalOrders = dao.getTotalOrdersCount();
        int totalCustomers = dao.getTotalCustomersCount();
        int totalProducts = dao.getTotalProductsCount();
        int lowStockCount = dao.getLowStockProductsCount();

        List<TopProduct> top5Products = dao.getTop5BestSellers();
        List<Order> recentOrders = dao.getRecentOrders(5);

        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("pendingOrders", pendingOrders);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalCustomers", totalCustomers);
        req.setAttribute("totalProducts", totalProducts);
        req.setAttribute("lowStockCount", lowStockCount);
        req.setAttribute("top5Products", top5Products);
        req.setAttribute("recentOrders", recentOrders);

        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, resp);
    }
}
