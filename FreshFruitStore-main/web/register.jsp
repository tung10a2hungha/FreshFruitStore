<%-- 
    Document   : register
    Description: Trang Đăng Ký Tài Khoản Khách Hàng (Mã hóa mật khẩu an toàn SHA-256)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light ff-auth-body d-flex flex-column justify-content-center align-items-center" style="min-height: 100vh; padding: 40px 16px;">
    
    <!-- Logo về trang chủ -->
    <div class="mb-3 text-center">
        <a href="${pageContext.request.contextPath}/index.jsp" class="ff-brand text-decoration-none">
            <span class="brand-badge"><i class="bi bi-basket2-fill"></i></span>
            <span>FreshFruit Store</span>
        </a>
    </div>

    <div class="card ff-auth-card shadow p-4 p-md-5" style="width: 100%; max-width: 520px;">
        <div class="text-center mb-2">
            <span class="badge bg-success-subtle text-success rounded-pill px-3 py-2 mb-2">
                <i class="bi bi-stars me-1"></i>Thành viên mới
            </span>
        </div>
        <h3 class="text-center text-success fw-bold mb-4">Tạo Tài Khoản Khách Hàng</h3>
        
        <form action="${pageContext.request.contextPath}/register" method="post">
            <div class="mb-3">
                <label class="form-label fw-bold"><i class="bi bi-person text-success me-1"></i>Tên đăng nhập <span class="text-danger">*</span></label>
                <input type="text" class="form-control" name="username" placeholder="Nhập tên tài khoản (viết liền, không dấu)" required />
            </div>
            
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold"><i class="bi bi-key text-success me-1"></i>Mật khẩu <span class="text-danger">*</span></label>
                    <input type="password" class="form-control" name="password" placeholder="Mật khẩu bí mật" required />
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold"><i class="bi bi-check-circle text-success me-1"></i>Xác nhận MK <span class="text-danger">*</span></label>
                    <input type="password" class="form-control" name="confirmPassword" placeholder="Nhập lại mật khẩu" required />
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold"><i class="bi bi-card-heading text-success me-1"></i>Họ và tên <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="fullname" placeholder="Ví dụ: Nguyễn Văn A" required />
                </div>
                
                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold"><i class="bi bi-telephone text-success me-1"></i>Số điện thoại <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="phone" placeholder="Ví dụ: 0912345678" required />
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold"><i class="bi bi-envelope text-success me-1"></i>Địa chỉ Email</label>
                <input type="email" class="form-control" name="email" placeholder="Ví dụ: customer@gmail.com" />
            </div>
            
            <div class="mb-3">
                <label class="form-label fw-bold"><i class="bi bi-geo-alt text-success me-1"></i>Địa chỉ nhận hàng mặc định <span class="text-danger">*</span></label>
                <textarea class="form-control" name="address" rows="2" placeholder="Số nhà, Đường, Phường/Xã, Quận/Huyện..." required></textarea>
            </div>
            
            <!-- Hiển thị báo lỗi nếu có -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger py-2 small text-center mb-3">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i>${error}
                </div>
            </c:if>
            
            <button type="submit" class="btn btn-success w-100 py-2 mb-3 shadow-sm fw-bold">
                <i class="bi bi-person-plus-fill me-1"></i>Đăng Ký Tài Khoản
            </button>
        </form>
        
        <!-- Nút quay lại trang đăng nhập -->
        <div class="text-center border-top pt-3">
            <span>Đã có tài khoản? </span>
            <a href="${pageContext.request.contextPath}/login.jsp" class="text-success text-decoration-none fw-bold">Đăng nhập ngay</a>
        </div>
    </div>

</body>
</html>
