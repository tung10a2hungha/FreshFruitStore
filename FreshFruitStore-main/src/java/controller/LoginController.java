package controller;

import dal.UserDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class LoginController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            Object msg = session.getAttribute("loginSuccessMessage");
            if (msg != null) {
                req.setAttribute("message", msg);
                session.removeAttribute("loginSuccessMessage");
            }
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String user = req.getParameter("username");
        String pass = req.getParameter("password");

        UserDAO dao = new UserDAO();
        User account = dao.checkLogin(user, pass);

        if (account == null) {
            // Sai tài khoản/mật khẩu -> Đẩy lại về trang login kèm báo lỗi
            req.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } else if (account.isLocked()) {
            // Tài khoản bị Admin khóa -> Báo lỗi không cho đăng nhập
            req.setAttribute("error", "Tài khoản của bạn đã bị khóa bởi Quản trị viên!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } else {
            // Đăng nhập thành công -> Lưu thông tin vào Session (Phiên làm việc)
            HttpSession session = req.getSession();
            session.setAttribute("account", account);

            // BẺ LÁI DỰA TRÊN ROLE
            if (account.getRole() != null && account.getRole().equalsIgnoreCase("Admin")) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard"); // Bay vào Dashboard Báo Cáo Admin
            } else {
                resp.sendRedirect(req.getContextPath() + "/index.jsp"); // Chuyển thẳng vào Trang chủ
            }
        }
    }
}
