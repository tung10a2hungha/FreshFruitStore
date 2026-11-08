<%-- 
    Document   : verify-otp
    Description: Trang nhập mã xác nhận OTP 6 chữ số gửi qua Gmail
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác thực mã OTP - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <style>
        .otp-input {
            font-size: 1.75rem;
            letter-spacing: 0.5rem;
            text-align: center;
            font-weight: 700;
            color: #15803d;
            font-family: 'Courier New', monospace;
        }
    </style>
</head>
<body class="bg-light ff-auth-body d-flex flex-column justify-content-center align-items-center" style="min-height: 100vh; padding: 24px;">
    
    <!-- Logo điều hướng về Trang chủ -->
    <div class="mb-3 text-center">
        <a href="${pageContext.request.contextPath}/index.jsp" class="ff-brand text-decoration-none">
            <span class="brand-badge"><i class="bi bi-basket2-fill"></i></span>
            <span>FreshFruit Store</span>
        </a>
    </div>

    <div class="card ff-auth-card shadow p-4 p-md-5" style="width: 100%; max-width: 440px;">
        <div class="text-center mb-2">
            <span class="badge bg-success-subtle text-success rounded-pill px-3 py-2 mb-2">
                <i class="bi bi-envelope-check-fill me-1"></i>Kiểm tra hộp thư
            </span>
        </div>
        <h3 class="text-center text-success fw-bold mb-2">Xác Nhận OTP</h3>
        <p class="text-center text-muted small mb-3">
            Mã xác nhận 6 chữ số đã được gửi tới email:<br>
            <strong class="text-dark">${sessionScope.fpMaskedEmail}</strong>
        </p>

        <!-- Thông báo thành công nếu vừa gửi/gửi lại mã -->
        <c:if test="${not empty message}">
            <div class="alert alert-success py-2 small text-center mb-3">
                <i class="bi bi-check-circle-fill me-1"></i>${message}
            </div>
        </c:if>

        <!-- Thông báo lỗi nếu OTP sai hoặc hết hạn -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger py-2 small text-center mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i>${error}
            </div>
        </c:if>

        <!-- Cảnh báo nếu đang chạy ở chế độ dev -->
        <c:if test="${not empty warning}">
            <div class="alert alert-warning py-2 small text-center mb-3">
                <i class="bi bi-info-circle-fill me-1"></i>${warning}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="post">
            <input type="hidden" name="action" value="verify-otp" />
            
            <div class="mb-3 text-center">
                <label class="form-label small fw-semibold text-secondary">Nhập mã OTP gồm 6 chữ số</label>
                <input type="text" class="form-control otp-input" name="otpCode" 
                       placeholder="------" maxlength="6" pattern="[0-9]{6}" inputmode="numeric" required autofocus />
                <div class="form-text small text-muted mt-2">
                    <i class="bi bi-clock-history me-1"></i>Mã OTP có hiệu lực trong vòng <strong>5 phút</strong>.
                </div>
            </div>
            
            <button type="submit" class="btn btn-success w-100 py-2 mb-3 shadow-sm fw-bold">
                <i class="bi bi-check2-circle me-1"></i>Xác Nhận & Tiếp Tục
            </button>
        </form>

        <!-- Nút gửi lại mã OTP -->
        <form action="${pageContext.request.contextPath}/forgot-password" method="post" class="text-center mb-3">
            <input type="hidden" name="action" value="resend-otp" />
            <span class="small text-muted">Chưa nhận được mã? </span>
            <button type="submit" class="btn btn-link btn-sm text-success p-0 fw-bold text-decoration-none">
                <i class="bi bi-arrow-clockwise me-1"></i>Gửi lại mã mới
            </button>
        </form>

        <!-- Đổi email khác -->
        <div class="text-center border-top pt-3">
            <a href="${pageContext.request.contextPath}/forgot-password" class="small text-secondary text-decoration-none">
                <i class="bi bi-pencil-square me-1"></i>Nhập lại email / tài khoản khác
            </a>
        </div>

        <div class="text-center mt-2">
            <a href="${pageContext.request.contextPath}/login" class="small text-secondary text-decoration-none">
                <i class="bi bi-arrow-left me-1"></i>Quay lại trang Đăng nhập
            </a>
        </div>
    </div>

</body>
</html>
