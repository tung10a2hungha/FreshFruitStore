<%-- 
    Document   : reset-password
    Description: Trang đặt lại mật khẩu mới sau khi xác thực OTP thành công
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - FreshFruit Store</title>
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
                <i class="bi bi-key-fill me-1"></i>Bước cuối cùng
            </span>
        </div>
        <h3 class="text-center text-success fw-bold mb-2">Đặt Lại Mật Khẩu</h3>
        <p class="text-center text-muted small mb-4">
            Thiết lập mật khẩu mới cho tài khoản: <strong class="text-dark">${sessionScope.fpUsername}</strong>
        </p>

        <!-- Thông báo lỗi nếu có -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger py-2 small text-center mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i>${error}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="post" id="resetPasswordForm">
            <input type="hidden" name="action" value="reset-password" />
            
            <div class="mb-3">
                <label class="form-label small fw-semibold text-secondary">Mật khẩu mới</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-success"><i class="bi bi-lock"></i></span>
                    <input type="password" class="form-control border-start-0 border-end-0" id="newPassword" 
                           name="newPassword" placeholder="Nhập ít nhất 6 ký tự" minlength="6" required autofocus />
                    <button class="btn btn-outline-secondary border-start-0 bg-light" type="button" onclick="togglePass('newPassword', 'iconNew')">
                        <i class="bi bi-eye" id="iconNew"></i>
                    </button>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label small fw-semibold text-secondary">Xác nhận mật khẩu mới</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-success"><i class="bi bi-shield-check"></i></span>
                    <input type="password" class="form-control border-start-0 border-end-0" id="confirmPassword" 
                           name="confirmPassword" placeholder="Nhập lại mật khẩu mới" minlength="6" required />
                    <button class="btn btn-outline-secondary border-start-0 bg-light" type="button" onclick="togglePass('confirmPassword', 'iconConfirm')">
                        <i class="bi bi-eye" id="iconConfirm"></i>
                    </button>
                </div>
                <div id="matchError" class="small text-danger mt-1" style="display: none;">
                    <i class="bi bi-x-circle me-1"></i>Mật khẩu xác nhận không khớp!
                </div>
            </div>
            
            <button type="submit" class="btn btn-success w-100 py-2 mb-3 shadow-sm fw-bold">
                <i class="bi bi-check-lg me-1"></i>Lưu Mật Khẩu Mới
            </button>
        </form>

        <div class="text-center border-top pt-3">
            <a href="${pageContext.request.contextPath}/login" class="small text-secondary text-decoration-none">
                <i class="bi bi-arrow-left me-1"></i>Hủy bỏ & Quay lại Đăng nhập
            </a>
        </div>
    </div>

    <script>
        function togglePass(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove("bi-eye");
                icon.classList.add("bi-eye-slash");
            } else {
                input.type = "password";
                icon.classList.remove("bi-eye-slash");
                icon.classList.add("bi-eye");
            }
        }

        document.getElementById('resetPasswordForm').addEventListener('submit', function(e) {
            const p1 = document.getElementById('newPassword').value;
            const p2 = document.getElementById('confirmPassword').value;
            const err = document.getElementById('matchError');
            if (p1 !== p2) {
                e.preventDefault();
                err.style.display = 'block';
            } else {
                err.style.display = 'none';
            }
        });
    </script>

</body>
</html>
