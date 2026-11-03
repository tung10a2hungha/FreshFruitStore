package controller;

import dal.OrderDAO;
import model.Order;
import model.Payment;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class PaymentController extends HttpServlet {

    // Cấu hình tài khoản ngân hàng nhận tiền VietQR (MB Bank)
    private static final String BANK_ID = "MB";
    private static final String ACCOUNT_NO = "0987654321";
    private static final String ACCOUNT_NAME = "CUA HANG FRESHFRUIT";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String oidRaw = req.getParameter("orderId");
        if (oidRaw == null || oidRaw.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        try {
            int orderId = Integer.parseInt(oidRaw.trim());
            OrderDAO dao = new OrderDAO();
            Order order = dao.getOrderById(orderId);

            if (order == null) {
                resp.sendRedirect(req.getContextPath() + "/shop");
                return;
            }

            // Sinh link ảnh mã VietQR tự động theo chuẩn VietQR API
            long amount = (long) order.getTotalAmount();
            String addInfo = "DH" + order.getOrderId();
            String qrUrl = "https://img.vietqr.io/image/" + BANK_ID + "-" + ACCOUNT_NO + "-compact2.jpg?amount=" + amount + "&addInfo=" + addInfo + "&accountName=" + ACCOUNT_NAME.replace(" ", "%20");

            Payment payment = dao.getPaymentByOrderId(orderId);

            req.setAttribute("order", order);
            req.setAttribute("payment", payment);
            req.setAttribute("qrUrl", qrUrl);
            req.setAttribute("bankId", BANK_ID);
            req.setAttribute("accountNo", ACCOUNT_NO);
            req.setAttribute("accountName", ACCOUNT_NAME);
            req.setAttribute("addInfo", addInfo);

            req.getRequestDispatcher("/payment.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/shop");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String oidRaw = req.getParameter("orderId");
        String transRef = req.getParameter("transactionRef");

        if (oidRaw != null) {
            try {
                int orderId = Integer.parseInt(oidRaw.trim());
                OrderDAO dao = new OrderDAO();
                // Khách hàng bấm xác nhận chuyển khoản
                dao.confirmCustomerTransfer(orderId, transRef);
                resp.sendRedirect(req.getContextPath() + "/order-success?orderId=" + orderId);
                return;
            } catch (NumberFormatException ignored) {}
        }

        resp.sendRedirect(req.getContextPath() + "/shop");
    }
}
