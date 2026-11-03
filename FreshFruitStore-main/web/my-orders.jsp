<%-- 
    Document   : my-orders
    Description: Màn hình Lịch Sử Mua Hàng & Quản Lý Đơn Của Khách Hàng
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Mua Hàng - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <!-- Header dùng chung -->
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-5 pb-5">
        <!-- Tiêu đề trang -->
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
            <div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-1 small">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/index.jsp" class="text-decoration-none text-secondary">Trang chủ</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Lịch sử mua hàng</li>
                    </ol>
                </nav>
                <h3 class="fw-bold text-dark mb-0">
                    <i class="bi bi-clock-history text-success me-2"></i>Đơn Hàng Của Tôi
                </h3>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/shop" class="btn btn-outline-success rounded-pill px-4">
                    <i class="bi bi-plus-circle me-1"></i>Tiếp tục mua sắm
                </a>
            </div>
        </div>

        <!-- Flash messages -->
        <c:if test="${not empty message}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm rounded-3" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm rounded-3" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Thẻ thống kê tổng quan -->
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-4 text-center">
                    <span class="text-secondary small fw-semibold">Tổng Đơn Hàng</span>
                    <h3 class="fw-bold text-dark mt-1 mb-0">${totalOrders}</h3>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-4 text-center">
                    <span class="text-warning small fw-semibold">Đang Xử Lý / Giao</span>
                    <h3 class="fw-bold text-warning mt-1 mb-0">${pendingCount}</h3>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-4 text-center">
                    <span class="text-success small fw-semibold">Đã Hoàn Thành</span>
                    <h3 class="fw-bold text-success mt-1 mb-0">${completedCount}</h3>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-4 text-center">
                    <span class="text-danger small fw-semibold">Đã Hủy</span>
                    <h3 class="fw-bold text-secondary mt-1 mb-0">${cancelledCount}</h3>
                </div>
            </div>
        </div>

        <!-- Danh sách đơn hàng -->
        <c:choose>
            <c:when test="${empty orders}">
                <!-- Empty State khi chưa có đơn nào -->
                <div class="card border-0 shadow-sm p-5 text-center bg-white rounded-4">
                    <div class="mb-3">
                        <i class="bi bi-bag-x display-1 text-secondary opacity-50"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Bạn chưa có đơn mua hàng nào</h5>
                    <p class="text-secondary small mb-4">
                        Hãy dạo một vòng cửa hàng và chọn cho gia đình những giỏ hoa quả tươi ngon nhất nhé!
                    </p>
                    <div>
                        <a href="${pageContext.request.contextPath}/shop" class="btn btn-success btn-lg rounded-pill px-4 shadow-sm">
                            <i class="bi bi-shop me-2"></i>Khám Phá Cửa Hàng Ngay
                        </a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="d-flex flex-column gap-4">
                    <c:forEach items="${orders}" var="o">
                        <div class="card border-0 shadow-sm rounded-4 bg-white overflow-hidden">
                            <!-- Header đơn hàng -->
                            <div class="card-header bg-light border-0 py-3 px-4 d-flex flex-wrap justify-content-between align-items-center gap-2">
                                <div class="d-flex align-items-center gap-3">
                                    <span class="fw-bold text-dark fs-6">Đơn Hàng #DH${o.orderId}</span>
                                    <span class="text-secondary small">
                                        <i class="bi bi-calendar3 me-1"></i>
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm" />
                                    </span>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <!-- Badge Phương thức thanh toán -->
                                    <span class="badge ${o.paymentMethod == 'BANK_TRANSFER' ? 'bg-primary-subtle text-primary border border-primary-subtle' : 'bg-light text-dark border'}">
                                        <i class="bi ${o.paymentMethod == 'BANK_TRANSFER' ? 'bi-qr-code' : 'bi-cash-coin'} me-1"></i>
                                        ${o.paymentMethod == 'BANK_TRANSFER' ? 'VietQR' : 'COD (Tiền mặt)'}
                                    </span>

                                    <!-- Badge Trạng thái đơn hàng -->
                                    <c:choose>
                                        <c:when test="${o.orderStatus == 'Chờ xác nhận'}">
                                            <span class="badge bg-warning text-dark"><i class="bi bi-hourglass-split me-1"></i>Chờ xác nhận</span>
                                        </c:when>
                                        <c:when test="${o.orderStatus == 'Đã chuyển khoản'}">
                                            <span class="badge bg-info text-dark"><i class="bi bi-check-circle me-1"></i>Đã chuyển khoản</span>
                                        </c:when>
                                        <c:when test="${o.orderStatus == 'Đã xác nhận' || o.orderStatus == 'Đã thanh toán'}">
                                            <span class="badge bg-primary text-white"><i class="bi bi-patch-check me-1"></i>${o.orderStatus}</span>
                                        </c:when>
                                        <c:when test="${o.orderStatus == 'Đang giao hàng'}">
                                            <span class="badge bg-primary text-white"><i class="bi bi-truck me-1"></i>Đang giao hàng</span>
                                        </c:when>
                                        <c:when test="${o.orderStatus == 'Hoàn thành'}">
                                            <span class="badge bg-success text-white"><i class="bi bi-check2-all me-1"></i>Giao thành công</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary text-white"><i class="bi bi-x-circle me-1"></i>${o.orderStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Body: Danh sách các sản phẩm trong đơn -->
                            <div class="card-body p-4">
                                <div class="table-responsive">
                                    <table class="table align-middle mb-0">
                                        <tbody>
                                            <c:forEach items="${o.details}" var="d">
                                                <tr>
                                                    <td style="width: 70px;">
                                                        <img src="${d.imageUrl}" alt="${d.productName}" 
                                                             class="rounded-3 border shadow-sm" 
                                                             style="width: 60px; height: 60px; object-fit: cover;"
                                                             onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=120&q=80';">
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold text-dark">${d.productName}</div>
                                                        <div class="small text-secondary">
                                                            Đơn vị: <strong>${d.unit}</strong> | Đơn giá: 
                                                            <fmt:formatNumber value="${d.unitPrice}" pattern="#,###" /> đ
                                                        </div>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge bg-light text-dark border px-3 py-2 fs-6">
                                                            x ${d.quantity}
                                                        </span>
                                                    </td>
                                                    <td class="text-end fw-bold text-danger fs-6">
                                                        <fmt:formatNumber value="${d.totalPrice}" pattern="#,###" /> đ
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Địa chỉ giao hàng & ghi chú -->
                                <div class="bg-light p-3 rounded-3 mt-3 small text-secondary">
                                    <div class="row g-2">
                                        <div class="col-md-6">
                                            <i class="bi bi-geo-alt-fill text-danger me-1"></i>
                                            Giao tới: <strong class="text-dark">${o.receiverName}</strong> - ${o.receiverPhone}
                                            <div class="ms-3 text-dark">${o.shippingAddress}</div>
                                        </div>
                                        <c:if test="${not empty o.orderNote}">
                                            <div class="col-md-6">
                                                <i class="bi bi-chat-quote-fill text-primary me-1"></i>
                                                Ghi chú: <span class="fst-italic text-dark">"${o.orderNote}"</span>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <!-- Footer: Tổng tiền & Nút thao tác -->
                            <div class="card-footer bg-white border-top py-3 px-4 d-flex flex-wrap justify-content-between align-items-center gap-3">
                                <div class="d-flex align-items-baseline gap-2">
                                    <span class="text-secondary small">Tổng thanh toán:</span>
                                    <span class="fw-bold text-danger fs-5">
                                        <fmt:formatNumber value="${o.totalAmount}" pattern="#,###" /> đ
                                    </span>
                                </div>

                                <div class="d-flex align-items-center gap-2">
                                    <!-- Nút Thanh toán VietQR nếu đơn chưa thanh toán -->
                                    <c:if test="${o.paymentMethod == 'BANK_TRANSFER' && (o.orderStatus == 'Chờ xác nhận' || o.orderStatus == 'Chờ thanh toán')}">
                                        <a href="${pageContext.request.contextPath}/payment?orderId=${o.orderId}" 
                                           class="btn btn-outline-primary btn-sm rounded-pill px-3">
                                            <i class="bi bi-qr-code me-1"></i>Quét mã VietQR
                                        </a>
                                    </c:if>

                                    <!-- Nút Hủy đơn cho khách hàng (chỉ khi đơn chưa giao) -->
                                    <c:if test="${o.orderStatus == 'Chờ xác nhận' || o.orderStatus == 'Đã chuyển khoản'}">
                                        <form action="${pageContext.request.contextPath}/my-orders" method="post" class="d-inline"
                                              onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng #DH${o.orderId}?');">
                                            <input type="hidden" name="orderId" value="${o.orderId}">
                                            <input type="hidden" name="action" value="cancel">
                                            <button type="submit" class="btn btn-outline-danger btn-sm rounded-pill px-3">
                                                <i class="bi bi-x-circle me-1"></i>Hủy đơn
                                            </button>
                                        </form>
                                    </c:if>

                                    <!-- Nút Mua lại đơn này -->
                                    <form action="${pageContext.request.contextPath}/my-orders" method="post" class="d-inline">
                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                        <input type="hidden" name="action" value="reorder">
                                        <button type="submit" class="btn btn-success btn-sm rounded-pill px-3">
                                            <i class="bi bi-cart-plus me-1"></i>Mua lại
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Footer dùng chung -->
    <jsp:include page="/includes/footer.jsp" />
</body>
</html>
