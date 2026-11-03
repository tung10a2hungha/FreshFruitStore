package controller;

import dal.UserDAO;
import model.User;
import util.SecurityUtils;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class ProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User account = (session != null) ? (User) session.getAttribute("account") : null;

        if (account == null) {
            req.setAttribute("error", "Vui lòng đăng nhập để xem thông tin tài khoản!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // Đồng bộ lại thông tin mới nhất từ DAO
        UserDAO dao = new UserDAO();
        User freshUser = dao.getUserById(account.getUserId());
        if (freshUser != null) {
            session.setAttribute("account", freshUser);
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User account = (session != null) ? (User) session.getAttribute("account") : null;

        if (account == null) {
            req.setAttribute("error", "Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        String fullName = req.getParameter("fullname");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String newPassword = req.getParameter("password");

        UserDAO dao = new UserDAO();
        boolean updated = dao.updateUserProfile(account.getUserId(), fullName, email, phone, address, newPassword);

        if (updated) {
            account.setFullName(fullName);
            if (email != null) account.setEmail(email.trim());
            account.setPhone(phone);
            account.setAddress(address);
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                account.setPassword(SecurityUtils.hashPassword(newPassword.trim()));
            }
            session.setAttribute("account", account);
            req.setAttribute("message", "Cập nhật thông tin tài khoản thành công!");
        } else {
            req.setAttribute("error", "Không thể cập nhật thông tin tài khoản!");
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }
}
