<%-- 
    Document   : checkout
    Description: Trang Nhập Thông Tin Nhận Hàng & Thanh Toán Đơn Hàng (COD / VietQR)
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán Đơn Hàng - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-4 pb-5">
        <h2 class="mb-4 text-success fw-bold">
            <i class="bi bi-credit-card-2-front me-2"></i>Thông Tin Đặt Hàng & Thanh Toán
        </h2>

        <c:choose>
            <%-- Nếu giỏ hàng trống, không cho checkout --%>
            <c:when test="${empty sessionScope.cart || empty sessionScope.cart.items}">
                <div class="card border-0 shadow-sm p-5 text-center rounded-4 bg-white">
                    <div class="text-secondary fs-1 mb-3"><i class="bi bi-cart-x"></i></div>
                    <h4 class="fw-bold text-dark">Chưa có sản phẩm nào trong giỏ hàng!</h4>
                    <p class="text-secondary mb-4">Vui lòng chọn mua hoa quả trước khi tiến hành thanh toán đơn hàng.</p>
                    <div>
                        <a href="${pageContext.request.contextPath}/shop" class="btn btn-success btn-lg px-4 rounded-pill">
                            <i class="bi bi-shop me-2"></i>Xem Cửa Hàng Hoa Quả
                        </a>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <div class="row g-4">
                    <!-- Cột Trái: Form thông tin giao hàng & Phương thức thanh toán -->
                    <div class="col-lg-7">
                        <div class="card border-0 shadow-sm p-4 rounded-4 bg-white">
                            <h5 class="fw-bold text-success mb-3">
                                <i class="bi bi-geo-alt-fill me-2"></i>Địa Chỉ Nhận Hàng
                            </h5>

                            <form action="${pageContext.request.contextPath}/checkout" method="post">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Họ và tên người nhận <span class="text-danger">*</span></label>
                                        <input type="text" name="receiverName" value="${not empty sessionScope.account.fullName ? sessionScope.account.fullName : ''}" class="form-control" placeholder="Ví dụ: Nguyễn Văn A" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                                        <input type="text" name="receiverPhone" value="${not empty sessionScope.account.phone ? sessionScope.account.phone : ''}" class="form-control" placeholder="Ví dụ: 0912345678" required>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Địa chỉ giao hàng chi tiết <span class="text-danger">*</span></label>
                                        <textarea name="shippingAddress" class="form-control" rows="3" placeholder="Số nhà, ngõ/ngách, tên đường, Phường/Xã, Quận/Huyện..." required>${not empty sessionScope.account.address ? sessionScope.account.address : ''}</textarea>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Ghi chú giao hàng (Tùy chọn)</label>
                                        <textarea name="orderNote" class="form-control" rows="2" placeholder="Ví dụ: Giao giờ hành chính, gọi trước khi giao 15 phút..."></textarea>
                                    </div>
                                </div>

                                <hr class="my-4">

                                <h5 class="fw-bold text-success mb-3">
                                    <i class="bi bi-wallet2 me-2"></i>Phương Thức Thanh Toán
                                </h5>

                                <div class="form-check p-3 border rounded-3 mb-2 bg-light">
                                    <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethod" id="payCOD" value="COD" checked>
                                    <label class="form-check-label fw-semibold" for="payCOD">
                                        <i class="bi bi-cash-stack text-success me-1"></i>Thanh toán khi nhận hàng (COD)
                                    </label>
                                    <div class="small text-secondary ms-4">Nhận hoa quả tươi tận tay, kiểm tra chất lượng rồi mới thanh toán tiền mặt cho shipper.</div>
                                </div>

                                <div class="form-check p-3 border rounded-3 mb-4 bg-light">
                                    <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethod" id="payQR" value="BANK_TRANSFER">
                                    <label class="form-check-label fw-semibold" for="payQR">
                                        <i class="bi bi-qr-code-scan text-primary me-1"></i>Chuyển khoản qua mã VietQR / VNPay
                                    </label>
                                    <div class="small text-secondary ms-4">Quét mã QR tự động điền sẵn số tiền và mã đơn hàng qua ứng dụng ngân hàng.</div>
                                </div>

                                <button type="submit" class="btn btn-success btn-lg w-100 rounded-pill py-3 fw-bold shadow-sm">
                                    <i class="bi bi-bag-check-fill me-2"></i>Xác Nhận Đặt Hàng (<fmt:formatNumber value="${sessionScope.cart.totalAmount}" pattern="#,###" /> đ)
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Cột Phải: Tóm tắt các mặt hàng trong giỏ -->
                    <div class="col-lg-5">
                        <div class="card border-0 shadow-sm p-4 rounded-4 bg-white sticky-top" style="top: 90px;">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="fw-bold text-dark mb-0">Đơn Hàng (${sessionScope.cart.totalQuantity} món)</h5>
                                <a href="${pageContext.request.contextPath}/cart" class="small text-success text-decoration-none">Sửa giỏ hàng</a>
                            </div>

                            <div class="table-responsive" style="max-height: 280px; overflow-y: auto;">
                                <table class="table table-sm align-middle mb-0">
                                    <tbody>
                                        <c:forEach items="${sessionScope.cart.items}" var="item">
                                            <tr>
                                                <td style="width: 50px;">
                                                    <img src="${item.imageUrl}" 
                                                         alt="${item.productName}" 
                                                         class="rounded-2 border" 
                                                         style="width: 44px; height: 44px; object-fit: cover;"
                                                         onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=100&q=80';">
                                                </td>
                                                <td>
                                                    <div class="fw-semibold text-dark small">${item.productName}</div>
                                                    <small class="text-secondary">${item.quantity} ${item.unit} x <fmt:formatNumber value="${item.unitPrice}" pattern="#,###" /> đ</small>
                                                </td>
                                                <td class="text-end fw-bold text-danger small">
                                                    <fmt:formatNumber value="${item.subTotal}" pattern="#,###" /> đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <hr class="my-3">

                            <div class="d-flex justify-content-between mb-2 small">
                                <span class="text-secondary">Tạm tính:</span>
                                <span class="fw-bold text-dark">
                                    <fmt:formatNumber value="${sessionScope.cart.totalAmount}" pattern="#,###" /> đ
                                </span>
                            </div>
                            <div class="d-flex justify-content-between mb-3 small">
                                <span class="text-secondary">Phí giao hàng:</span>
                                <span class="text-success fw-semibold">Miễn phí</span>
                            </div>

                            <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                <span class="fw-bold text-dark">Tổng cộng:</span>
                                <span class="text-danger fw-bold fs-4">
                                    <fmt:formatNumber value="${sessionScope.cart.totalAmount}" pattern="#,###" /> đ
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</body>
</html>
