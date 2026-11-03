<%-- 
    Document   : cart
    Description: Trang Giỏ Hàng Mua Sắm (Shopping Cart - Session) - Bước 2
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ Hàng - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-4 pb-5">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <div>
                <h2 class="fw-bold text-success mb-1">
                    <i class="bi bi-cart3 me-2"></i>Giỏ Hàng Của Bạn
                </h2>
                <p class="text-secondary small mb-0">Kiểm tra danh sách hoa quả, điều chỉnh số lượng trước khi đặt hàng.</p>
            </div>
            <a href="${pageContext.request.contextPath}/shop" class="btn btn-outline-success rounded-pill px-4">
                <i class="bi bi-arrow-left me-1"></i>Tiếp tục chọn hoa quả
            </a>
        </div>

        <!-- Thông báo giỏ hàng (Flash Messages) -->
        <c:if test="${not empty cartMessage}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm rounded-3" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${cartMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty cartError}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm rounded-3" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${cartError}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:choose>
            <%-- TRƯỜNG HỢP 1: GIỎ HÀNG TRỐNG --%>
            <c:when test="${empty sessionScope.cart || empty sessionScope.cart.items}">
                <div class="card border-0 shadow-sm p-5 text-center rounded-4 bg-white my-4">
                    <div class="mx-auto mb-3 text-secondary" style="font-size: 4rem;">
                        <i class="bi bi-cart-x"></i>
                    </div>
                    <h4 class="fw-bold text-dark mb-2">Giỏ hàng của bạn đang trống</h4>
                    <p class="text-secondary mb-4">Hãy dạo quanh cửa hàng và chọn những loại hoa quả tươi ngon nhất nhé!</p>
                    <div>
                        <a href="${pageContext.request.contextPath}/shop" class="btn btn-success btn-lg px-5 rounded-pill shadow-sm">
                            <i class="bi bi-basket2 me-2"></i>Khám Phá Cửa Hàng Ngay
                        </a>
                    </div>
                </div>
            </c:when>

            <%-- TRƯỜNG HỢP 2: CÓ SẢN PHẨM TRONG GIỎ HÀNG --%>
            <c:otherwise>
                <div class="row g-4">
                    <!-- Cột Trái: Bảng danh sách các mặt hàng trong giỏ -->
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm p-4 rounded-4 bg-white">
                            <div class="table-responsive">
                                <table class="table align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Sản phẩm</th>
                                            <th>Đơn giá</th>
                                            <th style="width: 170px;">Số lượng</th>
                                            <th class="text-end">Thành tiền</th>
                                            <th class="text-center" style="width: 50px;"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${sessionScope.cart.items}" var="item">
                                            <tr>
                                                <!-- Thông tin sản phẩm -->
                                                <td>
                                                    <div class="d-flex align-items-center gap-3">
                                                        <img src="${item.imageUrl}" 
                                                             alt="${item.productName}" 
                                                             class="rounded-3 shadow-sm border" 
                                                             style="width: 64px; height: 64px; object-fit: cover;"
                                                             onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=100&q=80';">
                                                        <div>
                                                            <h6 class="fw-bold mb-1">
                                                                <a href="${pageContext.request.contextPath}/product-detail?id=${item.productId}" class="text-dark text-decoration-none">
                                                                    ${item.productName}
                                                                </a>
                                                            </h6>
                                                            <small class="text-secondary">Đơn vị: ${item.unit}</small>
                                                        </div>
                                                    </div>
                                                </td>

                                                <!-- Đơn giá -->
                                                <td class="text-secondary fw-semibold">
                                                    <fmt:formatNumber value="${item.unitPrice}" pattern="#,###" /> đ
                                                </td>

                                                <!-- Form cập nhật số lượng -->
                                                <td>
                                                    <form action="${pageContext.request.contextPath}/cart/update" method="post" class="d-flex align-items-center gap-1">
                                                        <input type="hidden" name="productId" value="${item.productId}">
                                                        <div class="input-group input-group-sm" style="width: 120px;">
                                                            <input type="number" 
                                                                   name="quantity" 
                                                                   value="${item.quantity}" 
                                                                   min="1" 
                                                                   max="${item.stockQuantity}" 
                                                                   class="form-control text-center" 
                                                                   required>
                                                            <span class="input-group-text">${item.unit}</span>
                                                        </div>
                                                        <button type="submit" class="btn btn-outline-success btn-sm" title="Lưu số lượng">
                                                            <i class="bi bi-check-lg"></i>
                                                        </button>
                                                    </form>
                                                </td>

                                                <!-- Thành tiền từng món -->
                                                <td class="text-end text-danger fw-bold fs-6">
                                                    <fmt:formatNumber value="${item.subTotal}" pattern="#,###" /> đ
                                                </td>

                                                <!-- Nút xóa món -->
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/cart/remove?productId=${item.productId}" 
                                                       class="text-danger fs-5" 
                                                       title="Xóa món này" 
                                                       onclick="return confirm('Bạn có muốn bỏ sản phẩm này khỏi giỏ hàng?');">
                                                        <i class="bi bi-trash3"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                                <a href="${pageContext.request.contextPath}/cart/clear" 
                                   class="btn btn-outline-danger btn-sm rounded-pill px-3" 
                                   onclick="return confirm('Bạn có chắc muốn xóa toàn bộ giỏ hàng?');">
                                    <i class="bi bi-trash me-1"></i>Xóa toàn bộ giỏ
                                </a>
                                <a href="${pageContext.request.contextPath}/shop" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                                    <i class="bi bi-plus-circle me-1"></i>Thêm hoa quả khác
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Cột Phải: Tóm tắt đơn hàng (Order Summary) -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm p-4 rounded-4 bg-white sticky-top" style="top: 90px;">
                            <h5 class="fw-bold text-dark mb-3">Tóm Tắt Đơn Hàng</h5>

                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-secondary">Tổng số lượng hoa quả:</span>
                                <span class="fw-bold text-dark">${sessionScope.cart.totalQuantity} món</span>
                            </div>

                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-secondary">Tạm tính:</span>
                                <span class="fw-bold text-dark">
                                    <fmt:formatNumber value="${sessionScope.cart.totalAmount}" pattern="#,###" /> đ
                                </span>
                            </div>

                            <div class="d-flex justify-content-between mb-3 pb-3 border-bottom">
                                <span class="text-secondary">Phí vận chuyển:</span>
                                <span class="text-success fw-semibold">Miễn phí giao hàng</span>
                            </div>

                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <span class="fw-bold fs-6 text-dark">Tổng thanh toán:</span>
                                <span class="text-danger fw-bold display-6" style="font-size: 1.75rem;">
                                    <fmt:formatNumber value="${sessionScope.cart.totalAmount}" pattern="#,###" /> đ
                                </span>
                            </div>

                            <a href="${pageContext.request.contextPath}/checkout.jsp" class="btn btn-success btn-lg w-100 rounded-pill py-3 shadow-sm fw-bold">
                                <i class="bi bi-credit-card-2-front me-2"></i>Tiến Hành Thanh Toán
                            </a>

                            <div class="mt-4 p-3 bg-light rounded-3 text-secondary small">
                                <div class="mb-1"><i class="bi bi-shield-check text-success me-2"></i>Cam kết trái cây tươi sạch VietGAP 100%.</div>
                                <div><i class="bi bi-truck text-success me-2"></i>Giao nhanh hỏa tốc trong 2 giờ nội thành.</div>
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
