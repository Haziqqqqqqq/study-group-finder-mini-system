<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("loggedUser") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StudyFinder - Register</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="<%= ctx %>/assets/css/style.css" rel="stylesheet">
    <style>
        body { background-color: #2563eb; }
    </style>
</head>
<body>

<div class="container d-flex flex-column justify-content-center align-items-center py-5" style="min-height: 100vh;">
    
    <div class="text-center mb-4">
        <h2 class="text-white fw-bold d-flex align-items-center justify-content-center">
            <span class="bg-white text-primary rounded px-2 py-1 me-2"><i class="bi bi-people-fill"></i></span>
            StudyFinder
        </h2>
        <p class="text-white-50">Connect with study groups and ace your classes</p>
    </div>

    <div class="card border-0 shadow-lg p-4 p-md-5" style="max-width: 500px; width: 100%; border-radius: 0.5rem;">
        <h3 class="fw-bold text-dark mb-1">Create Account</h3>
        <p class="text-muted mb-4">Join thousands of students studying together</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger py-2 small"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="<%= ctx %>/auth" method="post">
            <input type="hidden" name="action" value="register">

            <div class="mb-3">
                <label class="form-label text-muted fw-semibold small">Full Name *</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-person"></i></span>
                    <input type="text" name="full_name" class="form-control border-start-0 ps-0" placeholder="Your full name" required>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label text-muted fw-semibold small">Email Address *</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" name="email" class="form-control border-start-0 ps-0" placeholder="you@university.edu" required>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-6">
                    <label class="form-label text-muted fw-semibold small">Password *</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                        <input type="password" name="password" class="form-control border-start-0 ps-0" placeholder="Min 8 chars" required minlength="8">
                    </div>
                </div>
                <div class="col-6">
                    <label class="form-label text-muted fw-semibold small">Confirm *</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock-fill"></i></span>
                        <input type="password" name="confirm_password" class="form-control border-start-0 ps-0" placeholder="Repeat" required>
                    </div>
                </div>
            </div>

            <div class="row g-3 mb-4">
                <div class="col-6">
                    <label class="form-label text-muted fw-semibold small">University</label>
                    <input type="text" name="university" class="form-control" placeholder="State University">
                </div>
                <div class="col-6">
                    <label class="form-label text-muted fw-semibold small">Major</label>
                    <input type="text" name="major" class="form-control" placeholder="Computer Science">
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label text-muted fw-semibold small">Academic Year</label>
                <select class="form-select" name="academic_year">
                    <option value="">-- Select Year --</option>
                    <option value="Year 1">Year 1</option>
                    <option value="Year 2">Year 2</option>
                    <option value="Year 3">Year 3</option>
                    <option value="Year 4">Year 4</option>
                    <option value="Postgraduate">Postgraduate</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold mb-4">Create Account</button>

            <div class="text-center small text-muted">
                Already have an account? <a href="<%= ctx %>/auth?action=login" class="text-primary text-decoration-none fw-semibold">Sign In</a>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
