<%-- 
    Document   : order-success
    Description: Trang Thông Báo Đặt Hàng Thành Công (Bước 4)
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Hàng Thành Công - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-5 pb-5">
        <div class="card border-0 shadow-sm p-4 p-md-5 rounded-4 bg-white mx-auto" style="max-width: 800px;">
            <div class="text-center mb-4">
                <div class="mx-auto mb-3 d-flex align-items-center justify-content-center rounded-circle bg-success-subtle text-success" style="width: 88px; height: 88px; font-size: 3rem;">
                    <i class="bi bi-check-circle-fill"></i>
                </div>
                <span class="badge bg-success-subtle text-success rounded-pill px-3 py-1 mb-2">Đơn hàng đã được tiếp nhận</span>
                <h2 class="fw-bold text-dark">Đặt Hàng Thành Công!</h2>
                <p class="text-secondary small mb-0">Cảm ơn bạn đã tin tưởng chọn hoa quả tươi sạch tại <strong>FreshFruit Store</strong>.</p>
            </div>

            <!-- Tóm tắt thông tin mã đơn hàng -->
            <div class="bg-light p-3 rounded-3 mb-4 d-flex flex-wrap justify-content-between align-items-center">
                <div>
                    <span class="text-secondary small">Mã đơn hàng:</span>
                    <h5 class="fw-bold text-success mb-0">#${order.orderId}</h5>
                </div>
                <div class="text-md-end mt-2 mt-md-0">
                    <span class="text-secondary small">Thời gian đặt:</span>
                    <div class="fw-semibold text-dark">
                        <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm" />
                    </div>
                </div>
            </div>

            <!-- Thông tin người nhận -->
            <h6 class="fw-bold text-success mb-3"><i class="bi bi-geo-alt-fill me-2"></i>Thông Tin Giao Hàng</h6>
            <div class="row g-2 mb-4 small">
                <div class="col-sm-4 text-secondary">Người nhận hàng:</div>
                <div class="col-sm-8 fw-semibold text-dark">${order.receiverName} (${order.receiverPhone})</div>

                <div class="col-sm-4 text-secondary">Địa chỉ giao hàng:</div>
                <div class="col-sm-8 fw-semibold text-dark">${order.shippingAddress}</div>

                <c:if test="${not empty order.orderNote}">
                    <div class="col-sm-4 text-secondary">Ghi chú đơn hàng:</div>
                    <div class="col-sm-8 text-secondary fst-italic">"${order.orderNote}"</div>
                </c:if>

                <div class="col-sm-4 text-secondary">Hình thức thanh toán:</div>
                <div class="col-sm-8 fw-semibold text-dark">
                    <c:choose>
                        <c:when test="${order.paymentMethod == 'BANK_TRANSFER'}">
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle">Chuyển khoản VietQR</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-success-subtle text-success border border-success-subtle">Thanh toán tiền mặt khi nhận hàng (COD)</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="col-sm-4 text-secondary">Trạng thái đơn:</div>
                <div class="col-sm-8">
                    <span class="badge bg-warning text-dark">${order.orderStatus}</span>
                </div>
            </div>

            <!-- Danh sách chi tiết các mặt hàng trong đơn -->
            <h6 class="fw-bold text-success mb-3"><i class="bi bi-basket2-fill me-2"></i>Mặt Hàng Đã Đặt</h6>
            <div class="table-responsive border rounded-3 mb-4">
                <table class="table align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Sản phẩm</th>
                            <th class="text-center">Số lượng</th>
                            <th class="text-end">Đơn giá</th>
                            <th class="text-end">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${order.details}" var="d">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <img src="${d.imageUrl}" 
                                             alt="${d.productName}" 
                                             class="rounded-2 border" 
                                             style="width: 44px; height: 44px; object-fit: cover;"
                                             onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=100&q=80';">
                                        <div>
                                            <span class="fw-semibold text-dark">${d.productName}</span>
                                            <small class="text-secondary d-block">ĐVT: ${d.unit}</small>
                                        </div>
                                    </div>
                                </td>
                                <td class="text-center fw-semibold">${d.quantity} ${d.unit}</td>
                                <td class="text-end text-secondary">
                                    <fmt:formatNumber value="${d.unitPrice}" pattern="#,###" /> đ
                                </td>
                                <td class="text-end fw-bold text-danger">
                                    <fmt:formatNumber value="${d.totalPrice}" pattern="#,###" /> đ
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                    <tfoot class="table-light">
                        <tr>
                            <td colspan="3" class="fw-bold text-dark text-end">Tổng thanh toán:</td>
                            <td class="text-end fw-bold text-danger fs-5">
                                <fmt:formatNumber value="${order.totalAmount}" pattern="#,###" /> đ
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <!-- Cam kết giao hàng -->
            <div class="alert alert-info py-2 small mb-4">
                <i class="bi bi-truck me-2"></i>Đơn hàng sẽ được nhân viên đóng gói và chuyển giao nhanh chóng đến bạn trong ngày hôm nay.
            </div>

            <div class="d-flex flex-wrap justify-content-center gap-2">
                <a href="${pageContext.request.contextPath}/my-orders" class="btn btn-outline-primary rounded-pill px-4">
                    <i class="bi bi-clock-history me-1"></i>Xem Đơn Hàng Của Tôi
                </a>
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-outline-secondary rounded-pill px-4">
                    <i class="bi bi-house-door me-1"></i>Về Trang Chủ
                </a>
                <a href="${pageContext.request.contextPath}/shop" class="btn btn-success rounded-pill px-4 shadow-sm">
                    <i class="bi bi-shop me-1"></i>Tiếp Tục Mua Sắm
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</body>
</html>
