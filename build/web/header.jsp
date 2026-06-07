<%@ page contentType="text/html;charset=UTF-8" import="model.User, model.StudySession, dao.StudySessionDAO, java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String ctx = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");
    
    List<StudySession> headerUpcomingSessions = null;
    if (loggedUser != null) {
        StudySessionDAO headerSessionDAO = new StudySessionDAO();
        headerUpcomingSessions = headerSessionDAO.getUpcomingForUser(loggedUser.getUserId(), 5);
    }
    
    // Get current page to highlight the correct tab
    // When a servlet forwards to a JSP, getRequestURI() returns the JSP path,
    // so we also check the original servlet URI stored in forward attributes.
    String uri = request.getRequestURI();
    String query = request.getQueryString() != null ? request.getQueryString() : "";
    
    // Check forward attributes (set automatically by RequestDispatcher.forward)
    String fwdUri   = (String) request.getAttribute("javax.servlet.forward.request_uri");
    String fwdQuery = (String) request.getAttribute("javax.servlet.forward.query_string");
    if (fwdUri != null) uri = fwdUri;
    if (fwdQuery != null) query = fwdQuery;
    
    String activeTab = "dashboard";
    
    if (uri.contains("groups") && query.contains("action=find")) activeTab = "find";
    else if (uri.contains("groups") && query.contains("action=my")) activeTab = "my";
    else if (uri.contains("groups") && query.contains("action=create")) activeTab = "create";
    else if (uri.contains("profile")) activeTab = "profile";
    
    // Admin Tabs
    if (uri.contains("admin") && query.contains("action=users")) activeTab = "admin_users";
    else if (uri.contains("admin") && query.contains("action=groups")) activeTab = "admin_groups";
    else if (uri.contains("admin") || (uri.contains("admin_dashboard.jsp"))) activeTab = "admin_dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StudyFinder</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Simple Custom CSS -->
    <link href="<%= ctx %>/assets/css/style.css" rel="stylesheet">
</head>
<body>

<% if (loggedUser != null) { %>
<!-- Top Navbar -->
<nav class="navbar-top d-flex justify-content-between align-items-center">
    <div class="d-flex align-items-center">
        <a href="<%= ctx %>/dashboard" class="brand-title d-flex align-items-center">
            <i class="bi bi-people-fill brand-icon fs-3"></i>
            StudyFinder
        </a>
        
        <!-- Search Bar -->
        <div class="ms-5 d-none d-md-block">
            <form action="<%= ctx %>/groups" method="get" class="position-relative">
                <input type="hidden" name="action" value="find">
                <i class="bi bi-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"></i>
                <input type="text" name="q" class="form-control rounded-pill ps-5 bg-white border" placeholder="Search groups, subjects..." style="width: 350px;">
            </form>
        </div>
    </div>
    
    <div class="d-flex align-items-center gap-4">
        <div class="dropdown">
            <a href="#" class="text-secondary position-relative text-decoration-none dropdown-toggle-hidden" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-bell fs-5 text-dark"></i>
                <% if (headerUpcomingSessions != null && !headerUpcomingSessions.isEmpty()) { %>
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-circle bg-danger p-1" style="font-size: 0.65rem; border: 2px solid white;"><%= headerUpcomingSessions.size() %></span>
                <% } %>
            </a>
            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2 p-0" style="width: 320px; overflow: hidden;">
                <li class="bg-light px-3 py-2 border-bottom fw-bold text-dark" style="font-size: 0.9rem;">Upcoming Sessions</li>
                <% if (headerUpcomingSessions != null && !headerUpcomingSessions.isEmpty()) { 
                    for (StudySession s : headerUpcomingSessions) { %>
                    <li>
                        <a class="dropdown-item py-3 px-3 border-bottom d-flex align-items-start gap-3" href="<%= ctx %>/groups?action=detail&id=<%= s.getGroupId() %>&tab=sessions" style="white-space: normal;">
                            <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center flex-shrink-0" style="width: 36px; height: 36px;">
                                <i class="bi bi-calendar-event"></i>
                            </div>
                            <div>
                                <div class="fw-semibold text-dark mb-1" style="font-size: 0.9rem;"><%= s.getSessionTitle() %></div>
                                <div class="text-muted" style="font-size: 0.8rem;"><%= s.getSessionDate() %> at <%= s.getSessionTime() %></div>
                            </div>
                        </a>
                    </li>
                <% } } else { %>
                    <li class="px-3 py-4 text-center text-muted" style="font-size: 0.9rem;">
                        <i class="bi bi-bell-slash fs-4 d-block mb-2 text-black-50"></i>
                        No upcoming sessions
                    </li>
                <% } %>
            </ul>
        </div>
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark dropdown-toggle" data-bs-toggle="dropdown" style="gap: 8px;">
                <div class="bg-primary text-white rounded-circle d-flex justify-content-center align-items-center" style="width: 36px; height: 36px;">
                    <i class="bi bi-person fs-5"></i>
                </div>
                <span class="fw-semibold d-none d-sm-inline" style="font-size: 0.95rem;"><%= loggedUser.getFullName() %></span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                <li><a class="dropdown-item" href="<%= ctx %>/profile"><i class="bi bi-person me-2"></i>Profile</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="<%= ctx %>/auth?action=logout"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Secondary Tabs -->
<div class="navbar-tabs">
    <% if (loggedUser.isAdmin()) { %>
        <a href="<%= ctx %>/admin" class="nav-tabs-link <%= activeTab.equals("admin_dashboard") ? "active" : "" %>">
            <i class="bi bi-speedometer2 me-1"></i> Admin Dashboard
        </a>
        <a href="<%= ctx %>/admin?action=users" class="nav-tabs-link <%= activeTab.equals("admin_users") ? "active" : "" %>">
            <i class="bi bi-people me-1"></i> Manage Users
        </a>
        <a href="<%= ctx %>/admin?action=groups" class="nav-tabs-link <%= activeTab.equals("admin_groups") ? "active" : "" %>">
            <i class="bi bi-collection me-1"></i> Manage Groups
        </a>
    <% } else { %>
        <a href="<%= ctx %>/dashboard" class="nav-tabs-link <%= activeTab.equals("dashboard") ? "active" : "" %>">
            <i class="bi bi-house me-1"></i> Dashboard
        </a>
        <a href="<%= ctx %>/groups?action=find" class="nav-tabs-link <%= activeTab.equals("find") ? "active" : "" %>">
            <i class="bi bi-search me-1"></i> Find Groups
        </a>
        <a href="<%= ctx %>/groups?action=my" class="nav-tabs-link <%= activeTab.equals("my") ? "active" : "" %>">
            <i class="bi bi-people me-1"></i> My Groups
        </a>
        <a href="<%= ctx %>/groups?action=create" class="nav-tabs-link <%= activeTab.equals("create") ? "active" : "" %>">
            <i class="bi bi-plus-lg me-1"></i> Create
        </a>
        <a href="<%= ctx %>/profile" class="nav-tabs-link <%= activeTab.equals("profile") ? "active" : "" %>">
            <i class="bi bi-person me-1"></i> Profile
        </a>
    <% } %>
</div>
<% } %>
