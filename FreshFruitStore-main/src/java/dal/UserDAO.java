package dal;

import model.User;
import util.SecurityUtils;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO extends DBContext {

    public UserDAO() {
        super();
    }

    // 1. Kiểm tra đăng nhập với xác thực mật khẩu (Hỗ trợ SHA-256 & Plain-text)
    public User checkLogin(String username, String password) {
        if (username == null || password == null || connection == null) {
            return null;
        }

        String sql = "SELECT * FROM Users WHERE Username = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, username.trim());
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("Password");
                    // Xác thực mật khẩu
                    if (SecurityUtils.verifyPassword(password, storedPassword)) {
                        User u = new User();
                        u.setUserId(rs.getInt("UserID"));
                        u.setUsername(rs.getString("Username"));
                        u.setPassword(storedPassword);
                        u.setFullName(rs.getString("FullName"));
                        u.setEmail(rs.getString("Email"));
                        u.setPhone(rs.getString("Phone"));
                        u.setAddress(rs.getString("Address"));
                        u.setRole(rs.getString("Role") != null ? rs.getString("Role").trim() : "Customer");
                        u.setLocked(!rs.getBoolean("IsActive"));
                        return u;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi SQL checkLogin: " + e.getMessage());
        }
        return null;
    }

    // 2. Kiểm tra trùng Username khi đăng ký
    public boolean checkUserExist(String username) {
        if (username == null || connection == null) {
            return false;
        }

        String sql = "SELECT 1 FROM Users WHERE Username = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, username.trim());
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Lỗi checkUserExist: " + e.getMessage());
        }
        return false;
    }

    // 3. Đăng ký tài khoản mới (Tự động băm mật khẩu bằng SHA-256)
    public void registerUser(String user, String pass, String name, String phone, String address) {
        registerUser(user, pass, name, null, phone, address);
    }

    public void registerUser(String user, String pass, String name, String email, String phone, String address) {
        if (connection == null) return;

        // Băm mật khẩu bằng SHA-256 trước khi lưu vào CSDL
        String hashedPassword = SecurityUtils.hashPassword(pass);

        String sql = "INSERT INTO Users (Username, Password, FullName, Email, Phone, Address, Role, IsActive) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 'Customer', 1)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, user != null ? user.trim() : "");
            st.setString(2, hashedPassword);
            st.setString(3, name);
            st.setString(4, email != null ? email.trim() : null);
            st.setString(5, phone);
            st.setString(6, address);
            st.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Lỗi registerUser: " + e.getMessage());
        }
    }

    // 4. Lấy thông tin User theo UserID
    public User getUserById(int userId) {
        if (connection == null) return null;

        String sql = "SELECT * FROM Users WHERE UserID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("UserID"));
                    u.setUsername(rs.getString("Username"));
                    u.setPassword(rs.getString("Password"));
                    u.setFullName(rs.getString("FullName"));
                    u.setEmail(rs.getString("Email"));
                    u.setPhone(rs.getString("Phone"));
                    u.setAddress(rs.getString("Address"));
                    u.setRole(rs.getString("Role") != null ? rs.getString("Role").trim() : "Customer");
                    u.setLocked(!rs.getBoolean("IsActive"));
                    return u;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserById: " + e.getMessage());
        }
        return null;
    }

    // 5. Cập nhật thông tin tài khoản cá nhân & Đổi mật khẩu (Profile)
    public boolean updateUserProfile(int userId, String fullName, String phone, String address, String newPassword) {
        return updateUserProfile(userId, fullName, null, phone, address, newPassword);
    }

    public boolean updateUserProfile(int userId, String fullName, String email, String phone, String address, String newPassword) {
        if (connection == null) return false;

        boolean changePassword = (newPassword != null && !newPassword.trim().isEmpty());
        String sql;
        if (email != null && !email.trim().isEmpty()) {
            sql = changePassword
                    ? "UPDATE Users SET FullName = ?, Email = ?, Phone = ?, Address = ?, Password = ? WHERE UserID = ?"
                    : "UPDATE Users SET FullName = ?, Email = ?, Phone = ?, Address = ? WHERE UserID = ?";
        } else {
            sql = changePassword
                    ? "UPDATE Users SET FullName = ?, Phone = ?, Address = ?, Password = ? WHERE UserID = ?"
                    : "UPDATE Users SET FullName = ?, Phone = ?, Address = ? WHERE UserID = ?";
        }

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            int idx = 1;
            st.setString(idx++, fullName);
            if (email != null && !email.trim().isEmpty()) {
                st.setString(idx++, email.trim());
            }
            st.setString(idx++, phone);
            st.setString(idx++, address);
            if (changePassword) {
                // Băm mật khẩu mới bằng SHA-256
                st.setString(idx++, SecurityUtils.hashPassword(newPassword.trim()));
            }
            st.setInt(idx, userId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateUserProfile: " + e.getMessage());
        }
        return false;
    }

    // 6. Lấy danh sách toàn bộ User cho Admin
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT * FROM Users ORDER BY UserID ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("UserID"));
                u.setUsername(rs.getString("Username"));
                u.setPassword(rs.getString("Password"));
                u.setFullName(rs.getString("FullName"));
                u.setEmail(rs.getString("Email"));
                u.setPhone(rs.getString("Phone"));
                u.setAddress(rs.getString("Address"));
                u.setRole(rs.getString("Role") != null ? rs.getString("Role").trim() : "Customer");
                u.setLocked(!rs.getBoolean("IsActive"));
                list.add(u);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getAllUsers: " + e.getMessage());
        }
        return list;
    }

    // 7. Khóa / Mở khóa tài khoản (Admin)
    public boolean setUserLocked(int userId, boolean isLocked) {
        if (connection == null) return false;

        String sql = "UPDATE Users SET IsActive = ? WHERE UserID = ? AND Role <> 'Admin'";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setBoolean(1, !isLocked); // isLocked = true -> IsActive = 0
            st.setInt(2, userId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi setUserLocked: " + e.getMessage());
        }
        return false;
    }

    // 8. Tương thích ngược: Đặt trạng thái Active trực tiếp
    public boolean setUserActive(int userId, boolean isActive) {
        return setUserLocked(userId, !isActive);
    }

    // 9. Lấy User theo Email
    public User getUserByEmail(String email) {
        if (email == null || connection == null) {
            return null;
        }
        String sql = "SELECT * FROM Users WHERE LOWER(LTRIM(RTRIM(Email))) = LOWER(?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, email.trim());
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserByEmail: " + e.getMessage());
        }
        return null;
    }

    // 10. Lấy User theo Username hoặc Email (rất tiện lợi cho đăng nhập / quên mật khẩu)
    public User getUserByUsernameOrEmail(String input) {
        if (input == null || connection == null) {
            return null;
        }
        String trimmed = input.trim();
        String sql = "SELECT * FROM Users WHERE LOWER(LTRIM(RTRIM(Username))) = LOWER(?) OR LOWER(LTRIM(RTRIM(Email))) = LOWER(?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, trimmed);
            st.setString(2, trimmed);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserByUsernameOrEmail: " + e.getMessage());
        }
        return null;
    }

    // 11. Cập nhật mật khẩu theo UserID (băm SHA-256)
    public boolean updatePasswordByUserId(int userId, String newPassword) {
        if (connection == null || newPassword == null || newPassword.trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE Users SET Password = ? WHERE UserID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, SecurityUtils.hashPassword(newPassword.trim()));
            st.setInt(2, userId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updatePasswordByUserId: " + e.getMessage());
        }
        return false;
    }

    // 12. Cập nhật mật khẩu theo Email (băm SHA-256)
    public boolean updatePasswordByEmail(String email, String newPassword) {
        if (connection == null || email == null || newPassword == null || newPassword.trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE Users SET Password = ? WHERE LOWER(LTRIM(RTRIM(Email))) = LOWER(?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, SecurityUtils.hashPassword(newPassword.trim()));
            st.setString(2, email.trim());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updatePasswordByEmail: " + e.getMessage());
        }
        return false;
    }

    // Helper map ResultSet sang đối tượng User
    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("UserID"));
        u.setUsername(rs.getString("Username"));
        u.setPassword(rs.getString("Password"));
        u.setFullName(rs.getString("FullName"));
        u.setEmail(rs.getString("Email"));
        u.setPhone(rs.getString("Phone"));
        u.setAddress(rs.getString("Address"));
        u.setRole(rs.getString("Role") != null ? rs.getString("Role").trim() : "Customer");
        u.setLocked(!rs.getBoolean("IsActive"));
        return u;
    }
}
