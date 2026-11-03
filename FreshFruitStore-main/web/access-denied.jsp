<%-- 
    Document   : access-denied
    Description: Trang báo lỗi phân quyền (403 Forbidden) cho Module Auth & Phân quyền (Dev 1)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Không có quyền truy cập - FreshFruit Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="ff-auth-body d-flex flex-column">
    <jsp:include page="/includes/header.jsp" />

    <div class="container my-auto py-5">
        <div class="card ff-auth-card mx-auto p-4 p-md-5 text-center" style="max-width: 520px;">
            <div class="mx-auto mb-3 d-flex align-items-center justify-content-center rounded-circle bg-danger-subtle text-danger" style="width: 80px; height: 80px;">
                <i class="bi bi-shield-lock-fill fs-1"></i>
            </div>
            <span class="badge bg-danger-subtle text-danger mx-auto mb-2 px-3 py-1 rounded-pill">HTTP 403 - Forbidden</span>
            <h3 class="fw-bold text-dark mb-2">Truy Cập Bị Từ Chối</h3>
            <p class="text-secondary mb-4">
                Tài khoản của bạn không có quyền quản trị viên (<strong>Admin</strong>) để truy cập vào khu vực này. Vui lòng đăng nhập bằng tài khoản có thẩm quyền.
            </p>
            <div class="d-flex justify-content-center gap-3">
                <a href="${pageContext.request.contextPath}/shop.jsp" class="btn btn-outline-secondary px-4">
                    <i class="bi bi-shop me-1"></i>Về Cửa hàng
                </a>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-success px-4">
                    <i class="bi bi-box-arrow-in-right me-1"></i>Đăng nhập Admin
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />
</body>
</html>
