package controller;

import dal.ProductDAO;
import model.Cart;
import model.Product;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class CartController extends HttpServlet {

    private Cart getCartFromSession(HttpSession session) {
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        HttpSession session = req.getSession();
        Cart cart = getCartFromSession(session);

        if (path != null && path.startsWith("/add")) {
            doPost(req, resp);
            return;
        } else if (path != null && path.startsWith("/remove")) {
            // Xóa sản phẩm khỏi giỏ: /cart/remove?productId=...
            String pidRaw = req.getParameter("productId");
            if (pidRaw != null) {
                try {
                    int pid = Integer.parseInt(pidRaw.trim());
                    cart.removeItem(pid);
                    session.setAttribute("flashCartMessage", "Đã xóa sản phẩm khỏi giỏ hàng!");
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;

        } else if (path != null && path.startsWith("/clear")) {
            // Xóa toàn bộ giỏ: /cart/clear
            cart.clear();
            session.setAttribute("flashCartMessage", "Đã xóa toàn bộ giỏ hàng!");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        // Mặc định: Hiển thị trang giỏ hàng /cart
        Object flashMsg = session.getAttribute("flashCartMessage");
        Object flashErr = session.getAttribute("flashCartError");
        if (flashMsg != null) {
            req.setAttribute("cartMessage", flashMsg);
            session.removeAttribute("flashCartMessage");
        }
        if (flashErr != null) {
            req.setAttribute("cartError", flashErr);
            session.removeAttribute("flashCartError");
        }

        req.getRequestDispatcher("/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo();
        HttpSession session = req.getSession();
        Cart cart = getCartFromSession(session);
        ProductDAO prodDao = new ProductDAO();

        if (path != null && path.startsWith("/add")) {
            // Thêm sản phẩm vào giỏ: /cart/add
            String pidRaw = req.getParameter("productId");
            String qtyRaw = req.getParameter("quantity");

            try {
                int pid = Integer.parseInt(pidRaw.trim());
                int qty = 1;
                if (qtyRaw != null && !qtyRaw.trim().isEmpty()) {
                    qty = Integer.parseInt(qtyRaw.trim());
                    if (qty < 1) qty = 1;
                }

                Product p = prodDao.getProductById(pid);
                if (p == null) {
                    session.setAttribute("flashCartError", "Sản phẩm không tồn tại!");
                } else if (p.getStockQuantity() <= 0) {
                    session.setAttribute("flashCartError", "Sản phẩm '" + p.getProductName() + "' hiện đã tạm hết hàng!");
                } else {
                    boolean ok = cart.addItem(p, qty);
                    if (ok) {
                        session.setAttribute("flashCartMessage", "Đã thêm " + qty + " " + p.getUnit() + " '" + p.getProductName() + "' vào giỏ hàng thành công!");
                    } else {
                        session.setAttribute("flashCartError", "Không thể thêm sản phẩm do vượt quá tồn kho!");
                    }
                }
            } catch (Exception e) {
                session.setAttribute("flashCartError", "Lỗi dữ liệu giỏ hàng: " + e.getMessage());
            }

            resp.sendRedirect(req.getContextPath() + "/cart");
            return;

        } else if (path != null && path.startsWith("/update")) {
            // Cập nhật số lượng mặt hàng trong giỏ: /cart/update
            String pidRaw = req.getParameter("productId");
            String qtyRaw = req.getParameter("quantity");

            try {
                int pid = Integer.parseInt(pidRaw.trim());
                int qty = Integer.parseInt(qtyRaw.trim());

                Product p = prodDao.getProductById(pid);
                int maxStock = (p != null) ? p.getStockQuantity() : 999;

                cart.updateQuantity(pid, qty, maxStock);
                session.setAttribute("flashCartMessage", "Đã cập nhật số lượng giỏ hàng!");
            } catch (Exception e) {
                session.setAttribute("flashCartError", "Số lượng không hợp lệ!");
            }

            resp.sendRedirect(req.getContextPath() + "/cart");
            return;

        } else if (path != null && path.startsWith("/remove")) {
            // Hỗ trợ xóa qua POST
            String pidRaw = req.getParameter("productId");
            if (pidRaw != null) {
                try {
                    int pid = Integer.parseInt(pidRaw.trim());
                    cart.removeItem(pid);
                    session.setAttribute("flashCartMessage", "Đã xóa sản phẩm khỏi giỏ hàng!");
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        // Nếu không khớp action nào, quay về trang giỏ hàng
        resp.sendRedirect(req.getContextPath() + "/cart");
    }
}
