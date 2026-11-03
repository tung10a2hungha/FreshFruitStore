<%-- 
    Document   : payment
    Description: Màn hình Thanh Toán Chuyển Khoản Qua Mã VietQR (Bước 5)
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán VietQR - Đơn Hàng #${order.orderId}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-5 pb-5">
        <div class="card border-0 shadow-sm p-4 p-md-5 rounded-4 bg-white mx-auto" style="max-width: 860px;">
            <div class="text-center mb-4">
                <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-1 mb-2">
                    <i class="bi bi-qr-code me-1"></i>Thanh Toán Không Tiền Mặt
                </span>
                <h2 class="fw-bold text-dark">Quét Mã VietQR Để Thanh Toán</h2>
                <p class="text-secondary small mb-0">
                    Sử dụng ứng dụng ngân hàng hoặc ví điện tử (MoMo, ZaloPay, ViettelPay...) để quét mã bên dưới.
                </p>
            </div>

            <div class="row g-4 align-items-center">
                <!-- Cột Trái: Ảnh Mã QR tự sinh động -->
                <div class="col-md-5 text-center">
                    <div class="p-3 bg-white rounded-4 border shadow-sm d-inline-block">
                        <img src="${qrUrl}" 
                             alt="Mã QR Thanh Toán" 
                             class="img-fluid rounded-3" 
                             style="max-width: 280px; width: 100%;">
                        <div class="small text-secondary mt-2">
                            <i class="bi bi-camera me-1"></i>Quét mã để tự động điền số tiền & nội dung
                        </div>
                    </div>
                </div>

                <!-- Cột Phải: Thông tin chuyển khoản chi tiết -->
                <div class="col-md-7">
                    <div class="bg-light p-4 rounded-4 border mb-4">
                        <h6 class="fw-bold text-success mb-3">
                            <i class="bi bi-bank2 me-2"></i>Thông Tin Chuyển Khoản Chính Xác
                        </h6>

                        <div class="d-flex justify-content-between border-bottom pb-2 mb-2 small">
                            <span class="text-secondary">Ngân hàng thụ hưởng:</span>
                            <span class="fw-bold text-dark">${bankId} - Ngân Hàng Quân Đội (MB Bank)</span>
                        </div>

                        <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2 small">
                            <span class="text-secondary">Số tài khoản:</span>
                            <div class="d-flex align-items-center gap-2">
                                <span class="fw-bold text-primary fs-6" id="accNoText">${accountNo}</span>
                                <button type="button" class="btn btn-outline-secondary btn-sm py-0 px-2" onclick="copyText('accNoText', this)">
                                    <i class="bi bi-clipboard"></i> Sao chép
                                </button>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between border-bottom pb-2 mb-2 small">
                            <span class="text-secondary">Chủ tài khoản:</span>
                            <span class="fw-bold text-dark">${accountName}</span>
                        </div>

                        <div class="d-flex justify-content-between border-bottom pb-2 mb-2 small">
                            <span class="text-secondary">Số tiền thanh toán:</span>
                            <span class="fw-bold text-danger fs-5">
                                <fmt:formatNumber value="${order.totalAmount}" pattern="#,###" /> đ
                            </span>
                        </div>

                        <div class="d-flex justify-content-between align-items-center small">
                            <span class="text-secondary">Nội dung chuyển khoản:</span>
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge bg-warning text-dark fs-6 px-3 py-2" id="addInfoText">${addInfo}</span>
                                <button type="button" class="btn btn-outline-secondary btn-sm py-0 px-2" onclick="copyText('addInfoText', this)">
                                    <i class="bi bi-clipboard"></i> Sao chép
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Form xác nhận đã chuyển khoản -->
                    <form action="${pageContext.request.contextPath}/payment" method="post">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-secondary">
                                Mã tham chiếu giao dịch trên app ngân hàng (Không bắt buộc)
                            </label>
                            <input type="text" name="transactionRef" class="form-control" placeholder="Ví dụ: FT2411048899...">
                        </div>

                        <button type="submit" class="btn btn-success btn-lg w-100 rounded-pill py-3 fw-bold shadow-sm mb-2">
                            <i class="bi bi-check-circle-fill me-2"></i>Tôi Đã Chuyển Khoản Thành Công
                        </button>
                    </form>

                    <div class="text-center mt-3">
                        <a href="${pageContext.request.contextPath}/order-success?orderId=${order.orderId}" class="small text-secondary text-decoration-none">
                            <i class="bi bi-clock-history me-1"></i>Thanh toán sau / Xem chi tiết đơn hàng
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function copyText(elementId, btn) {
            const el = document.getElementById(elementId);
            if (!el) return;
            const text = el.innerText.trim();
            navigator.clipboard.writeText(text).then(() => {
                const originalHtml = btn.innerHTML;
                btn.classList.remove('btn-outline-secondary');
                btn.classList.add('btn-success');
                btn.innerHTML = '<i class="bi bi-check2"></i> Đã chép';
                setTimeout(() => {
                    btn.classList.remove('btn-success');
                    btn.classList.add('btn-outline-secondary');
                    btn.innerHTML = originalHtml;
                }, 1500);
            }).catch(err => {
                alert('Số tài khoản / Nội dung: ' + text);
            });
        }
    </script>
</body>
</html>
