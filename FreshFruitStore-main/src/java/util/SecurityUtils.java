package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SecurityUtils {

    // 1. Mã hóa mật khẩu bằng thuật toán SHA-256
    public static String hashPassword(String password) {
        if (password == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
            
            // Chuyển đổi byte sang định dạng Hexadecimal (64 ký tự)
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            System.err.println("Lỗi thuật toán mã hóa SHA-256: " + e.getMessage());
            return password;
        }
    }

    // 2. Kiểm tra mật khẩu (hỗ trợ cả mật khẩu băm SHA-256 và mật khẩu mẫu plain-text cũ)
    public static boolean verifyPassword(String rawPassword, String storedPassword) {
        if (rawPassword == null || storedPassword == null) return false;

        // Nếu mật khẩu trong CSDL đã được hash SHA-256
        String hashedRaw = hashPassword(rawPassword);
        if (hashedRaw.equalsIgnoreCase(storedPassword)) {
            return true;
        }

        // Tương thích ngược: Nếu CSDL chứa tài khoản mẫu plain-text (ví dụ '123456', '123')
        return rawPassword.equals(storedPassword);
    }
}
