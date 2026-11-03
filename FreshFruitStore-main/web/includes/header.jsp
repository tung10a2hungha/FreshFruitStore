<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Common Header / Navbar (Dev 1 - Auth & Navigation) -->
<nav class="navbar navbar-expand-lg ff-navbar sticky-top py-3">
    <div class="container">
        <a class="navbar-brand ff-brand" href="${pageContext.request.contextPath}/index.jsp">
            <span class="brand-badge"><i class="bi bi-basket2-fill"></i></span>
            <span>FreshFruit Store</span>
        </a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#ffNavbarContent">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="ffNavbarContent">
            <ul class="navbar-nav mx-auto mb-2 mb-lg-0 gap-1">
                <li class="nav-item">
                    <a class="nav-link ff-nav-link" href="${pageContext.request.contextPath}/index.jsp">
                        <i class="bi bi-house-door me-1"></i>Trang chủ
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ff-nav-link" href="${pageContext.request.contextPath}/shop">
                        <i class="bi bi-shop me-1"></i>Cửa hàng
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ff-nav-link" href="${pageContext.request.contextPath}/cart">
                        <i class="bi bi-cart3 me-1"></i>Giỏ hàng
                        <c:if test="${not empty sessionScope.cart && sessionScope.cart.totalQuantity > 0}">
                            <span class="badge bg-danger rounded-pill">${sessionScope.cart.totalQuantity}</span>
                        </c:if>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ff-nav-link" href="${pageContext.request.contextPath}/checkout.jsp">
                        <i class="bi bi-credit-card-2-front me-1"></i>Thanh toán
                    </a>
                </li>
                <c:if test="${not empty sessionScope.account}">
                    <li class="nav-item">
                        <a class="nav-link ff-nav-link" href="${pageContext.request.contextPath}/my-orders">
                            <i class="bi bi-clock-history me-1"></i>Đơn hàng của tôi
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ff-nav-link" href="${pageContext.request.contextPath}/profile">
                            <i class="bi bi-person-vcard me-1"></i>Thông tin cá nhân
                        </a>
                    </li>
                </c:if>
                <c:if test="${sessionScope.account != null && (sessionScope.account.role == 'Admin' || sessionScope.account.role == 'admin')}">
                    <li class="nav-item dropdown">
                        <a class="nav-link ff-nav-link dropdown-toggle text-danger" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="bi bi-shield-lock me-1"></i>Quản trị (Admin)
                        </a>
                        <ul class="dropdown-menu shadow border-0 rounded-3">
                            <li>
                                <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/dashboard">
                                    <i class="bi bi-speedometer2 me-2 text-primary"></i>Dashboard (Tổng quan)
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/orders">
                                    <i class="bi bi-receipt me-2 text-success"></i>Quản lý Đơn hàng
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/products">
                                    <i class="bi bi-apple me-2 text-warning"></i>Quản lý Sản phẩm
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/users">
                                    <i class="bi bi-people-fill me-2 text-danger"></i>Quản lý Tài khoản
                                </a>
                            </li>
                        </ul>
                    </li>
                </c:if>
            </ul>

            <div class="d-flex align-items-center gap-2">
                <!-- Nút Giỏ hàng nhanh -->
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-success position-relative rounded-pill px-3">
                    <i class="bi bi-cart3 me-1"></i>
                    <span class="d-none d-sm-inline">Giỏ</span>
                    <c:if test="${not empty sessionScope.cart && sessionScope.cart.totalQuantity > 0}">
                        <span class="badge bg-danger rounded-pill ms-1">${sessionScope.cart.totalQuantity}</span>
                    </c:if>
                </a>

                <!-- Khu vực Tài khoản & Phân quyền (Dev 1) -->
                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <div class="dropdown">
                            <button class="btn btn-success dropdown-toggle rounded-pill px-3" type="button" data-bs-toggle="dropdown">
                                <i class="bi bi-person-circle me-1"></i>
                                <c:out value="${not empty sessionScope.account.fullName ? sessionScope.account.fullName : sessionScope.account.username}" />
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3" style="min-width: 240px;">
                                <!-- Tóm tắt nhanh thông tin tài khoản đang đăng nhập -->
                                <li class="px-3 py-2 border-bottom">
                                    <div class="fw-bold text-dark">
                                        <c:out value="${not empty sessionScope.account.fullName ? sessionScope.account.fullName : sessionScope.account.username}" />
                                    </div>
                                    <div class="small text-secondary mb-1">@${sessionScope.account.username}</div>
                                    <span class="badge bg-success-subtle text-success border border-success-subtle">
                                        ${sessionScope.account.role}
                                    </span>
                                </li>

                                <!-- Các chức năng tài khoản dành cho Khách hàng -->
                                <li>
                                    <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/my-orders">
                                        <i class="bi bi-clock-history me-2 text-primary"></i>Lịch sử mua hàng
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/profile">
                                        <i class="bi bi-person-vcard me-2 text-success"></i>Xem chi tiết thông tin khách hàng
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/shop.jsp">
                                        <i class="bi bi-basket2 me-2 text-success"></i>Mua sắm hoa quả
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/checkout.jsp">
                                        <i class="bi bi-bag-check me-2 text-success"></i>Thanh toán đơn hàng
                                    </a>
                                </li>

                                <!-- Chỉ hiển thị thêm tùy chọn Quản trị nếu là Admin -->
                                <c:if test="${sessionScope.account.role == 'Admin' || sessionScope.account.role == 'admin'}">
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/dashboard">
                                            <i class="bi bi-speedometer2 me-2 text-danger"></i>Dashboard Báo Cáo (Admin)
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/orders">
                                            <i class="bi bi-receipt me-2 text-danger"></i>Quản lý Đơn hàng (Admin)
                                        </a>
                                    </li>
                                        </a>
                                    </li>
                                </c:if>

                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item py-2 text-danger fw-semibold" href="${pageContext.request.contextPath}/logout">
                                        <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-success rounded-pill px-3">
                            Đăng nhập
                        </a>
                        <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-success rounded-pill px-3">
                            Đăng ký
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
