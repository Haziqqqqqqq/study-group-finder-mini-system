<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow border-0 rounded-3">
                <div class="card-header bg-primary text-white p-3">
                    <h4 class="mb-0"><i class="bi bi-calendar-plus me-2"></i>Schedule Study Session</h4>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/sessions" method="POST">
                        <input type="hidden" name="action" value="create">
                        <input type="hidden" name="group_id" value="${param.groupId}">

                        <div class="mb-3">
                            <label class="form-label fw-bold">Topic / Title</label>
                            <input type="text" name="session_title" class="form-control" required placeholder="e.g. Chapter 3 Review">
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Date</label>
                                <input type="date" name="session_date" class="form-control" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Time</label>
                                <input type="time" name="session_time" class="form-control" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Duration (mins)</label>
                                <input type="number" name="duration_mins" class="form-control" value="60" min="15" step="15" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Physical Location (Optional)</label>
                            <input type="text" name="location" class="form-control" placeholder="e.g. Library Room 4">
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold">Online Meeting Link (Optional)</label>
                            <input type="url" name="meeting_link" class="form-control" placeholder="https://zoom.us/j/123...">
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/groups?action=detail&id=${param.groupId}" class="btn btn-light border">Cancel</a>
                            <button type="submit" class="btn btn-primary px-4"><i class="bi bi-calendar-check me-2"></i>Schedule</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
