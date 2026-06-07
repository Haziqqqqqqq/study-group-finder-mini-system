<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="header.jsp" />

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold"><i class="bi bi-collection text-success me-2"></i>Group Administration</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Groups</li>
                </ol>
            </nav>
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
            <c:choose>
                <c:when test="${param.msg == 'deleted'}">Study group successfully deleted.</c:when>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card shadow-sm border-0 rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-striped mb-0 align-middle">
                    <thead class="table-success">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Group Name</th>
                            <th>Subject & Course</th>
                            <th>Creator</th>
                            <th>Members</th>
                            <th>Created On</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="g" items="${groups}">
                            <tr>
                                <td class="ps-4 fw-bold text-muted">#${g.groupId}</td>
                                <td class="fw-bold">
                                    <a href="${pageContext.request.contextPath}/groups?action=detail&id=${g.groupId}" class="text-decoration-none">
                                        ${g.groupName}
                                    </a>
                                </td>
                                <td>
                                    <div class="small fw-bold">${g.courseCode}</div>
                                    <div class="small text-muted">${g.subject}</div>
                                </td>
                                <td><i class="bi bi-person-fill text-muted me-1"></i>${g.creatorName}</td>
                                <td>${g.memberCount} / ${g.capacity}</td>
                                <td>${g.createdAt.substring(0, 10)}</td>
                                <td class="text-end pe-4">
                                    <form action="${pageContext.request.contextPath}/admin" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to permanently delete this group? All sessions and posts will be lost.');">
                                        <input type="hidden" name="action" value="deleteGroup">
                                        <input type="hidden" name="group_id" value="${g.groupId}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i> Delete</button>
                                    </form>
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
