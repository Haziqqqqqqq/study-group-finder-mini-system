<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="header.jsp" />

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold"><i class="bi bi-people text-primary me-2"></i>User Management</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Users</li>
                </ol>
            </nav>
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
            <c:choose>
                <c:when test="${param.msg == 'deleted'}">User account successfully deleted.</c:when>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card shadow-sm border-0 rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-striped mb-0 align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>University / Major</th>
                            <th>Registered On</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${users}">
                            <tr>
                                <td class="ps-4 fw-bold text-muted">#${u.userId}</td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-2" style="width: 32px; height: 32px;">
                                            ${u.fullName.substring(0, 1).toUpperCase()}
                                        </div>
                                        <span class="fw-bold">${u.fullName}</span>
                                    </div>
                                </td>
                                <td><a href="mailto:${u.email}">${u.email}</a></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.role == 'admin'}"><span class="badge bg-danger">Admin</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary">Student</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="small">${u.university}</div>
                                    <div class="small text-muted">${u.major}</div>
                                </td>
                                <td>${u.createdAt.substring(0, 10)}</td>
                                <td class="text-end pe-4">
                                    <c:if test="${u.role != 'admin'}">
                                        <form action="${pageContext.request.contextPath}/admin" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to permanently delete this user?');">
                                            <input type="hidden" name="action" value="deleteUser">
                                            <input type="hidden" name="user_id" value="${u.userId}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i> Delete</button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
