<%@ page contentType="text/html;charset=UTF-8" import="model.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }
%>
<%@ include file="header.jsp" %>

<div class="container py-4" style="max-width: 800px;">
    
    <div class="mb-4">
        <a href="<%= ctx %>/groups?action=my" class="text-primary text-decoration-none fw-medium mb-3 d-inline-block">
            <i class="bi bi-arrow-left me-1"></i> Back
        </a>
        <h2 class="fw-bold text-dark mb-1">Create a Study Group</h2>
        <p class="text-muted">Start your own study group and invite others to join</p>
    </div>

    <div class="simple-card p-4 p-md-5">
        <form action="<%= ctx %>/groups" method="POST">
            <input type="hidden" name="action" value="create">

            <div class="mb-4">
                <label class="form-label text-dark fw-medium">Group Name *</label>
                <input type="text" name="group_name" class="form-control form-control-lg bg-light bg-opacity-50" placeholder="e.g., Advanced Calculus Study Group" required>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-6">
                    <label class="form-label text-dark fw-medium">Subject *</label>
                    <input type="text" name="subject" class="form-control form-control-lg bg-light bg-opacity-50" placeholder="e.g., Mathematics" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label text-dark fw-medium">Course Code *</label>
                    <input type="text" name="course_code" class="form-control form-control-lg bg-light bg-opacity-50" placeholder="e.g., MATH 301" required>
                </div>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-6">
                    <label class="form-label text-dark fw-medium">Academic Year *</label>
                    <select name="academic_year" class="form-select form-select-lg bg-light bg-opacity-50" required>
                        <option value="Year 1">Year 1</option>
                        <option value="Year 2">Year 2</option>
                        <option value="Year 3">Year 3</option>
                        <option value="Year 4">Year 4</option>
                        <option value="Postgraduate">Postgraduate</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label text-dark fw-medium">Max Capacity *</label>
                    <input type="number" name="capacity" class="form-control form-control-lg bg-light bg-opacity-50" value="15" min="2" max="50" required>
                </div>
            </div>

            <div class="mb-5">
                <label class="form-label text-dark fw-medium">Description *</label>
                <textarea name="description" class="form-control form-control-lg bg-light bg-opacity-50" rows="4" placeholder="Describe what your study group is about, meeting frequency, and what members can expect..." required></textarea>
            </div>

            <div class="text-end">
                <button type="submit" class="btn btn-primary btn-lg px-5 fw-semibold">Create Group</button>
            </div>
        </form>
    </div>

</div>

<%@ include file="footer.jsp" %>
