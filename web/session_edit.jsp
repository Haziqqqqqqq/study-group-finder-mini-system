<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow border-0 rounded-3">
                <div class="card-header bg-primary text-white p-3">
                    <h4 class="mb-0"><i class="bi bi-pencil-square me-2"></i>Edit Study Session</h4>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/sessions" method="POST">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="session_id" value="${sessionData.sessionId}">
                        <input type="hidden" name="group_id" value="${sessionData.groupId}">

                        <div class="mb-3">
                            <label class="form-label fw-bold">Topic / Title</label>
                            <input type="text" name="session_title" class="form-control" required value="${sessionData.sessionTitle}">
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Date</label>
                                <input type="date" name="session_date" class="form-control" required value="${sessionData.sessionDate}">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Time</label>
                                <input type="time" name="session_time" class="form-control" required value="${sessionData.sessionTime}">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Duration (mins)</label>
                                <input type="number" name="duration_mins" class="form-control" min="15" step="15" required value="${sessionData.durationMins}">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Physical Location (Optional)</label>
                            <input type="text" name="location" class="form-control" value="${sessionData.location}">
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold">Online Meeting Link (Optional)</label>
                            <input type="url" name="meeting_link" class="form-control" value="${sessionData.meetingLink}">
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/groups?action=detail&id=${sessionData.groupId}" class="btn btn-light border">Cancel</a>
                            <button type="submit" class="btn btn-primary px-4">Save Changes</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Delete Button -->
            <div class="text-end mt-4">
                <form action="${pageContext.request.contextPath}/sessions" method="POST" onsubmit="return confirm('Are you sure you want to cancel and delete this session?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="session_id" value="${sessionData.sessionId}">
                    <input type="hidden" name="group_id" value="${sessionData.groupId}">
                    <button type="submit" class="btn btn-outline-danger btn-sm"><i class="bi bi-trash"></i> Cancel Session</button>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
