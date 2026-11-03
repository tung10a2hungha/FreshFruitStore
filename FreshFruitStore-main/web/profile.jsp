<%-- 
    Document   : profile
    Description: Trang Xem chi tiết & Cập nhật thông tin tài khoản Khách hàng
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Bắt buộc đăng nhập mới được xem thông tin tài khoản
    if (session.getAttribute("account") == null) {
        request.setAttribute("error", "Vui lòng đăng nhập để xem thông tin tài khoản!");
        request.getRequestDispatcher("/login.jsp").forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin tài khoản - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-4 pb-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="text-success fw-bold mb-1">
                    <i class="bi bi-person-vcard me-2"></i>Thông Tin Tài Khoản
                </h2>
                <p class="text-secondary small mb-0">
                    Xem thông tin hồ sơ, quản lý địa chỉ nhận hàng và đổi mật khẩu bảo mật.
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/shop" class="btn btn-outline-success rounded-pill px-4">
                <i class="bi bi-shop me-1"></i>Về Cửa hàng
            </a>
        </div>

        <div class="row g-4">
            <!-- Cột Trái: Thẻ Chi tiết Thông tin Khách hàng -->
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm p-4 bg-white rounded-4 h-100">
                    <div class="text-center">
                        <div class="mx-auto mb-3 d-flex align-items-center justify-content-center rounded-circle bg-success-subtle text-success fw-bold" style="width: 88px; height: 88px; font-size: 2.2rem;">
                            <i class="bi bi-person-circle"></i>
                        </div>
                        <h5 class="fw-bold mb-1">
                            ${not empty sessionScope.account.fullName ? sessionScope.account.fullName : sessionScope.account.username}
                        </h5>
                        <p class="text-secondary small mb-2">@${sessionScope.account.username}</p>
                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
                            <i class="bi bi-patch-check-fill me-1"></i>${sessionScope.account.role}
                        </span>
                    </div>

                    <hr class="my-4">

                    <h6 class="fw-bold text-dark mb-3">
                        <i class="bi bi-info-circle-fill text-success me-2"></i>Chi tiết hồ sơ
                    </h6>
                    <div class="small d-flex flex-column gap-3">
                        <div class="d-flex justify-content-between border-bottom pb-2">
                            <span class="text-secondary">Mã tài khoản:</span>
                            <span class="fw-bold text-dark">#${sessionScope.account.userId}</span>
                        </div>
                        <div class="d-flex justify-content-between border-bottom pb-2">
                            <span class="text-secondary">Tên đăng nhập:</span>
                            <span class="fw-semibold text-dark">${sessionScope.account.username}</span>
                        </div>
                        <div class="d-flex justify-content-between border-bottom pb-2">
                            <span class="text-secondary">Họ và tên:</span>
                            <span class="fw-semibold text-dark">
                                ${not empty sessionScope.account.fullName ? sessionScope.account.fullName : 'Chưa cập nhật'}
                            </span>
                        </div>
                        <div class="d-flex justify-content-between border-bottom pb-2">
                            <span class="text-secondary">Địa chỉ Email:</span>
                            <span class="fw-semibold text-dark">
                                ${not empty sessionScope.account.email ? sessionScope.account.email : 'Chưa cập nhật'}
                            </span>
                        </div>
                        <div class="d-flex justify-content-between border-bottom pb-2">
                            <span class="text-secondary">Số điện thoại:</span>
                            <span class="fw-semibold text-dark">
                                ${not empty sessionScope.account.phone ? sessionScope.account.phone : 'Chưa cập nhật'}
                            </span>
                        </div>
                        <div>
                            <div class="text-secondary mb-1">Địa chỉ giao hàng:</div>
                            <div class="fw-semibold text-dark bg-light p-2 rounded-3 border">
                                ${not empty sessionScope.account.address ? sessionScope.account.address : 'Chưa cập nhật địa chỉ'}
                            </div>
                        </div>

                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/my-orders" class="btn btn-success w-100 rounded-pill py-2 shadow-sm text-white">
                                <i class="bi bi-clock-history me-1"></i>Lịch Sử Mua Hàng Của Tôi
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Cột Phải: Form Cập nhật Thông tin & Đổi mật khẩu -->
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm p-4 bg-white rounded-4">
                    <h5 class="fw-bold text-success mb-3">
                        <i class="bi bi-pencil-square me-2"></i>Cập nhật Thông tin Cá nhân
                    </h5>

                    <c:if test="${not empty message}">
                        <div class="alert alert-success alert-dismissible fade show py-2 small" role="alert">
                            <i class="bi bi-check-circle-fill me-1"></i><strong>${message}</strong>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show py-2 small" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i><strong>${error}</strong>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/profile" method="post">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Tên đăng nhập</label>
                                <input type="text" name="username" class="form-control bg-light" value="${sessionScope.account.username}" readonly>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Họ và tên khách hàng</label>
                                <input type="text" name="fullname" class="form-control" value="${sessionScope.account.fullName}" placeholder="Nhập họ và tên đầy đủ" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Địa chỉ Email</label>
                                <input type="email" name="email" class="form-control" value="${sessionScope.account.email}" placeholder="Ví dụ: customer@gmail.com">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Số điện thoại nhận hàng</label>
                                <input type="text" name="phone" class="form-control" value="${sessionScope.account.phone}" placeholder="Ví dụ: 0912345678" required>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Địa chỉ giao hàng mặc định</label>
                                <textarea name="address" class="form-control" rows="2" placeholder="Số nhà, Đường, Phường/Xã, Quận/Huyện..." required>${sessionScope.account.address}</textarea>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Đổi mật khẩu mới (Bỏ trống nếu không đổi)</label>
                                <input type="password" name="password" class="form-control" placeholder="Nhập mật khẩu mới nếu muốn thay đổi">
                                <div class="form-text small text-muted">Mật khẩu mới sẽ được mã hóa an toàn bằng thuật toán SHA-256.</div>
                            </div>

                            <div class="col-12 d-flex justify-content-end gap-2 mt-3">
                                <button type="submit" class="btn btn-success px-4 py-2 rounded-pill fw-bold shadow-sm">
                                    <i class="bi bi-floppy-fill me-1"></i>Lưu Thay Đổi
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</body>
</html>
