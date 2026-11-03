package controller;

import dal.CategoryDAO;
import dal.ProductDAO;
import model.Category;
import model.Product;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AdminProductController extends HttpServlet {

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
        if (!ensureAdmin(req, resp)) return;

        HttpSession session = req.getSession(false);
        if (session != null) {
            Object msg = session.getAttribute("flashMessage");
            Object err = session.getAttribute("flashError");
            if (msg != null) {
                req.setAttribute("message", msg);
                session.removeAttribute("flashMessage");
            }
            if (err != null) {
                req.setAttribute("error", err);
                session.removeAttribute("flashError");
            }
        }

        ProductDAO productDao = new ProductDAO();
        CategoryDAO categoryDao = new CategoryDAO();

        List<Product> listProduct = productDao.getAllProductsAdmin();
        List<Category> listCategory = categoryDao.getAllCategories();

        req.setAttribute("listProduct", listProduct);
        req.setAttribute("listCategory", listCategory);
        req.getRequestDispatcher("/admin-product.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!ensureAdmin(req, resp)) return;

        HttpSession session = req.getSession();
        String action = req.getParameter("action");
        ProductDAO productDao = new ProductDAO();
        CategoryDAO categoryDao = new CategoryDAO();

        try {
            if ("add-product".equalsIgnoreCase(action)) {
                String name = req.getParameter("productName");
                int categoryId = Integer.parseInt(req.getParameter("categoryId"));
                double price = Double.parseDouble(req.getParameter("price"));
                String unit = req.getParameter("unit");
                int stock = Integer.parseInt(req.getParameter("stockQuantity"));
                String imageUrl = req.getParameter("imageUrl");
                String description = req.getParameter("description");

                Product p = new Product(0, categoryId, name, price, unit, stock, imageUrl, description);
                boolean ok = productDao.addProduct(p);
                if (ok) {
                    session.setAttribute("flashMessage", "Thêm trái cây '" + name + "' thành công!");
                } else {
                    session.setAttribute("flashError", "Không thể thêm sản phẩm mới!");
                }

            } else if ("edit-product".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("productId"));
                String name = req.getParameter("productName");
                int categoryId = Integer.parseInt(req.getParameter("categoryId"));
                double price = Double.parseDouble(req.getParameter("price"));
                String unit = req.getParameter("unit");
                int stock = Integer.parseInt(req.getParameter("stockQuantity"));
                String imageUrl = req.getParameter("imageUrl");
                String description = req.getParameter("description");

                Product p = new Product(id, categoryId, name, price, unit, stock, imageUrl, description);
                boolean ok = productDao.updateProduct(p);
                if (ok) {
                    session.setAttribute("flashMessage", "Cập nhật sản phẩm #" + id + " thành công!");
                } else {
                    session.setAttribute("flashError", "Cập nhật sản phẩm thất bại!");
                }

            } else if ("toggle-status".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("productId"));
                boolean currentStatus = Boolean.parseBoolean(req.getParameter("currentStatus"));
                boolean ok = productDao.toggleProductStatus(id, currentStatus);
                if (ok) {
                    session.setAttribute("flashMessage", "Đã cập nhật trạng thái kinh doanh của sản phẩm #" + id);
                } else {
                    session.setAttribute("flashError", "Không thể đổi trạng thái sản phẩm!");
                }

            } else if ("delete-product".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("productId"));
                boolean ok = productDao.deleteProduct(id);
                if (ok) {
                    session.setAttribute("flashMessage", "Đã xóa sản phẩm #" + id + " thành công!");
                } else {
                    session.setAttribute("flashError", "Không thể xóa sản phẩm do đang có trong đơn hàng!");
                }

            } else if ("add-category".equalsIgnoreCase(action)) {
                String catName = req.getParameter("categoryName");
                if (categoryDao.addCategory(catName)) {
                    session.setAttribute("flashMessage", "Thêm danh mục '" + catName + "' thành công!");
                } else {
                    session.setAttribute("flashError", "Không thể thêm danh mục mới!");
                }

            } else if ("edit-category".equalsIgnoreCase(action)) {
                int catId = Integer.parseInt(req.getParameter("categoryId"));
                String catName = req.getParameter("categoryName");
                if (categoryDao.updateCategory(catId, catName)) {
                    session.setAttribute("flashMessage", "Cập nhật danh mục #" + catId + " thành công!");
                } else {
                    session.setAttribute("flashError", "Không thể cập nhật danh mục!");
                }

            } else if ("delete-category".equalsIgnoreCase(action)) {
                int catId = Integer.parseInt(req.getParameter("categoryId"));
                if (categoryDao.deleteCategory(catId)) {
                    session.setAttribute("flashMessage", "Xóa danh mục #" + catId + " thành công!");
                } else {
                    session.setAttribute("flashError", "Không thể xóa danh mục!");
                }
            }
        } catch (Exception e) {
            session.setAttribute("flashError", "Lỗi dữ liệu đầu vào: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }
}
