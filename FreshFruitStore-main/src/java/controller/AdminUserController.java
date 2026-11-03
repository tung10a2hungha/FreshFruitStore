package controller;

import dal.UserDAO;
import model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AdminUserController extends HttpServlet {

    // Kiểm tra bắt buộc phải đăng nhập bằng tài khoản Admin
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
        if (!ensureAdmin(req, resp)) {
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null) {
            Object flashMsg = session.getAttribute("flashMessage");
            Object flashErr = session.getAttribute("flashError");
            if (flashMsg != null) {
                req.setAttribute("message", flashMsg);
                session.removeAttribute("flashMessage");
            }
            if (flashErr != null) {
                req.setAttribute("error", flashErr);
                session.removeAttribute("flashError");
            }
        }

        UserDAO dao = new UserDAO();
        List<User> allUsers = dao.getAllUsers();

        // Tính toán số liệu thống kê thực tế
        int totalCount = allUsers.size();
        int activeCount = 0;
        int lockedCount = 0;
        int adminCount = 0;
        for (User u : allUsers) {
            if (u.isLocked()) {
                lockedCount++;
            } else {
                activeCount++;
            }
            if (u.getRole() != null && u.getRole().equalsIgnoreCase("Admin")) {
                adminCount++;
            }
        }

        // Lọc danh sách theo từ khóa, vai trò, trạng thái (nếu có)
        String keyword = req.getParameter("keyword");
        String roleFilter = req.getParameter("role");
        String statusFilter = req.getParameter("status");

        List<User> filteredUsers = new ArrayList<>();
        for (User u : allUsers) {
            boolean matchKeyword = true;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = keyword.trim().toLowerCase();
                String uname = u.getUsername() != null ? u.getUsername().toLowerCase() : "";
                String fname = u.getFullName() != null ? u.getFullName().toLowerCase() : "";
                String phone = u.getPhone() != null ? u.getPhone().toLowerCase() : "";
                matchKeyword = uname.contains(kw) || fname.contains(kw) || phone.contains(kw);
            }

            boolean matchRole = true;
            if (roleFilter != null && !roleFilter.trim().isEmpty()) {
                matchRole = u.getRole() != null && u.getRole().equalsIgnoreCase(roleFilter.trim());
            }

            boolean matchStatus = true;
            if ("active".equalsIgnoreCase(statusFilter)) {
                matchStatus = !u.isLocked();
            } else if ("locked".equalsIgnoreCase(statusFilter)) {
                matchStatus = u.isLocked();
            }

            if (matchKeyword && matchRole && matchStatus) {
                filteredUsers.add(u);
            }
        }

        req.setAttribute("totalCount", totalCount);
        req.setAttribute("activeCount", activeCount);
        req.setAttribute("lockedCount", lockedCount);
        req.setAttribute("adminCount", adminCount);
        req.setAttribute("listUser", filteredUsers);
        req.getRequestDispatcher("/admin-user.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!ensureAdmin(req, resp)) {
            return;
        }

        HttpSession session = req.getSession();
        String userIdRaw = req.getParameter("userId");
        String action = req.getParameter("action");

        UserDAO dao = new UserDAO();
        if (userIdRaw != null) {
            try {
                int userId = Integer.parseInt(userIdRaw.trim());
                User target = dao.getUserById(userId);

                if (target == null) {
                    session.setAttribute("flashError", "Không tìm thấy tài khoản #" + userId + "!");
                } else if (target.getRole() != null && target.getRole().equalsIgnoreCase("Admin")) {
                    session.setAttribute("flashError", "Không thể khóa tài khoản Quản trị viên (" + target.getUsername() + ")!");
                } else {
                    boolean lock;
                    if ("unlock".equalsIgnoreCase(action)) {
                        lock = false;
                    } else if ("lock".equalsIgnoreCase(action)) {
                        lock = true;
                    } else {
                        lock = !target.isLocked();
                    }

                    boolean ok = dao.setUserLocked(userId, lock);
                    if (ok) {
                        session.setAttribute("flashMessage",
                                (lock ? "Đã khóa tài khoản " : "Đã mở khóa tài khoản ")
                                + "'" + target.getUsername() + "' (#" + userId + ") thành công!");
                    } else {
                        session.setAttribute("flashError", "Không thể cập nhật trạng thái tài khoản #" + userId + "!");
                    }
                }
            } catch (NumberFormatException ignored) {
                session.setAttribute("flashError", "Mã tài khoản không hợp lệ!");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
