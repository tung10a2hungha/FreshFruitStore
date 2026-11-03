<%-- 
    Document   : admin-product
    Description: Dashboard Admin Quản lý Danh mục & Sản phẩm Hoa Quả (Bước 1)
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Quản Lý Sản Phẩm & Danh Mục - FreshFruit</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">
    <!-- Navbar Admin -->
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
                <a class="nav-link active fw-bold text-success" href="${pageContext.request.contextPath}/admin/products">
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
        <!-- Thông báo flash -->
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

        <div class="row g-4">
            <!-- CỘT TRÁI: QUẢN LÝ DANH MỤC -->
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm p-4 rounded-4 bg-white mb-4">
                    <h5 class="fw-bold text-success mb-3"><i class="bi bi-folder-plus me-2"></i>Thêm Danh Mục Mới</h5>
                    <form action="${pageContext.request.contextPath}/admin/products" method="post">
                        <input type="hidden" name="action" value="add-category">
                        <div class="input-group mb-3">
                            <input type="text" name="categoryName" class="form-control" placeholder="Tên danh mục mới" required>
                            <button type="submit" class="btn btn-success"><i class="bi bi-plus-lg"></i> Thêm</button>
                        </div>
                    </form>

                    <h6 class="fw-bold text-dark mt-4 mb-2"><i class="bi bi-list-ul me-2"></i>Danh Sách Danh Mục</h6>
                    <div class="table-responsive">
                        <table class="table table-sm table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã</th>
                                    <th>Tên danh mục</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${listCategory}" var="c">
                                    <tr>
                                        <td>#${c.categoryId}</td>
                                        <td><strong>${c.categoryName}</strong></td>
                                        <td class="text-end">
                                            <form action="${pageContext.request.contextPath}/admin/products" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa danh mục này?');">
                                                <input type="hidden" name="action" value="delete-category">
                                                <input type="hidden" name="categoryId" value="${c.categoryId}">
                                                <button type="submit" class="btn btn-outline-danger btn-sm py-0 px-2"><i class="bi bi-trash"></i></button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- CỘT PHẢI: QUẢN LÝ SẢN PHẨM -->
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm p-4 rounded-4 bg-white mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-success mb-0"><i class="bi bi-apple me-2"></i>Danh Sách Trái Cây Đang Bán</h5>
                        <button class="btn btn-success rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#addProductModal">
                            <i class="bi bi-plus-circle me-1"></i>Thêm Sản Phẩm Mới
                        </button>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-success">
                                <tr>
                                    <th>Ảnh</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Danh mục</th>
                                    <th>Giá bán</th>
                                    <th>Kho</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${listProduct}" var="p">
                                    <tr>
                                        <td>
                                            <img src="${p.imageUrl}" alt="${p.productName}" class="rounded-3 shadow-sm" style="width: 52px; height: 52px; object-fit: cover;" onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=100&q=80';">
                                        </td>
                                        <td>
                                            <div class="fw-bold text-dark">${p.productName}</div>
                                            <small class="text-secondary">#${p.productId}</small>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark border">${p.categoryName}</span>
                                        </td>
                                        <td class="text-danger fw-bold">
                                            <fmt:formatNumber value="${p.price}" pattern="#,###" /> đ / ${p.unit}
                                        </td>
                                        <td>
                                            <span class="badge ${p.stockQuantity > 0 ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'}">
                                                ${p.stockQuantity} ${p.unit}
                                            </span>
                                        </td>
                                        <td>
                                            <form action="${pageContext.request.contextPath}/admin/products" method="post" class="d-inline">
                                                <input type="hidden" name="action" value="toggle-status">
                                                <input type="hidden" name="productId" value="${p.productId}">
                                                <input type="hidden" name="currentStatus" value="${p.status}">
                                                <button type="submit" class="badge border-0 ${p.status ? 'bg-success' : 'bg-secondary'}" style="cursor: pointer;">
                                                    ${p.status ? 'Đang bán' : 'Tạm ẩn'}
                                                </button>
                                            </form>
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-outline-primary btn-sm me-1" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#editProductModal${p.productId}">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <form action="${pageContext.request.contextPath}/admin/products" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc muốn xóa sản phẩm này?');">
                                                <input type="hidden" name="action" value="delete-product">
                                                <input type="hidden" name="productId" value="${p.productId}">
                                                <button type="submit" class="btn btn-outline-danger btn-sm"><i class="bi bi-trash"></i></button>
                                            </form>
                                        </td>
                                    </tr>

                                    <!-- Modal Sửa Sản Phẩm -->
                                    <div class="modal fade" id="editProductModal${p.productId}" tabindex="-1">
                                        <div class="modal-dialog modal-lg">
                                            <div class="modal-content">
                                                <form action="${pageContext.request.contextPath}/admin/products" method="post">
                                                    <input type="hidden" name="action" value="edit-product">
                                                    <input type="hidden" name="productId" value="${p.productId}">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title fw-bold text-success">Sửa Sản Phẩm #${p.productId}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="row g-3">
                                                            <div class="col-md-8">
                                                                <label class="form-label fw-semibold">Tên trái cây</label>
                                                                <input type="text" name="productName" value="${p.productName}" class="form-control" required>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label fw-semibold">Danh mục</label>
                                                                <select name="categoryId" class="form-select" required>
                                                                    <c:forEach items="${listCategory}" var="c">
                                                                        <option value="${c.categoryId}" ${c.categoryId == p.categoryId ? 'selected' : ''}>${c.categoryName}</option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label fw-semibold">Đơn giá (VNĐ)</label>
                                                                <input type="number" step="1000" name="price" value="${p.price}" class="form-control" required>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label fw-semibold">Đơn vị tính</label>
                                                                <input type="text" name="unit" value="${p.unit}" class="form-control" placeholder="kg, hộp, quả" required>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label fw-semibold">Tồn kho</label>
                                                                <input type="number" name="stockQuantity" value="${p.stockQuantity}" class="form-control" required>
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label fw-semibold">Đường dẫn ảnh (URL)</label>
                                                                <input type="text" name="imageUrl" value="${p.imageUrl}" class="form-control">
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label fw-semibold">Mô tả sản phẩm</label>
                                                                <textarea name="description" class="form-control" rows="3">${p.description}</textarea>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-success">Lưu thay đổi</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Thêm Sản Phẩm Mới -->
    <div class="modal fade" id="addProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/products" method="post">
                    <input type="hidden" name="action" value="add-product">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title fw-bold"><i class="bi bi-plus-circle me-2"></i>Thêm Mới Trái Cây</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-8">
                                <label class="form-label fw-semibold">Tên trái cây</label>
                                <input type="text" name="productName" class="form-control" placeholder="Ví dụ: Xoài Cát Hòa Lộc" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Danh mục</label>
                                <select name="categoryId" class="form-select" required>
                                    <c:forEach items="${listCategory}" var="c">
                                        <option value="${c.categoryId}">${c.categoryName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Đơn giá (VNĐ)</label>
                                <input type="number" step="1000" name="price" class="form-control" placeholder="Ví dụ: 85000" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Đơn vị tính</label>
                                <input type="text" name="unit" class="form-control" placeholder="kg, hộp, giỏ..." value="kg" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Số lượng tồn kho</label>
                                <input type="number" name="stockQuantity" class="form-control" value="50" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Đường dẫn ảnh (URL)</label>
                                <input type="text" name="imageUrl" class="form-control" placeholder="https://images.unsplash.com/photo-...">
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Mô tả sản phẩm</label>
                                <textarea name="description" class="form-control" rows="3" placeholder="Mô tả nguồn gốc VietGAP, độ ngọt, chất lượng..."></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-success"><i class="bi bi-save me-1"></i>Lưu Sản Phẩm</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
