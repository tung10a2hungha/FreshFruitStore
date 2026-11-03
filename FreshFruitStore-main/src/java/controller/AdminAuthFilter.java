package controller;

import model.User;
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Filter phân quyền Admin (Module Auth & Phân quyền - Dev 1)
 * Chặn tất cả truy cập tự do vào các trang và chức năng của Admin (/admin/*, /admin-user.jsp, /admin-order.jsp).
 * Chỉ cho phép đi tiếp khi đã đăng nhập bằng tài khoản có Role = 'Admin'.
 */
public class AdminAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        User account = (session != null) ? (User) session.getAttribute("account") : null;

        // 1. Chưa đăng nhập -> Bắt buộc chuyển hướng về trang Đăng nhập
        if (account == null) {
            req.setAttribute("error", "Vui lòng đăng nhập bằng tài khoản Admin để truy cập khu vực Quản trị!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // 2. Đã đăng nhập nhưng không phải Admin (ví dụ: Customer) -> Báo lỗi 403 Không có quyền truy cập
        String role = account.getRole();
        if (role == null || !role.trim().equalsIgnoreCase("Admin")) {
            req.getRequestDispatcher("/access-denied.jsp").forward(req, resp);
            return;
        }

        // 3. Đúng là Admin -> Cho phép thực hiện tiếp
        chain.doFilter(request, response);
    }
}
