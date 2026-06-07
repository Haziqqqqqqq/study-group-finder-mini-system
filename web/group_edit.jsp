<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow-lg border-0 rounded-4">
                <div class="card-header bg-primary text-white p-4 rounded-top-4 d-flex justify-content-between align-items-center">
                    <h3 class="mb-0"><i class="bi bi-pencil-square me-2"></i>Edit Group Settings</h3>
                </div>
                <div class="card-body p-5">
                    <form action="${pageContext.request.contextPath}/groups" method="POST">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="group_id" value="${group.groupId}">

                        <div class="row g-4">
                            <div class="col-12">
                                <label class="form-label fw-bold">Group Name</label>
                                <input type="text" name="group_name" class="form-control form-control-lg" required value="${group.groupName}">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Course Code</label>
                                <input type="text" name="course_code" class="form-control" required value="${group.courseCode}">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Subject</label>
                                <input type="text" name="subject" class="form-control" required value="${group.subject}">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Meeting Type</label>
                                <select name="meeting_type" class="form-select">
                                    <option value="Online" ${group.meetingType == 'Online' ? 'selected' : ''}>Online</option>
                                    <option value="Physical" ${group.meetingType == 'Physical' ? 'selected' : ''}>Physical</option>
                                    <option value="Hybrid" ${group.meetingType == 'Hybrid' ? 'selected' : ''}>Hybrid</option>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Member Capacity</label>
                                <input type="number" name="capacity" class="form-control" min="${group.memberCount}" max="50" required value="${group.capacity}">
                                <div class="form-text text-danger">Cannot be less than current member count (${group.memberCount}).</div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Description</label>
                                <textarea name="description" class="form-control" rows="4">${group.description}</textarea>
                            </div>

                            <div class="col-12 mt-5">
                                <div class="d-flex justify-content-between">
                                    <a href="${pageContext.request.contextPath}/groups?action=detail&id=${group.groupId}" class="btn btn-light border btn-lg px-4">Cancel</a>
                                    <button type="submit" class="btn btn-primary btn-lg px-5 shadow-sm">Save Changes</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- Danger Zone -->
            <div class="card border-danger mt-5 shadow-sm rounded-4">
                <div class="card-body p-4 text-center">
                    <h5 class="text-danger fw-bold"><i class="bi bi-exclamation-triangle-fill me-2"></i>Danger Zone</h5>
                    <p class="text-muted">Deleting this group will permanently remove all discussions, sessions, and member data.</p>
                    <form action="${pageContext.request.contextPath}/groups" method="POST" onsubmit="return confirm('WARNING: This action is irreversible. Are you absolutely sure you want to delete this group?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="group_id" value="${group.groupId}">
                        <button type="submit" class="btn btn-danger"><i class="bi bi-trash-fill me-1"></i>Delete Group Permanently</button>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
