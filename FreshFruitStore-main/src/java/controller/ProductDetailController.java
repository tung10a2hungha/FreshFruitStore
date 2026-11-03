package controller;

import dal.ProductDAO;
import model.Product;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ProductDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        try {
            int id = Integer.parseInt(idRaw.trim());
            ProductDAO dao = new ProductDAO();
            Product product = dao.getProductById(id);

            if (product == null) {
                resp.sendRedirect(req.getContextPath() + "/shop");
                return;
            }

            // Lấy thêm 4 sản phẩm liên quan cùng danh mục để gợi ý
            List<Product> relatedProducts = dao.getProducts(product.getCategoryId(), null, 1, 4);
            // Loại bỏ chính sản phẩm đang xem khỏi danh sách gợi ý
            relatedProducts.removeIf(p -> p.getProductId() == product.getProductId());

            req.setAttribute("product", product);
            req.setAttribute("relatedProducts", relatedProducts);
            req.getRequestDispatcher("/product-detail.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/shop");
        }
    }
}
