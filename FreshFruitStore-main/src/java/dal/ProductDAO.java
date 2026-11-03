package dal;

import model.Product;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO extends DBContext {

    public ProductDAO() {
        super();
    }

    // 1. Đọc đối tượng Product từ ResultSet
    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("ProductID"));
        p.setCategoryId(rs.getInt("CategoryID"));
        p.setProductName(rs.getString("ProductName"));
        p.setPrice(rs.getDouble("Price"));
        p.setUnit(rs.getString("Unit"));
        p.setStockQuantity(rs.getInt("StockQuantity"));
        p.setImageUrl(rs.getString("ImageUrl"));
        p.setDescription(rs.getString("Description"));
        
        // Hỗ trợ đọc IsActive (hoặc fallback Status nếu có)
        try {
            p.setStatus(rs.getBoolean("IsActive"));
        } catch (SQLException e) {
            try {
                p.setStatus(rs.getBoolean("Status"));
            } catch (SQLException ignored) {}
        }

        try {
            p.setCategoryName(rs.getString("CategoryName"));
        } catch (SQLException ignored) {}

        return p;
    }

    // 2. Lấy sản phẩm nổi bật / mới nhất (dùng cho Trang chủ index.jsp)
    public List<Product> getFeaturedProducts(int limit) {
        List<Product> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT TOP (?) p.*, c.CategoryName FROM Products p "
                   + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                   + "WHERE p.IsActive = 1 ORDER BY p.ProductID DESC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, limit);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getFeaturedProducts: " + e.getMessage());
        }
        return list;
    }

    // 3. Lấy sản phẩm có Bộ lọc (Danh mục + Tìm kiếm từ khóa) & Phân trang
    public List<Product> getProducts(Integer categoryId, String keyword, int pageIndex, int pageSize) {
        List<Product> list = new ArrayList<>();
        if (connection == null) return list;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.*, c.CategoryName FROM Products p ");
        sql.append("LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ");
        sql.append("WHERE p.IsActive = 1 ");

        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.CategoryID = ? ");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.ProductName LIKE ? OR p.Description LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        sql.append("ORDER BY p.ProductID DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        int offset = (pageIndex - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement st = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getProducts: " + e.getMessage());
        }
        return list;
    }

    // 4. Đếm tổng số sản phẩm thỏa mãn điều kiện lọc (để tính tổng số trang)
    public int countProducts(Integer categoryId, String keyword) {
        if (connection == null) return 0;

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Products WHERE IsActive = 1 ");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append("AND CategoryID = ? ");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (ProductName LIKE ? OR Description LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        try (PreparedStatement st = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi countProducts: " + e.getMessage());
        }
        return 0;
    }

    // 5. Lấy chi tiết 1 sản phẩm theo ID (Product Detail)
    public Product getProductById(int productId) {
        if (connection == null) return null;

        String sql = "SELECT p.*, c.CategoryName FROM Products p "
                   + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                   + "WHERE p.ProductID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, productId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getProductById: " + e.getMessage());
        }
        return null;
    }

    // 6. Lấy toàn bộ danh sách sản phẩm cho Admin Quản trị
    public List<Product> getAllProductsAdmin() {
        List<Product> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT p.*, c.CategoryName FROM Products p "
                   + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                   + "ORDER BY p.ProductID DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getAllProductsAdmin: " + e.getMessage());
        }
        return list;
    }

    // 7. Thêm sản phẩm mới (Admin)
    public boolean addProduct(Product p) {
        if (connection == null || p == null) return false;

        String sql = "INSERT INTO Products (CategoryID, ProductName, Price, Unit, StockQuantity, ImageUrl, Description, IsActive) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            if (p.getCategoryId() > 0) {
                st.setInt(1, p.getCategoryId());
            } else {
                st.setNull(1, java.sql.Types.INTEGER);
            }
            st.setString(2, p.getProductName());
            st.setDouble(3, p.getPrice());
            st.setString(4, p.getUnit());
            st.setInt(5, p.getStockQuantity());
            st.setString(6, p.getImageUrl());
            st.setString(7, p.getDescription());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi addProduct: " + e.getMessage());
        }
        return false;
    }

    // 8. Cập nhật thông tin sản phẩm (Admin)
    public boolean updateProduct(Product p) {
        if (connection == null || p == null) return false;

        String sql = "UPDATE Products SET CategoryID = ?, ProductName = ?, Price = ?, Unit = ?, "
                   + "StockQuantity = ?, ImageUrl = ?, Description = ? WHERE ProductID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            if (p.getCategoryId() > 0) {
                st.setInt(1, p.getCategoryId());
            } else {
                st.setNull(1, java.sql.Types.INTEGER);
            }
            st.setString(2, p.getProductName());
            st.setDouble(3, p.getPrice());
            st.setString(4, p.getUnit());
            st.setInt(5, p.getStockQuantity());
            st.setString(6, p.getImageUrl());
            st.setString(7, p.getDescription());
            st.setInt(8, p.getProductId());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateProduct: " + e.getMessage());
        }
        return false;
    }

    // 9. Bật / Tắt trạng thái kinh doanh của sản phẩm
    public boolean toggleProductStatus(int productId, boolean currentStatus) {
        if (connection == null) return false;

        String sql = "UPDATE Products SET IsActive = ? WHERE ProductID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setBoolean(1, !currentStatus);
            st.setInt(2, productId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi toggleProductStatus: " + e.getMessage());
        }
        return false;
    }

    // 10. Xóa sản phẩm
    public boolean deleteProduct(int productId) {
        if (connection == null) return false;

        String sql = "DELETE FROM Products WHERE ProductID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, productId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deleteProduct: " + e.getMessage());
        }
        return false;
    }
}
