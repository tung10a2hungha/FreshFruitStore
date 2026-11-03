package controller;

import dal.CategoryDAO;
import dal.ProductDAO;
import model.Category;
import model.Product;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ShopController extends HttpServlet {

    private static final int PAGE_SIZE = 8; // 8 sản phẩm mỗi trang

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 1. Nhận các tham số Lọc & Tìm kiếm
        String categoryIdRaw = req.getParameter("categoryId");
        String keyword = req.getParameter("keyword");
        String pageRaw = req.getParameter("page");

        Integer categoryId = null;
        if (categoryIdRaw != null && !categoryIdRaw.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdRaw.trim());
            } catch (NumberFormatException ignored) {}
        }

        int currentPage = 1;
        if (pageRaw != null && !pageRaw.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageRaw.trim());
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException ignored) {}
        }

        // 2. Khởi tạo DAO
        CategoryDAO catDao = new CategoryDAO();
        ProductDAO prodDao = new ProductDAO();

        // 3. Lấy dữ liệu
        List<Category> listCategory = catDao.getAllCategories();
        int totalProducts = prodDao.countProducts(categoryId, keyword);
        int totalPages = (int) Math.ceil((double) totalProducts / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        List<Product> listProduct = prodDao.getProducts(categoryId, keyword, currentPage, PAGE_SIZE);

        // 4. Đẩy dữ liệu ra view shop.jsp
        req.setAttribute("listCategory", listCategory);
        req.setAttribute("listProduct", listProduct);
        req.setAttribute("selectedCategory", categoryId);
        req.setAttribute("keyword", keyword);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalProducts", totalProducts);

        req.getRequestDispatcher("/shop.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
