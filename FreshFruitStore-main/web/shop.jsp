<%-- 
    Document   : shop
    Description: Cửa hàng hoa quả tươi, lọc danh mục, tìm kiếm và phân trang
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Nếu người dùng truy cập trực tiếp shop.jsp mà chưa đi qua ShopController, tự nạp dữ liệu
    if (request.getAttribute("listProduct") == null) {
        request.getRequestDispatcher("/shop").forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cửa Hàng Hoa Quả Tươi - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <style>
        .product-card {
            border: 1px solid rgba(22, 163, 74, 0.15);
            border-radius: 16px;
            transition: transform 0.2s, box-shadow 0.2s;
            overflow: hidden;
            background: #fff;
        }
        .product-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 24px rgba(22, 163, 74, 0.12);
        }
        .product-img {
            height: 200px;
            object-fit: cover;
            width: 100%;
            transition: transform 0.3s;
        }
        .product-card:hover .product-img {
            transform: scale(1.04);
        }
        .cat-item.active {
            background-color: #16a34a !important;
            color: #fff !important;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-4">
        <!-- Banner đầu trang Cửa hàng -->
        <div class="bg-success text-white p-4 rounded-4 mb-4 shadow-sm" style="background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h2 class="fw-bold mb-1"><i class="bi bi-shop me-2"></i>Cửa Hàng Hoa Quả Tươi Sạch</h2>
                    <p class="mb-0 opacity-75">100% trái cây thu hoạch tự nhiên theo tiêu chuẩn VietGAP, tươi ngon trọn vị mỗi ngày.</p>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <span class="badge bg-light text-success px-3 py-2 rounded-pill fs-6">
                        <i class="bi bi-box-seam me-1"></i>Hiện có ${totalProducts} sản phẩm
                    </span>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- CỘT TRÁI: BỘ LỌC DANH MỤC & TÌM KIẾM -->
            <div class="col-lg-3">
                <!-- Thanh tìm kiếm -->
                <div class="card border-0 shadow-sm p-3 mb-4 rounded-4 bg-white">
                    <h6 class="fw-bold text-success mb-3"><i class="bi bi-search me-2"></i>Tìm kiếm trái cây</h6>
                    <form action="${pageContext.request.contextPath}/shop" method="get">
                        <c:if test="${not empty selectedCategory}">
                            <input type="hidden" name="categoryId" value="${selectedCategory}">
                        </c:if>
                        <div class="input-group">
                            <input type="text" name="keyword" value="${keyword}" class="form-control" placeholder="Táo, cam, xoài...">
                            <button class="btn btn-success" type="submit"><i class="bi bi-search"></i></button>
                        </div>
                    </form>
                </div>

                <!-- Danh mục sản phẩm -->
                <div class="card border-0 shadow-sm p-3 rounded-4 bg-white">
                    <h6 class="fw-bold text-success mb-3"><i class="bi bi-grid-fill me-2"></i>Danh mục trái cây</h6>
                    <div class="list-group list-group-flush">
                        <a href="${pageContext.request.contextPath}/shop?keyword=${keyword}" 
                           class="list-group-item list-group-item-action cat-item rounded-3 mb-1 ${empty selectedCategory ? 'active' : ''}">
                            <i class="bi bi-collection me-2"></i>Tất cả hoa quả
                        </a>
                        <c:forEach items="${listCategory}" var="c">
                            <a href="${pageContext.request.contextPath}/shop?categoryId=${c.categoryId}&keyword=${keyword}" 
                               class="list-group-item list-group-item-action cat-item rounded-3 mb-1 ${selectedCategory == c.categoryId ? 'active' : ''}">
                                <i class="bi bi-tag-fill me-2"></i>${c.categoryName}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <!-- CỘT PHẢI: LƯỚI SẢN PHẨM -->
            <div class="col-lg-9">
                <!-- Báo không có sản phẩm nếu tìm kiếm rỗng -->
                <c:if test="${empty listProduct}">
                    <div class="card border-0 shadow-sm p-5 text-center rounded-4 bg-white">
                        <div class="text-secondary fs-1 mb-3"><i class="bi bi-emoji-frown"></i></div>
                        <h5 class="fw-bold text-dark">Không tìm thấy sản phẩm phù hợp</h5>
                        <p class="text-muted small">Hãy thử tìm kiếm với từ khóa khác hoặc bấm chọn danh mục "Tất cả hoa quả".</p>
                        <div>
                            <a href="${pageContext.request.contextPath}/shop" class="btn btn-outline-success rounded-pill px-4">
                                <i class="bi bi-arrow-clockwise me-1"></i>Xem tất cả sản phẩm
                            </a>
                        </div>
                    </div>
                </c:if>

                <div class="row row-cols-1 row-cols-md-3 g-4">
                    <c:forEach items="${listProduct}" var="p">
                        <div class="col">
                            <div class="card product-card h-100 shadow-sm position-relative">
                                <!-- Badge danh mục -->
                                <c:if test="${not empty p.categoryName}">
                                    <span class="position-absolute top-0 start-0 m-2 badge bg-success-subtle text-success border border-success-subtle rounded-pill">
                                        ${p.categoryName}
                                    </span>
                                </c:if>

                                <!-- Ảnh sản phẩm -->
                                <a href="${pageContext.request.contextPath}/product-detail?id=${p.productId}" class="overflow-hidden d-block">
                                    <img src="${not empty p.imageUrl ? p.imageUrl : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=500&q=80'}" 
                                         class="product-img" 
                                         alt="${p.productName}"
                                         onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=500&q=80';">
                                </a>

                                <div class="card-body d-flex flex-column text-center p-3">
                                    <h6 class="card-title fw-bold mb-1">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${p.productId}" class="text-dark text-decoration-none">
                                            ${p.productName}
                                        </a>
                                    </h6>

                                    <div class="text-danger fw-bold fs-5 my-1">
                                        <fmt:formatNumber value="${p.price}" pattern="#,###" /> đ 
                                        <span class="text-secondary fw-normal fs-6">/ ${p.unit}</span>
                                    </div>

                                    <div class="small mb-3">
                                        <c:choose>
                                            <c:when test="${p.stockQuantity > 0}">
                                                <span class="text-success"><i class="bi bi-check-circle me-1"></i>Còn hàng (${p.stockQuantity} ${p.unit})</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-danger"><i class="bi bi-x-circle me-1"></i>Tạm hết hàng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="mt-auto d-flex gap-2">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${p.productId}" 
                                           class="btn btn-outline-secondary btn-sm flex-grow-1 rounded-pill">
                                            <i class="bi bi-eye"></i> Chi tiết
                                        </a>
                                        <form action="${pageContext.request.contextPath}/cart/add" method="post" class="flex-grow-1">
                                            <input type="hidden" name="productId" value="${p.productId}">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="btn btn-success btn-sm w-100 rounded-pill" ${p.stockQuantity <= 0 ? 'disabled' : ''}>
                                                <i class="bi bi-cart-plus"></i> Mua
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Phân trang (Pagination) -->
                <c:if test="${totalPages > 1}">
                    <nav class="mt-5">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/shop?page=${currentPage - 1}&categoryId=${selectedCategory}&keyword=${keyword}">
                                    <i class="bi bi-chevron-left"></i> Trang trước
                                </a>
                            </li>

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/shop?page=${i}&categoryId=${selectedCategory}&keyword=${keyword}">${i}</a>
                                </li>
                            </c:forEach>

                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/shop?page=${currentPage + 1}&categoryId=${selectedCategory}&keyword=${keyword}">
                                    Trang sau <i class="bi bi-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</body>
</html>
