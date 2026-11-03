<%-- 
    Document   : index
    Description: Trang chủ động (JSP) giữ nguyên trạng thái đăng nhập Session của Khách hàng & Admin
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Nạp top 4 sản phẩm nổi bật hiển thị ngay trang chủ
    dal.ProductDAO homeProductDao = new dal.ProductDAO();
    java.util.List<model.Product> homeFeatured = homeProductDao.getFeaturedProducts(4);
    request.setAttribute("featuredProducts", homeFeatured);
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>FreshFruit Store - Trái Cây Tươi Sạch Mỗi Ngày</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    </head>
    <body>
        <!-- Dùng chung Header JSP để luôn giữ phiên đăng nhập (Session) -->
        <jsp:include page="/includes/header.jsp" />

        <!-- Hero Section -->
        <section class="container mt-4">
            <div class="ff-hero shadow-sm">
                <div class="row align-items-center g-4">
                    <div class="col-lg-7">
                        <div class="ff-hero-badge mb-3">
                            <i class="bi bi-stars text-warning"></i>
                            <span>Trái cây tươi thu hoạch mỗi sáng - 100% VietGAP</span>
                        </div>
                        <h1 class="display-5 fw-bold text-dark mb-3">
                            Vị Ngọt Tự Nhiên Cho <span class="text-success">Sức Khỏe Gia Đình</span> Bạn
                        </h1>
                        <p class="lead text-secondary mb-4">
                            FreshFruit Store cung ứng và phân phối hoa quả tươi trực tuyến. Chọn hoa quả nhanh chóng, thanh toán tiện lợi qua COD hoặc chuyển khoản VietQR.
                        </p>
                        <div class="d-flex flex-wrap gap-3">
                            <a href="${pageContext.request.contextPath}/shop" class="btn btn-success btn-lg px-4 py-3 rounded-pill shadow-sm">
                                <i class="bi bi-cart-plus me-2"></i>Mua Sắm Ngay
                            </a>
                            <c:choose>
                                <c:when test="${not empty sessionScope.account}">
                                    <a href="${pageContext.request.contextPath}/profile" class="btn btn-outline-success btn-lg px-4 py-3 rounded-pill bg-white">
                                        <i class="bi bi-person-vcard me-2"></i>Thông Tin Tài Khoản
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-success btn-lg px-4 py-3 rounded-pill bg-white">
                                        <i class="bi bi-box-arrow-in-right me-2"></i>Đăng Nhập
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="col-lg-5 text-center">
                        <img src="https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=900&q=80"
                             alt="Fresh Fruit Basket"
                             class="img-fluid rounded-4 shadow-lg border border-4 border-white"
                             style="max-height: 340px; width: 100%; object-fit: cover;">
                    </div>
                </div>
            </div>
        </section>

        <!-- Trái Cây Nổi Bật Mới Về (Hiển thị ngay trên Trang Chủ) -->
        <c:if test="${not empty featuredProducts}">
            <section class="container mt-5">
                <div class="d-flex justify-content-between align-items-end mb-4">
                    <div>
                        <span class="badge bg-success-subtle text-success px-3 py-2 rounded-pill mb-1">
                            <i class="bi bi-fire me-1"></i>Bán chạy nhất
                        </span>
                        <h3 class="fw-bold text-dark mb-0">Trái Cây Tươi Mới Về Hôm Nay</h3>
                    </div>
                    <a href="${pageContext.request.contextPath}/shop" class="btn btn-outline-success rounded-pill px-3">
                        Xem tất cả <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                </div>

                <div class="row row-cols-1 row-cols-md-4 g-4">
                    <c:forEach items="${featuredProducts}" var="fp">
                        <div class="col">
                            <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden bg-white">
                                <a href="${pageContext.request.contextPath}/product-detail?id=${fp.productId}">
                                    <img src="${fp.imageUrl}" 
                                         class="card-img-top" 
                                         alt="${fp.productName}"
                                         style="height: 180px; object-fit: cover;"
                                         onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=400&q=80';">
                                </a>
                                <div class="card-body p-3 text-center d-flex flex-column">
                                    <span class="badge bg-light text-secondary border mx-auto mb-2">${fp.categoryName}</span>
                                    <h6 class="fw-bold mb-1">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${fp.productId}" class="text-dark text-decoration-none">
                                            ${fp.productName}
                                        </a>
                                    </h6>
                                    <div class="text-danger fw-bold fs-6 my-1">
                                        <fmt:formatNumber value="${fp.price}" pattern="#,###" /> đ / ${fp.unit}
                                    </div>
                                    <div class="mt-auto pt-2 d-flex gap-2">
                                        <a href="${pageContext.request.contextPath}/product-detail?id=${fp.productId}" class="btn btn-outline-secondary btn-sm flex-grow-1 rounded-pill">
                                            Chi tiết
                                        </a>
                                        <form action="${pageContext.request.contextPath}/cart/add" method="post" class="flex-grow-1">
                                            <input type="hidden" name="productId" value="${fp.productId}">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="btn btn-success btn-sm w-100 rounded-pill">
                                                Mua
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </c:if>

        <!-- Cam kết dịch vụ -->
        <section class="container mt-5 mb-5">
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="card h-100 p-4 border-0 shadow-sm text-center bg-white rounded-4">
                        <div class="mx-auto mb-2 text-success fs-2"><i class="bi bi-award-fill"></i></div>
                        <h6 class="fw-bold mb-1">Hoa Quả Tươi Trong Ngày</h6>
                        <p class="small text-secondary mb-0">Đa dạng đơn vị tính linh hoạt theo kg, hộp hoặc combo.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 p-4 border-0 shadow-sm text-center bg-white rounded-4">
                        <div class="mx-auto mb-2 text-success fs-2"><i class="bi bi-qr-code-scan"></i></div>
                        <h6 class="fw-bold mb-1">Thanh Toán Nhanh Gọn</h6>
                        <p class="small text-secondary mb-0">Hỗ trợ tiền mặt khi nhận hàng (COD) và chuyển khoản QR.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 p-4 border-0 shadow-sm text-center bg-white rounded-4">
                        <div class="mx-auto mb-2 text-success fs-2"><i class="bi bi-lightning-charge-fill"></i></div>
                        <h6 class="fw-bold mb-1">Xác Nhận & Giao Nhanh</h6>
                        <p class="small text-secondary mb-0">Đơn hàng được tiếp nhận và xử lý đóng gói tức thì.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Dùng chung Footer JSP -->
        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
