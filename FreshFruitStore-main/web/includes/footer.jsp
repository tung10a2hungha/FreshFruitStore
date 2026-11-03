<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Common Footer -->
<footer class="ff-footer mt-5">
    <div class="container">
        <div class="row g-4 pb-4 border-bottom border-secondary border-opacity-25">
            <div class="col-lg-5">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <span class="badge bg-success p-2 rounded-3"><i class="bi bi-basket2-fill fs-5"></i></span>
                    <h5 class="text-white fw-bold mb-0">FreshFruit Store</h5>
                </div>
                <p class="small text-secondary mb-3">
                    Website thương mại điện tử chuyên cung ứng và phân phối hoa quả tươi trực tuyến.
                </p>
            </div>

            <div class="col-6 col-lg-3">
                <h6 class="text-white fw-bold mb-3">Điều hướng</h6>
                <ul class="list-unstyled small d-flex flex-column gap-2">
                    <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/shop.jsp">Cửa hàng trái cây</a></li>
                    <li><a href="${pageContext.request.contextPath}/checkout.jsp">Thanh toán</a></li>
                </ul>
            </div>

            <div class="col-6 col-lg-4">
                <h6 class="text-white fw-bold mb-3">Tài khoản</h6>
                <ul class="list-unstyled small d-flex flex-column gap-2">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account}">
                            <li><a href="${pageContext.request.contextPath}/profile">Xem thông tin cá nhân</a></li>
                            <li><a href="${pageContext.request.contextPath}/my-orders">Lịch sử mua hàng</a></li>
                            <c:if test="${sessionScope.account.role == 'Admin' || sessionScope.account.role == 'admin'}">
                                <li><a href="${pageContext.request.contextPath}/admin/users">Quản lý Tài khoản (Admin)</a></li>
                                <li><a href="${pageContext.request.contextPath}/admin-order.jsp">Quản lý Đơn hàng (Admin)</a></li>
                            </c:if>
                            <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Đăng nhập</a></li>
                            <li><a href="${pageContext.request.contextPath}/register.jsp">Đăng ký tài khoản</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>

        <div class="d-flex flex-wrap justify-content-between align-items-center pt-3 small text-secondary">
            <span>&copy; 2026 FreshFruit Store - PRJ301 Project.</span>
            <span>Hỗ trợ thanh toán: COD &bull; VietQR / VNPay</span>
        </div>
    </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
