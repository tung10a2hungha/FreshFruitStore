<%-- 
    Document   : admin-user
    Description: Trang Admin Quản lý Tài khoản & Khóa/Mở khóa tài khoản (Module Dev 1)
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Kiểm tra phân quyền bắt buộc: Chỉ tài khoản Admin đã đăng nhập mới được truy cập
    model.User currentAccount = (model.User) session.getAttribute("account");
    if (currentAccount == null) {
        request.setAttribute("error", "Vui lòng đăng nhập bằng tài khoản Admin để truy cập khu vực Quản trị!");
        request.getRequestDispatcher("/login.jsp").forward(request, response);
        return;
    }
    if (currentAccount.getRole() == null || !currentAccount.getRole().trim().equalsIgnoreCase("Admin")) {
        request.getRequestDispatcher("/access-denied.jsp").forward(request, response);
        return;
    }

    // Tự động nạp dữ liệu thực tế nếu Admin mở trực tiếp admin-user.jsp mà chưa đi qua /admin/users
    if (request.getAttribute("listUser") == null
            && request.getParameter("keyword") == null
            && request.getParameter("role") == null
            && request.getParameter("status") == null) {
        dal.UserDAO dao = new dal.UserDAO();
        java.util.List<model.User> users = dao.getAllUsers();
        int active = 0, locked = 0, admins = 0;
        for (model.User u : users) {
            if (u.isLocked()) {
                locked++;
            } else {
                active++;
            }
            if (u.getRole() != null && u.getRole().equalsIgnoreCase("Admin")) {
                admins++;
            }
        }
        request.setAttribute("listUser", users);
        request.setAttribute("totalCount", users.size());
        request.setAttribute("activeCount", active);
        request.setAttribute("lockedCount", locked);
        request.setAttribute("adminCount", admins);
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Quản lý Tài khoản - FreshFruit</title>
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
                <a class="nav-link" href="${pageContext.request.contextPath}/admin/orders">
                    <i class="bi bi-receipt me-1"></i>Quản lý Đơn hàng
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/admin/products">
                    <i class="bi bi-apple me-1"></i>Quản lý Sản phẩm
                </a>
                <a class="nav-link active fw-bold text-success" href="${pageContext.request.contextPath}/admin/users">
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
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-box-arrow-right me-1"></i>Đăng xuất
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid px-4 pb-5">
        <!-- Thống kê nhanh Tài khoản (Cập nhật động theo dữ liệu thực) -->
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="card ff-admin-stat-card p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-secondary small fw-semibold">Tổng Tài khoản</div>
                            <h4 class="fw-bold mb-0">${not empty totalCount ? totalCount : listUser.size()} tài khoản</h4>
                        </div>
                        <div class="ff-stat-icon bg-primary-subtle text-primary"><i class="bi bi-people-fill"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card ff-admin-stat-card p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-secondary small fw-semibold">Đang hoạt động</div>
                            <h4 class="fw-bold text-success mb-0">${not empty activeCount ? activeCount : 0} tài khoản</h4>
                        </div>
                        <div class="ff-stat-icon bg-success-subtle text-success"><i class="bi bi-person-check-fill"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card ff-admin-stat-card p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-secondary small fw-semibold">Đã bị khóa</div>
                            <h4 class="fw-bold text-danger mb-0">${not empty lockedCount ? lockedCount : 0} tài khoản</h4>
                        </div>
                        <div class="ff-stat-icon bg-danger-subtle text-danger"><i class="bi bi-person-lock"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card ff-admin-stat-card p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-secondary small fw-semibold">Quản trị viên (Admin)</div>
                            <h4 class="fw-bold text-dark mb-0">${not empty adminCount ? adminCount : 1} Admin</h4>
                        </div>
                        <div class="ff-stat-icon bg-warning-subtle text-warning"><i class="bi bi-shield-lock-fill"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Thanh lọc & tìm kiếm tài khoản -->
        <div class="ff-filter-bar mb-4">
            <form action="${pageContext.request.contextPath}/admin/users" method="get" class="row g-3 align-items-end">
                <div class="col-md-5">
                    <label class="form-label small fw-bold text-secondary mb-1">
                        <i class="bi bi-search text-success me-1"></i>Tìm kiếm tài khoản
                    </label>
                    <input type="text" name="keyword" value="${param.keyword}" class="form-control" placeholder="Nhập username, họ tên hoặc số điện thoại...">
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-bold text-secondary mb-1">Vai trò (Role)</label>
                    <select name="role" class="form-select">
                        <option value="">-- Tất cả vai trò --</option>
                        <option value="Admin" ${param.role == 'Admin' ? 'selected' : ''}>Admin (Quản trị)</option>
                        <option value="Customer" ${param.role == 'Customer' ? 'selected' : ''}>Customer (Khách hàng)</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small fw-bold text-secondary mb-1">Trạng thái</label>
                    <select name="status" class="form-select">
                        <option value="">-- Tất cả --</option>
                        <option value="active" ${param.status == 'active' ? 'selected' : ''}>Đang hoạt động</option>
                        <option value="locked" ${param.status == 'locked' ? 'selected' : ''}>Đã khóa</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-success w-100">
                        <i class="bi bi-funnel-fill me-1"></i>Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary" title="Làm mới">
                        <i class="bi bi-arrow-counterclockwise"></i>
                    </a>
                </div>
            </form>
        </div>

        <!-- Thông báo kết quả Khóa / Mở khóa -->
        <c:if test="${not empty message}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-3" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i><strong>${message}</strong>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 mb-3" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>${error}</strong>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Bảng Danh sách Tài khoản & Khóa/Mở khóa -->
        <div class="card border-0 shadow-sm p-3 bg-white rounded-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold text-success mb-0">
                    <i class="bi bi-person-lines-fill me-2"></i>Danh sách Tài khoản Hệ thống
                </h5>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-success">
                        <tr>
                            <th>ID</th>
                            <th>Tên đăng nhập</th>
                            <th>Họ và tên</th>
                            <th>Số điện thoại</th>
                            <th>Địa chỉ</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động (Khóa / Mở khóa)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listUser}" var="u">
                            <tr class="${u.locked ? 'table-light text-muted' : ''}">
                                <td class="fw-bold">#${u.userId}</td>
                                <td class="fw-semibold text-dark">${u.username}</td>
                                <td>${not empty u.fullName ? u.fullName : '<span class="text-muted fst-italic">Chưa cập nhật</span>'}</td>
                                <td>${not empty u.phone ? u.phone : '-'}</td>
                                <td><small class="text-secondary">${not empty u.address ? u.address : '-'}</small></td>
                                <td>
                                    <span class="badge ${u.role == 'Admin' || u.role == 'admin' ? 'bg-danger' : 'bg-info text-dark'}">
                                        ${u.role}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.locked}">
                                            <span class="badge bg-danger">
                                                <i class="bi bi-slash-circle me-1"></i>Đã khóa
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-success">
                                                <i class="bi bi-check-circle me-1"></i>Hoạt động
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <c:choose>
                                        <c:when test="${u.role == 'Admin' || u.role == 'admin'}">
                                            <span class="badge bg-light text-secondary border">Tài khoản Admin</span>
                                        </c:when>
                                        <c:otherwise>
                                            <form action="${pageContext.request.contextPath}/admin/user/toggle-lock" method="post" class="d-inline">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <c:choose>
                                                    <c:when test="${u.locked}">
                                                        <input type="hidden" name="action" value="unlock">
                                                        <button type="submit" class="btn btn-success btn-sm">
                                                            <i class="bi bi-unlock-fill me-1"></i>Mở khóa
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <input type="hidden" name="action" value="lock">
                                                        <button type="submit" class="btn btn-outline-danger btn-sm">
                                                            <i class="bi bi-lock-fill me-1"></i>Khóa tài khoản
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty listUser}">
                            <tr>
                                <td colspan="8" class="text-center py-4 text-secondary">
                                    Không tìm thấy tài khoản nào phù hợp với điều kiện lọc.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
