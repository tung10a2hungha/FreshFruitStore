package dal;

import model.Category;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO extends DBContext {

    public CategoryDAO() {
        super();
    }

    // 1. Lấy toàn bộ danh mục để hiển thị lên Menu/Sidebar
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT * FROM Categories ORDER BY CategoryID ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("CategoryID"));
                c.setCategoryName(rs.getString("CategoryName"));
                list.add(c);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getAllCategories: " + e.getMessage());
        }
        return list;
    }

    // 2. Lấy thông tin danh mục theo ID
    public Category getCategoryById(int id) {
        if (connection == null) return null;

        String sql = "SELECT * FROM Categories WHERE CategoryID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return new Category(rs.getInt("CategoryID"), rs.getString("CategoryName"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getCategoryById: " + e.getMessage());
        }
        return null;
    }

    // 3. Thêm mới danh mục (Admin)
    public boolean addCategory(String categoryName) {
        if (connection == null || categoryName == null || categoryName.trim().isEmpty()) return false;

        String sql = "INSERT INTO Categories (CategoryName) VALUES (?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, categoryName.trim());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi addCategory: " + e.getMessage());
        }
        return false;
    }

    // 4. Sửa danh mục (Admin)
    public boolean updateCategory(int id, String newName) {
        if (connection == null || newName == null || newName.trim().isEmpty()) return false;

        String sql = "UPDATE Categories SET CategoryName = ? WHERE CategoryID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, newName.trim());
            st.setInt(2, id);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateCategory: " + e.getMessage());
        }
        return false;
    }

    // 5. Xóa danh mục (Admin)
    public boolean deleteCategory(int id) {
        if (connection == null) return false;

        String sql = "DELETE FROM Categories WHERE CategoryID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deleteCategory: " + e.getMessage());
        }
        return false;
    }
}
