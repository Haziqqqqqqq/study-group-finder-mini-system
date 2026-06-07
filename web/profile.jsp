<%@ page contentType="text/html;charset=UTF-8" import="model.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }
%>
<%@ include file="header.jsp" %>

<div class="container py-4" style="max-width: 900px;">
    
    <div class="mb-4">
        <h2 class="fw-bold text-dark mb-1">Profile & Settings</h2>
        <p class="text-muted">Manage your account and preferences</p>
    </div>

    <div class="simple-card">
        
        <!-- Profile Inner Tabs -->
        <div class="border-bottom px-4 pt-3 d-flex gap-4">
            <div class="nav-tabs-link active border-bottom-0 pb-3 mb-0" style="border-bottom: 2px solid #2563eb !important;">Profile Information</div>
        </div>

        <div class="p-4 p-md-5">

            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success py-2 mb-4"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger py-2 mb-4"><%= request.getAttribute("error") %></div>
            <% } %>
            
            <div class="d-flex align-items-center mb-5">
                <div class="bg-primary text-white rounded-circle d-flex justify-content-center align-items-center me-4" style="width: 80px; height: 80px;">
                    <i class="bi bi-person fs-1"></i>
                </div>
                <div>
                    <h4 class="fw-bold text-dark mb-1"><%= user.getFullName() %></h4>
                    <p class="text-muted mb-0"><%= user.getEmail() %></p>
                </div>
            </div>

            <form action="<%= ctx %>/profile" method="POST">
                <input type="hidden" name="action" value="update">

                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <label class="form-label text-dark fw-medium small">Full Name</label>
                        <input type="text" name="full_name" class="form-control bg-light bg-opacity-50" value="<%= user.getFullName() %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label text-dark fw-medium small">Email Address</label>
                        <input type="email" class="form-control bg-light bg-opacity-50" value="<%= user.getEmail() %>" disabled>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <label class="form-label text-dark fw-medium small">University/School</label>
                        <input type="text" name="university" class="form-control bg-light bg-opacity-50" value="<%= user.getUniversity() != null ? user.getUniversity() : "State University" %>">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label text-dark fw-medium small">Major</label>
                        <input type="text" name="major" class="form-control bg-light bg-opacity-50" value="<%= user.getMajor() != null ? user.getMajor() : "Computer Science" %>">
                    </div>
                </div>

                <div class="mb-5">
                    <label class="form-label text-dark fw-medium small">Academic Year</label>
                    <select name="academic_year" class="form-select bg-light bg-opacity-50">
                        <option value="Year 1" <%= "Year 1".equals(user.getAcademicYear()) ? "selected" : "" %>>Year 1</option>
                        <option value="Year 2" <%= "Year 2".equals(user.getAcademicYear()) ? "selected" : "" %>>Year 2</option>
                        <option value="Year 3" <%= "Year 3".equals(user.getAcademicYear()) ? "selected" : "" %>>Year 3</option>
                        <option value="Year 4" <%= "Year 4".equals(user.getAcademicYear()) ? "selected" : "" %>>Year 4</option>
                        <option value="Postgraduate" <%= "Postgraduate".equals(user.getAcademicYear()) ? "selected" : "" %>>Postgraduate</option>
                    </select>
                </div>

                <div>
                    <button type="submit" class="btn btn-primary px-4 fw-semibold">Save Changes</button>
                </div>
            </form>
            
        </div>
    </div>

</div>

<%@ include file="footer.jsp" %>
