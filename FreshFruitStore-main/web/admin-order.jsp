<%-- 
    Document   : admin-order
    Description: Dashboard Admin Quản lý Đơn hàng & Cập nhật Trạng thái (Bước 5)
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Tự động chuyển hướng qua Servlet AdminOrderController nếu truy cập trực tiếp file JSP
    if (request.getAttribute("listOrder") == null) {
        request.getRequestDispatcher("/admin/orders").forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Quản lý Đơn hàng - FreshFruit</title>
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
                <a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">
                    <i class="bi bi-speedometer2 me-1"></i>Tổng quan
                </a>
                <a class="nav-link active fw-bold text-success" href="${pageContext.request.contextPath}/admin/orders">
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
        <!-- Thông báo Flash Messages -->
        <c:if test="${not empty message}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Thống kê nhanh Đơn Hàng (Dữ liệu động thực tế) -->
        <div class="row g-3 mb-4">
            <div class="col-md">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-3">
                    <div class="text-secondary small fw-semibold">Tổng Đơn Hàng</div>
                    <h4 class="fw-bold text-dark mb-0">${totalOrders} đơn</h4>
                </div>
            </div>
            <div class="col-md">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-3">
                    <div class="text-warning small fw-semibold">Chờ Duyệt / Chờ TT</div>
                    <h4 class="fw-bold text-warning mb-0">${pendingOrders} đơn</h4>
                </div>
            </div>
            <div class="col-md">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-3">
                    <div class="text-primary small fw-semibold">Đang Giao Hàng</div>
                    <h4 class="fw-bold text-primary mb-0">${shippingOrders} đơn</h4>
                </div>
            </div>
            <div class="col-md">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-3">
                    <div class="text-success small fw-semibold">Đã Hoàn Thành</div>
                    <h4 class="fw-bold text-success mb-0">${completedOrders} đơn</h4>
                </div>
            </div>
            <div class="col-md">
                <div class="card border-0 shadow-sm p-3 bg-white rounded-3">
                    <div class="text-secondary small fw-semibold">Doanh Thu Thực Tế</div>
                    <h4 class="fw-bold text-danger mb-0">
                        <fmt:formatNumber value="${totalRevenue}" pattern="#,###" /> đ
                    </h4>
                </div>
            </div>
        </div>

        <!-- Bộ lọc & Tìm kiếm Đơn hàng -->
        <div class="card border-0 shadow-sm p-3 rounded-4 bg-white mb-4">
            <form action="${pageContext.request.contextPath}/admin/orders" method="get" class="row g-2 align-items-center">
                <div class="col-md-4">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-search"></i></span>
                        <input type="text" name="keyword" value="${keyword}" class="form-control border-start-0" placeholder="Mã đơn, Tên người nhận, SĐT...">
                    </div>
                </div>
                <div class="col-md-3">
                    <select name="status" class="form-select">
                        <option value="ALL">-- Tất cả trạng thái --</option>
                        <option value="Chờ xác nhận" ${statusFilter == 'Chờ xác nhận' ? 'selected' : ''}>Chờ xác nhận</option>
                        <option value="Đã chuyển khoản" ${statusFilter == 'Đã chuyển khoản' ? 'selected' : ''}>Đã chuyển khoản</option>
                        <option value="Đã xác nhận" ${statusFilter == 'Đã xác nhận' ? 'selected' : ''}>Đã xác nhận</option>
                        <option value="Đã thanh toán" ${statusFilter == 'Đã thanh toán' ? 'selected' : ''}>Đã thanh toán</option>
                        <option value="Đang giao hàng" ${statusFilter == 'Đang giao hàng' ? 'selected' : ''}>Đang giao hàng</option>
                        <option value="Hoàn thành" ${statusFilter == 'Hoàn thành' ? 'selected' : ''}>Hoàn thành</option>
                        <option value="Đã hủy" ${statusFilter == 'Đã hủy' ? 'selected' : ''}>Đã hủy</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-success px-4 rounded-pill">
                        <i class="bi bi-funnel me-1"></i>Lọc Đơn
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary rounded-pill">
                        Đặt lại
                    </a>
                </div>
            </form>
        </div>

        <!-- Bảng danh sách đơn hàng -->
        <div class="card border-0 shadow-sm p-4 rounded-4 bg-white">
            <h5 class="fw-bold text-success mb-3"><i class="bi bi-receipt me-2"></i>Danh Sách Đơn Hàng</h5>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-success">
                        <tr>
                            <th>Mã Đơn</th>
                            <th>Khách hàng</th>
                            <th>Địa chỉ nhận hàng</th>
                            <th>Tổng tiền</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái hiện tại</th>
                            <th class="text-end">Cập nhật trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listOrder}" var="o">
                            <tr>
                                <td>
                                    <span class="fw-bold text-dark">#${o.orderId}</span>
                                    <div class="small text-secondary">
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd/MM HH:mm" />
                                    </div>
                                    <button class="btn btn-link btn-sm p-0 text-decoration-none small text-success" 
                                            data-bs-toggle="modal" 
                                            data-bs-target="#orderDetailModal${o.orderId}">
                                        <i class="bi bi-eye"></i> Xem món (${o.details.size()})
                                    </button>
                                </td>
                                <td>
                                    <div class="fw-bold text-dark">${o.receiverName}</div>
                                    <small class="text-secondary"><i class="bi bi-telephone me-1"></i>${o.receiverPhone}</small>
                                </td>
                                <td>
                                    <div class="small text-dark" style="max-width: 220px;">${o.shippingAddress}</div>
                                    <c:if test="${not empty o.orderNote}">
                                        <small class="text-secondary fst-italic">"${o.orderNote}"</small>
                                    </c:if>
                                </td>
                                <td class="text-danger fw-bold fs-6">
                                    <fmt:formatNumber value="${o.totalAmount}" pattern="#,###" /> đ
                                </td>
                                <td>
                                    <span class="badge ${o.paymentMethod == 'BANK_TRANSFER' ? 'bg-primary-subtle text-primary border' : 'bg-light text-dark border'}">
                                        ${o.paymentMethod == 'BANK_TRANSFER' ? 'VietQR' : 'COD'}
                                    </span>
                                </td>
                                <td>
                                    <!-- In màu trạng thái sinh động -->
                                    <c:choose>
                                        <c:when test="${o.orderStatus == 'Chờ xác nhận' || o.orderStatus == 'Đã chuyển khoản'}">
                                            <span class="badge bg-warning text-dark"><i class="bi bi-hourglass-split me-1"></i>${o.orderStatus}</span>
                                        </c:when>
                                        <c:when test="${o.orderStatus == 'Đang giao hàng' || o.orderStatus == 'Đã xác nhận' || o.orderStatus == 'Đã thanh toán'}">
                                            <span class="badge bg-primary"><i class="bi bi-truck me-1"></i>${o.orderStatus}</span>
                                        </c:when>
                                        <c:when test="${o.orderStatus == 'Hoàn thành'}">
                                            <span class="badge bg-success"><i class="bi bi-check-circle-fill me-1"></i>Hoàn thành</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">${o.orderStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <div class="d-flex flex-column align-items-end gap-1">
                                        <!-- Nhóm nút Thao tác nhanh theo đề bài Bước 5 -->
                                        <div class="btn-group btn-group-sm mb-1" role="group">
                                            <c:if test="${o.orderStatus == 'Chờ xác nhận'}">
                                                <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="d-inline">
                                                    <input type="hidden" name="orderId" value="${o.orderId}">
                                                    <input type="hidden" name="newStatus" value="Đã xác nhận">
                                                    <button type="submit" class="btn btn-outline-success btn-sm" title="Duyệt đơn hàng">
                                                        <i class="bi bi-check-lg"></i> Duyệt đơn
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'Đã chuyển khoản'}">
                                                <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="d-inline me-1">
                                                    <input type="hidden" name="orderId" value="${o.orderId}">
                                                    <input type="hidden" name="newStatus" value="Đã thanh toán">
                                                    <button type="submit" class="btn btn-primary btn-sm text-white" title="Xác nhận đã nhận tiền chuyển khoản">
                                                        <i class="bi bi-cash-stack"></i> Đã nhận tiền CK
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'Đã xác nhận' || o.orderStatus == 'Đã thanh toán'}">
                                                <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="d-inline">
                                                    <input type="hidden" name="orderId" value="${o.orderId}">
                                                    <input type="hidden" name="newStatus" value="Đang giao hàng">
                                                    <button type="submit" class="btn btn-outline-primary btn-sm" title="Bắt đầu giao hàng">
                                                        <i class="bi bi-truck"></i> Chuyển giao hàng
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'Đang giao hàng'}">
                                                <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="d-inline">
                                                    <input type="hidden" name="orderId" value="${o.orderId}">
                                                    <input type="hidden" name="newStatus" value="Hoàn thành">
                                                    <button type="submit" class="btn btn-success btn-sm text-white" title="Đã giao hàng thành công">
                                                        <i class="bi bi-check2-all"></i> Hoàn thành
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus != 'Đã hủy' && o.orderStatus != 'Hoàn thành'}">
                                                <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="d-inline ms-1" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng #${o.orderId}? Số lượng trái cây sẽ được tự động cộng hoàn lại vào kho!');">
                                                    <input type="hidden" name="orderId" value="${o.orderId}">
                                                    <input type="hidden" name="newStatus" value="Đã hủy">
                                                    <button type="submit" class="btn btn-outline-danger btn-sm" title="Hủy đơn & hoàn tồn kho">
                                                        <i class="bi bi-x-circle"></i> Hủy đơn
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>

                                        <!-- Dropdown chỉnh trạng thái tùy chọn -->
                                        <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="d-inline-flex gap-1 align-items-center">
                                            <input type="hidden" name="orderId" value="${o.orderId}">
                                            <select name="newStatus" class="form-select form-select-sm" style="width: 140px; font-size: 0.8rem;">
                                                <option value="Chờ xác nhận" ${o.orderStatus == 'Chờ xác nhận' ? 'selected' : ''}>Chờ xác nhận</option>
                                                <option value="Đã chuyển khoản" ${o.orderStatus == 'Đã chuyển khoản' ? 'selected' : ''}>Đã chuyển khoản</option>
                                                <option value="Đã xác nhận" ${o.orderStatus == 'Đã xác nhận' ? 'selected' : ''}>Đã xác nhận</option>
                                                <option value="Đã thanh toán" ${o.orderStatus == 'Đã thanh toán' ? 'selected' : ''}>Đã thanh toán</option>
                                                <option value="Đang giao hàng" ${o.orderStatus == 'Đang giao hàng' ? 'selected' : ''}>Đang giao hàng</option>
                                                <option value="Hoàn thành" ${o.orderStatus == 'Hoàn thành' ? 'selected' : ''}>Hoàn thành</option>
                                                <option value="Đã hủy" ${o.orderStatus == 'Đã hủy' ? 'selected' : ''}>Đã hủy (Hoàn kho)</option>
                                            </select>
                                            <button type="submit" class="btn btn-secondary btn-sm px-2 py-1" style="font-size: 0.8rem;" onclick="if(this.form.newStatus.value === 'Đã hủy') return confirm('Bạn có chắc chắn muốn hủy đơn hàng này? Số lượng trái cây sẽ được tự động cộng hoàn lại vào kho!');">
                                                Lưu
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>

                            <!-- Modal Chi tiết các mặt hàng trong đơn hàng #${o.orderId} -->
                            <div class="modal fade" id="orderDetailModal${o.orderId}" tabindex="-1">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header bg-success text-white">
                                            <h5 class="modal-title fw-bold">Chi Tiết Đơn Hàng #${o.orderId}</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body p-4">
                                            <div class="row g-2 mb-3 small">
                                                <div class="col-sm-6">Khách hàng: <strong>${o.receiverName}</strong> (${o.receiverPhone})</div>
                                                <div class="col-sm-6">Thanh toán: <strong>${o.paymentMethod}</strong></div>
                                                <div class="col-12">Địa chỉ giao: <strong>${o.shippingAddress}</strong></div>
                                            </div>

                                            <div class="table-responsive border rounded-3">
                                                <table class="table align-middle mb-0">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th>Trái cây</th>
                                                            <th class="text-center">Số lượng</th>
                                                            <th class="text-end">Đơn giá</th>
                                                            <th class="text-end">Thành tiền</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach items="${o.details}" var="d">
                                                            <tr>
                                                                <td>
                                                                    <div class="d-flex align-items-center gap-2">
                                                                        <img src="${d.imageUrl}" alt="${d.productName}" class="rounded-2" style="width: 40px; height: 40px; object-fit: cover;" onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=100&q=80';">
                                                                        <span>${d.productName}</span>
                                                                    </div>
                                                                </td>
                                                                <td class="text-center fw-bold">${d.quantity} ${d.unit}</td>
                                                                <td class="text-end text-secondary"><fmt:formatNumber value="${d.unitPrice}" pattern="#,###" /> đ</td>
                                                                <td class="text-end fw-bold text-danger"><fmt:formatNumber value="${d.totalPrice}" pattern="#,###" /> đ</td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                    <tfoot class="table-light">
                                                        <tr>
                                                            <td colspan="3" class="fw-bold text-end">Tổng tiền đơn:</td>
                                                            <td class="text-end fw-bold text-danger fs-6"><fmt:formatNumber value="${o.totalAmount}" pattern="#,###" /> đ</td>
                                                        </tr>
                                                    </tfoot>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
