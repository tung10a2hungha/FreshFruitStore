<%-- 
    Document   : forgot-password
    Description: Trang yêu cầu mã xác thực OTP qua Gmail để khôi phục mật khẩu
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
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
                <i class="bi bi-shield-lock-fill me-1"></i>Bảo mật tài khoản
            </span>
        </div>
        <h3 class="text-center text-success fw-bold mb-2">Quên Mật Khẩu</h3>
        <p class="text-center text-muted small mb-4">
            Nhập Email hoặc Tên đăng nhập của tài khoản bạn đã đăng ký để nhận mã OTP xác thực qua Gmail.
        </p>

        <!-- Thông báo lỗi nếu có -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger py-2 small text-center mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i>${error}
            </div>
        </c:if>

        <!-- Thông báo cảnh báo hoặc kiểm thử -->
        <c:if test="${not empty warning}">
            <div class="alert alert-warning py-2 small text-center mb-3">
                <i class="bi bi-info-circle-fill me-1"></i>${warning}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="post">
            <input type="hidden" name="action" value="send-otp" />
            
            <div class="mb-3">
                <label class="form-label small fw-semibold text-secondary">Email hoặc Tên đăng nhập</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-success">
                        <i class="bi bi-envelope-at"></i>
                    </span>
                    <input type="text" class="form-control border-start-0" name="accountInput" 
                           value="${accountInput}" placeholder="Ví dụ: nguyenvana@gmail.com hoặc tung" required autofocus />
                </div>
                <div class="form-text small text-muted">
                    Hệ thống sẽ gửi mã OTP gồm 6 chữ số đến địa chỉ Gmail đã liên kết với tài khoản này.
                </div>
            </div>
            
            <button type="submit" class="btn btn-success w-100 py-2 mb-3 shadow-sm fw-bold">
                <i class="bi bi-send-fill me-1"></i>Gửi Mã Xác Nhận
            </button>
        </form>

        <!-- Quay lại đăng nhập -->
        <div class="text-center border-top pt-3">
            <span>Đã nhớ lại mật khẩu? </span>
            <a href="${pageContext.request.contextPath}/login" class="text-success text-decoration-none fw-bold">Đăng nhập</a>
        </div>

        <div class="text-center mt-3">
            <a href="${pageContext.request.contextPath}/index.jsp" class="small text-secondary text-decoration-none">
                <i class="bi bi-arrow-left me-1"></i>Về trang chủ
            </a>
        </div>
    </div>

</body>
</html>
