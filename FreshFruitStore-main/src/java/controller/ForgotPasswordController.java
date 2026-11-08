package controller;

import dal.UserDAO;
import model.User;
import util.EmailUtils;
import java.io.IOException;
import java.security.SecureRandom;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý luồng Quên mật khẩu & Gửi mã OTP xác thực về Gmail.
 */
public class ForgotPasswordController extends HttpServlet {

    private static final SecureRandom random = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String step = req.getParameter("step");
        HttpSession session = req.getSession();

        if ("verify".equalsIgnoreCase(step)) {
            // Bước 2: Nhập mã OTP
            if (session.getAttribute("fpEmail") == null) {
                resp.sendRedirect(req.getContextPath() + "/forgot-password");
                return;
            }
            req.getRequestDispatcher("/verify-otp.jsp").forward(req, resp);

        } else if ("reset".equalsIgnoreCase(step)) {
            // Bước 3: Đặt lại mật khẩu mới (chỉ vào được nếu đã verify OTP thành công)
            Boolean verified = (Boolean) session.getAttribute("fpVerified");
            if (verified == null || !verified) {
                resp.sendRedirect(req.getContextPath() + "/forgot-password");
                return;
            }
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);

        } else {
            // Bước 1: Mặc định hiển thị trang nhập Email / Username
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "send-otp":
                handleSendOtp(req, resp);
                break;
            case "resend-otp":
                handleResendOtp(req, resp);
                break;
            case "verify-otp":
                handleVerifyOtp(req, resp);
                break;
            case "reset-password":
                handleResetPassword(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/forgot-password");
                break;
        }
    }

    /**
     * Xử lý Bước 1: Nhận Email/Username -> Kiểm tra tài khoản -> Tạo & Gửi OTP về Gmail
     */
    private void handleSendOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String input = req.getParameter("accountInput");
        if (input == null || input.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập Email hoặc Tên đăng nhập!");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.getUserByUsernameOrEmail(input.trim());

        if (user == null) {
            req.setAttribute("error", "Không tìm thấy tài khoản nào khớp với thông tin bạn cung cấp!");
            req.setAttribute("accountInput", input);
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (user.isLocked()) {
            req.setAttribute("error", "Tài khoản này đã bị khóa bởi Quản trị viên, không thể khôi phục mật khẩu!");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            req.setAttribute("error", "Tài khoản '" + user.getUsername() + "' chưa liên kết địa chỉ Email. Vui lòng liên hệ Admin!");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Tạo mã OTP 6 chữ số ngẫu nhiên
        String otpCode = String.format("%06d", random.nextInt(1000000));
        long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000); // Có hiệu lực 5 phút

        HttpSession session = req.getSession();
        session.setAttribute("fpUserId", user.getUserId());
        session.setAttribute("fpUsername", user.getUsername());
        session.setAttribute("fpEmail", user.getEmail());
        session.setAttribute("fpMaskedEmail", maskEmail(user.getEmail()));
        session.setAttribute("fpOtp", otpCode);
        session.setAttribute("fpOtpExpiry", expiryTime);
        session.setAttribute("fpVerified", false);

        // Gửi email qua Gmail SMTP
        boolean sent = EmailUtils.sendOtpEmail(user.getEmail(), user.getFullName(), otpCode);

        if (!sent) {
            // Trường hợp chưa cấu hình App Password hoặc lỗi mạng
            req.setAttribute("warning", "Hệ thống đang chạy chế độ kiểm thử (DEV MODE). Mã OTP đã được in ra cửa sổ Server Console để bạn kiểm tra!");
        } else {
            req.setAttribute("message", "Mã xác nhận đã được gửi tới email " + maskEmail(user.getEmail()) + ". Vui lòng kiểm tra hộp thư!");
        }

        req.getRequestDispatcher("/verify-otp.jsp").forward(req, resp);
    }

    /**
     * Xử lý gửi lại mã xác nhận
     */
    private void handleResendOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String email = (String) session.getAttribute("fpEmail");
        String username = (String) session.getAttribute("fpUsername");

        if (email == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Tạo OTP mới và gia hạn thêm 5 phút
        String newOtp = String.format("%06d", random.nextInt(1000000));
        long newExpiry = System.currentTimeMillis() + (5 * 60 * 1000);

        session.setAttribute("fpOtp", newOtp);
        session.setAttribute("fpOtpExpiry", newExpiry);
        session.setAttribute("fpVerified", false);

        boolean sent = EmailUtils.sendOtpEmail(email, username, newOtp);
        if (!sent) {
            req.setAttribute("warning", "Chưa kết nối được Gmail SMTP. Mã OTP mới đã được in ra console server!");
        } else {
            req.setAttribute("message", "Đã gửi lại mã xác nhận mới tới email của bạn!");
        }

        req.getRequestDispatcher("/verify-otp.jsp").forward(req, resp);
    }

    /**
     * Xử lý Bước 2: Kiểm tra mã OTP người dùng nhập vào
     */
    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String sessionOtp = (String) session.getAttribute("fpOtp");
        Long expiryTime = (Long) session.getAttribute("fpOtpExpiry");

        if (sessionOtp == null || expiryTime == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String enteredOtp = req.getParameter("otpCode");
        if (enteredOtp == null || enteredOtp.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập mã OTP 6 chữ số!");
            req.getRequestDispatcher("/verify-otp.jsp").forward(req, resp);
            return;
        }

        // Kiểm tra thời gian hết hạn
        if (System.currentTimeMillis() > expiryTime) {
            req.setAttribute("error", "Mã OTP đã hết hiệu lực (sau 5 phút). Vui lòng nhấn 'Gửi lại mã'!");
            req.getRequestDispatcher("/verify-otp.jsp").forward(req, resp);
            return;
        }

        // Kiểm tra tính chính xác của OTP
        if (!sessionOtp.equals(enteredOtp.trim())) {
            req.setAttribute("error", "Mã xác nhận không chính xác! Vui lòng kiểm tra lại hộp thư.");
            req.getRequestDispatcher("/verify-otp.jsp").forward(req, resp);
            return;
        }

        // Xác nhận thành công -> Đánh dấu session và chuyển sang bước đổi mật khẩu
        session.setAttribute("fpVerified", true);
        resp.sendRedirect(req.getContextPath() + "/forgot-password?step=reset");
    }

    /**
     * Xử lý Bước 3: Lưu mật khẩu mới vào cơ sở dữ liệu
     */
    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Boolean verified = (Boolean) session.getAttribute("fpVerified");
        Integer userId = (Integer) session.getAttribute("fpUserId");

        if (verified == null || !verified || userId == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (newPassword == null || newPassword.trim().length() < 6) {
            req.setAttribute("error", "Mật khẩu mới phải có độ dài từ 6 ký tự trở lên!");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        boolean success = dao.updatePasswordByUserId(userId, newPassword.trim());

        if (success) {
            // Xóa sạch session quên mật khẩu để bảo mật
            session.removeAttribute("fpUserId");
            session.removeAttribute("fpUsername");
            session.removeAttribute("fpEmail");
            session.removeAttribute("fpMaskedEmail");
            session.removeAttribute("fpOtp");
            session.removeAttribute("fpOtpExpiry");
            session.removeAttribute("fpVerified");

            // Lưu thông báo thành công cho trang đăng nhập
            session.setAttribute("loginSuccessMessage", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.");
            resp.sendRedirect(req.getContextPath() + "/login");
        } else {
            req.setAttribute("error", "Không thể cập nhật mật khẩu lúc này. Vui lòng thử lại sau!");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        }
    }

    /**
     * Ẩn bớt ký tự email để bảo mật: ví dụ nguyenvana@gmail.com -> ng***a@gmail.com
     */
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        int atIndex = email.indexOf('@');
        String name = email.substring(0, atIndex);
        String domain = email.substring(atIndex);
        if (name.length() <= 2) {
            return name.charAt(0) + "***" + domain;
        }
        return name.substring(0, 2) + "***" + name.charAt(name.length() - 1) + domain;
    }
}
