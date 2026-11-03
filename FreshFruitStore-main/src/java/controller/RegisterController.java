package controller;

import java.io.IOException;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }
   
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String user = req.getParameter("username");
        String pass = req.getParameter("password");
        String confirmPass = req.getParameter("confirmPassword");
        String name = req.getParameter("fullname");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");

        // Validate cơ bản
        if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
            req.setAttribute("error", "Tên đăng nhập và mật khẩu không được để trống!");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        if (confirmPass != null && !confirmPass.isEmpty() && !pass.equals(confirmPass)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        
        // Kiểm tra trùng username
        if (dao.checkUserExist(user.trim())) {
            req.setAttribute("error", "Tên đăng nhập '" + user.trim() + "' đã có người sử dụng!");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // Đăng ký tài khoản mới (Mật khẩu được băm SHA-256 an toàn trong DAO)
        dao.registerUser(user.trim(), pass, name, email, phone, address);

        // Lưu thông báo thành công và chuyển hướng về trang đăng nhập
        HttpSession session = req.getSession();
        session.setAttribute("loginSuccessMessage", "Đăng ký tài khoản thành công! Vui lòng đăng nhập để tiếp tục.");
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
