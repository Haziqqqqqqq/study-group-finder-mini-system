<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StudyFinder - Login</title>
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

<div class="container d-flex flex-column justify-content-center align-items-center" style="min-height: 100vh;">
    
    <div class="text-center mb-4">
        <h2 class="text-white fw-bold d-flex align-items-center justify-content-center">
            <span class="bg-white text-primary rounded px-2 py-1 me-2"><i class="bi bi-people-fill"></i></span>
            StudyFinder
        </h2>
        <p class="text-white-50">Connect with study groups and ace your classes</p>
    </div>

    <div class="card border-0 shadow-lg p-4 p-md-5" style="max-width: 450px; width: 100%; border-radius: 0.5rem;">
        <h3 class="fw-bold text-dark mb-1">Welcome Back</h3>
        <p class="text-muted mb-4">Sign in to continue your study journey</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger py-2 small"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="<%= ctx %>/auth" method="POST">
            <input type="hidden" name="action" value="login">
            
            <div class="mb-3">
                <label class="form-label text-muted fw-semibold small">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" name="email" class="form-control border-start-0 ps-0" placeholder="you@university.edu" required>
                </div>
            </div>
            
            <div class="mb-4">
                <label class="form-label text-muted fw-semibold small">Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                    <input type="password" name="password" class="form-control border-start-0 ps-0" placeholder="Enter your password" required>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="form-check">
                    <input type="checkbox" class="form-check-input" id="remember">
                    <label class="form-check-label small text-muted fw-semibold" for="remember">Remember me</label>
                </div>
                <a href="#" class="text-primary small text-decoration-none fw-semibold">Forgot password?</a>
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold mb-4">Sign In</button>

            <div class="text-center small text-muted">
                Don't have an account? <a href="<%= ctx %>/auth?action=register" class="text-primary text-decoration-none fw-semibold">Sign up</a>
            </div>
        </form>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
