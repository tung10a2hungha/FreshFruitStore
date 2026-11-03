<%-- 
    Document   : product-detail
    Description: Trang Chi Tiết Sản Phẩm Hoa Quả
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.productName} - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-4">
        <!-- Breadcrumb điều hướng -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/index.jsp" class="text-success text-decoration-none">Trang chủ</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/shop" class="text-success text-decoration-none">Cửa hàng</a></li>
                <c:if test="${not empty product.categoryName}">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/shop?categoryId=${product.categoryId}" class="text-success text-decoration-none">${product.categoryName}</a></li>
                </c:if>
                <li class="breadcrumb-item active" aria-current="page">${product.productName}</li>
            </ol>
        </nav>

        <!-- Thẻ chi tiết sản phẩm chính -->
        <div class="card border-0 shadow-sm p-4 p-md-5 rounded-4 bg-white mb-5">
            <div class="row g-5 align-items-center">
                <!-- Cột trái: Ảnh sản phẩm lớn -->
                <div class="col-md-6 text-center">
                    <img src="${not empty product.imageUrl ? product.imageUrl : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=600&q=80'}" 
                         alt="${product.productName}" 
                         class="img-fluid rounded-4 shadow-sm border border-2 border-light" 
                         style="max-height: 420px; width: 100%; object-fit: cover;"
                         onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=600&q=80';">
                </div>

                <!-- Cột phải: Thông tin & Đặt mua -->
                <div class="col-md-6">
                    <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2 rounded-pill mb-2">
                        <i class="bi bi-patch-check-fill me-1"></i>Tiêu chuẩn VietGAP 100%
                    </span>
                    <h2 class="fw-bold text-dark mb-2">${product.productName}</h2>
                    <p class="text-secondary small mb-3">Danh mục: <strong>${not empty product.categoryName ? product.categoryName : 'Trái cây sạch'}</strong></p>

                    <div class="p-3 bg-light rounded-3 mb-4">
                        <span class="text-secondary small d-block">Giá ưu đãi:</span>
                        <span class="text-danger fw-bold display-6">
                            <fmt:formatNumber value="${product.price}" pattern="#,###" /> đ
                        </span>
                        <span class="text-secondary fs-5"> / ${product.unit}</span>
                    </div>

                    <!-- Tồn kho -->
                    <div class="mb-4">
                        <c:choose>
                            <c:when test="${product.stockQuantity > 0}">
                                <div class="text-success fw-semibold">
                                    <i class="bi bi-box-seam me-2"></i>Hiện có sẵn <strong>${product.stockQuantity} ${product.unit}</strong> tại cửa hàng
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-danger fw-semibold">
                                    <i class="bi bi-x-circle me-2"></i>Tạm hết hàng (đang chờ thu hoạch đợt mới)
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Form thêm vào giỏ hàng -->
                    <form action="${pageContext.request.contextPath}/cart/add" method="post" class="mb-4">
                        <input type="hidden" name="productId" value="${product.productId}">
                        <div class="row g-3 align-items-center">
                            <div class="col-auto">
                                <label class="fw-semibold text-secondary">Số lượng:</label>
                            </div>
                            <div class="col-auto">
                                <div class="input-group" style="width: 140px;">
                                    <input type="number" name="quantity" value="1" min="1" max="${product.stockQuantity > 0 ? product.stockQuantity : 1}" class="form-control text-center" ${product.stockQuantity <= 0 ? 'disabled' : ''}>
                                    <span class="input-group-text">${product.unit}</span>
                                </div>
                            </div>
                            <div class="col-auto flex-grow-1">
                                <button type="submit" class="btn btn-success btn-lg w-100 rounded-pill shadow-sm" ${product.stockQuantity <= 0 ? 'disabled' : ''}>
                                    <i class="bi bi-cart-plus me-2"></i>Thêm Vào Giỏ Hàng
                                </button>
                            </div>
                        </div>
                    </form>

                    <!-- Cam kết dịch vụ nhanh -->
                    <div class="border-top pt-3 text-secondary small d-flex flex-column gap-2">
                        <div><i class="bi bi-check2-circle text-success me-2"></i>Giao nhanh trong 2 giờ tại nội thành Hà Nội.</div>
                        <div><i class="bi bi-arrow-repeat text-success me-2"></i>Đổi trả 1-1 miễn phí nếu phát hiện quả dập nát, không tươi.</div>
                        <div><i class="bi bi-qr-code text-success me-2"></i>Hỗ trợ thanh toán linh hoạt COD hoặc chuyển khoản VietQR.</div>
                    </div>
                </div>
            </div>

            <!-- Mô tả chi tiết -->
            <div class="border-top mt-5 pt-4">
                <h5 class="fw-bold text-success mb-3"><i class="bi bi-card-text me-2"></i>Mô tả chi tiết sản phẩm</h5>
                <div class="text-secondary lh-lg">
                    <c:choose>
                        <c:when test="${not empty product.description}">
                            <p>${product.description}</p>
                        </c:when>
                        <c:otherwise>
                            <p>Hoa quả tươi sạch loại 1 được FreshFruit tuyển chọn trực tiếp tại vườn theo quy trình chuẩn nông nghiệp sạch VietGAP. Quả to đều, độ ngọt đậm đà, giữ trọn vi chất và vitamin tự nhiên cho gia đình bạn.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Sản phẩm tương tự cùng danh mục -->
        <c:if test="${not empty relatedProducts}">
            <div class="mb-5">
                <h4 class="fw-bold text-success mb-4"><i class="bi bi-stars me-2"></i>Có thể bạn cũng thích</h4>
                <div class="row row-cols-1 row-cols-md-4 g-4">
                    <c:forEach items="${relatedProducts}" var="rp">
                        <div class="col">
                            <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden">
                                <a href="${pageContext.request.contextPath}/product-detail?id=${rp.productId}">
                                    <img src="${not empty rp.imageUrl ? rp.imageUrl : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=400&q=80'}" 
                                         class="card-img-top" 
                                         alt="${rp.productName}"
                                         style="height: 160px; object-fit: cover;">
                                </a>
                                <div class="card-body text-center p-3 d-flex flex-column">
                                    <h6 class="fw-bold mb-1">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${rp.productId}" class="text-dark text-decoration-none">
                                            ${rp.productName}
                                        </a>
                                    </h6>
                                    <div class="text-danger fw-bold my-1">
                                        <fmt:formatNumber value="${rp.price}" pattern="#,###" /> đ / ${rp.unit}
                                    </div>
                                    <div class="mt-auto pt-2">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${rp.productId}" class="btn btn-outline-success btn-sm rounded-pill w-100">
                                            Xem chi tiết
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</body>
</html>
