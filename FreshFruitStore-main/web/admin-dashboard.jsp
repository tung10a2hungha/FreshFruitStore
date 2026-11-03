<%-- 
    Document   : admin-dashboard
    Description: Báo Cáo Thống Kê & Bảng Điều Khiển Quản Trị Trung Tâm (Bước 6)
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Tự động chuyển hướng qua Servlet AdminDashboardController nếu truy cập trực tiếp file JSP
    if (request.getAttribute("totalOrders") == null) {
        request.getRequestDispatcher("/admin/dashboard").forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Thống Kê Báo Cáo FreshFruit</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <!-- Navbar Admin đồng bộ -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/admin/dashboard">
                <span class="badge bg-success p-2"><i class="bi bi-basket2-fill"></i></span>
                <span>FreshFruit Admin Dashboard</span>
            </a>
            <div class="navbar-nav me-auto ms-4 gap-2">
                <a class="nav-link active fw-bold text-success" href="${pageContext.request.contextPath}/admin/dashboard">
                    <i class="bi bi-speedometer2 me-1"></i>Tổng quan
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/admin/orders">
                    <i class="bi bi-receipt me-1"></i>Quản lý Đơn hàng
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/admin/products">
                    <i class="bi bi-apple me-1"></i>Quản lý Sản phẩm
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/admin/users">
                    <i class="bi bi-people-fill me-1"></i>Quản lý Tài khoản
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/shop">
                    <i class="bi bi-shop me-1"></i>Xem Cửa hàng
                </a>
            </div>
            <div class="d-flex align-items-center gap-3">
                <span class="text-light small">
                    <i class="bi bi-shield-check text-success me-1"></i>Admin: <strong>${sessionScope.account.username}</strong>
                </span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Đăng xuất</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid px-4 pb-5">
        <!-- Tiêu đề trang Dashboard -->
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
            <div>
                <h3 class="fw-bold text-dark mb-1">
                    <i class="bi bi-graph-up-arrow text-success me-2"></i>Báo Cáo Hoạt Động & Doanh Thu
                </h3>
                <p class="text-secondary small mb-0">
                    Số liệu kinh doanh thời gian thực từ cửa hàng hoa quả tươi trực tuyến FreshFruit Store.
                </p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-success rounded-pill px-3 shadow-sm">
                    <i class="bi bi-receipt me-1"></i>Xử Lý Đơn Hàng (${pendingOrders})
                </a>
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline-dark rounded-pill px-3">
                    <i class="bi bi-plus-circle me-1"></i>Thêm Trái Cây Mới
                </a>
            </div>
        </div>

        <!-- Cảnh báo nếu có mặt hàng sắp hết hàng trong kho -->
        <c:if test="${lowStockCount > 0}">
            <div class="alert alert-warning border-warning border-opacity-50 shadow-sm rounded-4 d-flex align-items-center justify-content-between mb-4 py-3" role="alert">
                <div class="d-flex align-items-center gap-3">
                    <i class="bi bi-exclamation-triangle-fill fs-3 text-warning"></i>
                    <div>
                        <div class="fw-bold text-dark">Cảnh Báo Tồn Kho Thấp!</div>
                        <div class="small text-secondary">
                            Có <strong>${lowStockCount} sản phẩm</strong> đang có số lượng tồn kho còn dưới hoặc bằng 10 kg/hộp.
                        </div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-warning btn-sm text-dark fw-bold rounded-pill px-3">
                    Kiểm tra kho ngay
                </a>
            </div>
        </c:if>

        <!-- 4 Thẻ KPI Chỉ Số Chính -->
        <div class="row g-3 mb-4">
            <!-- Thẻ 1: Tổng Doanh Thu -->
            <div class="col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm p-4 bg-white rounded-4 h-100">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="text-secondary small fw-semibold">Tổng Doanh Thu</span>
                        <span class="badge bg-success-subtle text-success p-2 rounded-3">
                            <i class="bi bi-cash-stack fs-5"></i>
                        </span>
                    </div>
                    <h3 class="fw-bold text-danger mb-1">
                        <fmt:formatNumber value="${totalRevenue}" pattern="#,###" /> đ
                    </h3>
                    <div class="small text-success">
                        <i class="bi bi-check-circle-fill me-1"></i>Đơn hoàn thành & đã thanh toán
                    </div>
                </div>
            </div>

            <!-- Thẻ 2: Đơn Hàng Chờ Xử Lý -->
            <div class="col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm p-4 bg-white rounded-4 h-100">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="text-secondary small fw-semibold">Đơn Chờ Xử Lý</span>
                        <span class="badge bg-warning-subtle text-warning p-2 rounded-3">
                            <i class="bi bi-hourglass-split fs-5"></i>
                        </span>
                    </div>
                    <h3 class="fw-bold text-warning mb-1">${pendingOrders} đơn</h3>
                    <div class="small text-secondary">
                        <i class="bi bi-clock me-1"></i>Chờ xác nhận & Đã chuyển khoản
                    </div>
                </div>
            </div>

            <!-- Thẻ 3: Tổng Đơn Hàng -->
            <div class="col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm p-4 bg-white rounded-4 h-100">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="text-secondary small fw-semibold">Tổng Số Đơn Hàng</span>
                        <span class="badge bg-primary-subtle text-primary p-2 rounded-3">
                            <i class="bi bi-receipt-cutoff fs-5"></i>
                        </span>
                    </div>
                    <h3 class="fw-bold text-dark mb-1">${totalOrders} đơn</h3>
                    <div class="small text-primary">
                        <i class="bi bi-bar-chart-fill me-1"></i>Gồm cả COD & VietQR
                    </div>
                </div>
            </div>

            <!-- Thẻ 4: Khách Hàng & Sản Phẩm -->
            <div class="col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm p-4 bg-white rounded-4 h-100">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="text-secondary small fw-semibold">Khách Hàng / Mặt Hàng</span>
                        <span class="badge bg-info-subtle text-info p-2 rounded-3">
                            <i class="bi bi-people-fill fs-5"></i>
                        </span>
                    </div>
                    <h3 class="fw-bold text-dark mb-1">${totalCustomers} / ${totalProducts}</h3>
                    <div class="small text-secondary">
                        <i class="bi bi-apple me-1"></i>${totalCustomers} khách &bull; ${totalProducts} loại trái cây
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Bảng TOP 5 Mặt Hàng Bán Chạy Nhất (Bước 6) -->
            <div class="col-lg-7">
                <div class="card border-0 shadow-sm p-4 rounded-4 bg-white h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold text-dark mb-1">
                                <i class="bi bi-trophy-fill text-warning me-2"></i>Top 5 Mặt Hàng Bán Chạy Nhất
                            </h5>
                            <span class="text-secondary small">Xếp hạng theo tổng sản lượng đã bán thành công</span>
                        </div>
                        <span class="badge bg-light text-secondary border px-3 py-2">
                            <i class="bi bi-fire text-danger me-1"></i>Bán chạy
                        </span>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="text-center" style="width: 50px;">Hạng</th>
                                    <th>Trái cây</th>
                                    <th>Danh mục</th>
                                    <th class="text-center">Đã bán</th>
                                    <th class="text-end">Doanh thu thu về</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${top5Products}" var="tp" varStatus="loop">
                                    <tr>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${loop.index == 0}">
                                                    <span class="badge bg-warning text-dark rounded-circle p-2" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">1</span>
                                                </c:when>
                                                <c:when test="${loop.index == 1}">
                                                    <span class="badge bg-secondary text-white rounded-circle p-2" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">2</span>
                                                </c:when>
                                                <c:when test="${loop.index == 2}">
                                                    <span class="badge bg-danger-subtle text-danger border rounded-circle p-2" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">3</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-secondary border rounded-circle p-2" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">${loop.index + 1}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="${tp.imageUrl}" alt="${tp.productName}" 
                                                     class="rounded-3 border shadow-sm" 
                                                     style="width: 44px; height: 44px; object-fit: cover;"
                                                     onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=100&q=80';">
                                                <div>
                                                    <div class="fw-bold text-dark">${tp.productName}</div>
                                                    <small class="text-secondary"><fmt:formatNumber value="${tp.price}" pattern="#,###" /> đ / ${tp.unit}</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark border">${tp.categoryName}</span>
                                        </td>
                                        <td class="text-center">
                                            <span class="fw-bold text-success fs-6">${tp.totalSold}</span> 
                                            <small class="text-secondary">${tp.unit}</small>
                                        </td>
                                        <td class="text-end fw-bold text-danger">
                                            <fmt:formatNumber value="${tp.totalRevenue}" pattern="#,###" /> đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Cột Phải: Đơn Hàng Gần Đây Cần Xử Lý -->
            <div class="col-lg-5">
                <div class="card border-0 shadow-sm p-4 rounded-4 bg-white h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold text-dark mb-1">
                                <i class="bi bi-clock-history text-primary me-2"></i>Đơn Hàng Gần Đây
                            </h5>
                            <span class="text-secondary small">5 đơn đặt mới nhất trên hệ thống</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/orders" class="small text-success text-decoration-none fw-semibold">
                            Xem tất cả <i class="bi bi-arrow-right"></i>
                        </a>
                    </div>

                    <div class="d-flex flex-column gap-3">
                        <c:forEach items="${recentOrders}" var="ro">
                            <div class="p-3 rounded-3 bg-light border d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <span class="fw-bold text-dark">#DH${ro.orderId}</span>
                                        <c:choose>
                                            <c:when test="${ro.orderStatus == 'Chờ xác nhận' || ro.orderStatus == 'Đã chuyển khoản'}">
                                                <span class="badge bg-warning text-dark">${ro.orderStatus}</span>
                                            </c:when>
                                            <c:when test="${ro.orderStatus == 'Hoàn thành'}">
                                                <span class="badge bg-success">${ro.orderStatus}</span>
                                            </c:when>
                                            <c:when test="${ro.orderStatus == 'Đã hủy'}">
                                                <span class="badge bg-secondary">${ro.orderStatus}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-primary">${ro.orderStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="badge ${ro.paymentMethod == 'BANK_TRANSFER' ? 'bg-primary-subtle text-primary border' : 'bg-light text-dark border'}">
                                            ${ro.paymentMethod == 'BANK_TRANSFER' ? 'VietQR' : 'COD'}
                                        </span>
                                    </div>
                                    <div class="small text-secondary">
                                        <i class="bi bi-person me-1"></i>${ro.receiverName} &bull; 
                                        <fmt:formatDate value="${ro.orderDate}" pattern="dd/MM HH:mm" />
                                    </div>
                                </div>
                                <div class="text-end">
                                    <div class="fw-bold text-danger fs-6">
                                        <fmt:formatNumber value="${ro.totalAmount}" pattern="#,###" /> đ
                                    </div>
                                    <a href="${pageContext.request.contextPath}/admin/orders?keyword=${ro.orderId}" class="btn btn-outline-success btn-sm py-0 px-2 mt-1" style="font-size: 0.75rem;">
                                        Xử lý đơn
                                    </a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
