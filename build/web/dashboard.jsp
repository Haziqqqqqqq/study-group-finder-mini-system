<%@ page contentType="text/html;charset=UTF-8" import="model.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }
    
    List<StudyGroup> createdGroups = (List<StudyGroup>) request.getAttribute("createdGroups");
    List<StudyGroup> joinedGroups = (List<StudyGroup>) request.getAttribute("joinedGroups");
    int totalGroups = (createdGroups != null ? createdGroups.size() : 0) + (joinedGroups != null ? joinedGroups.size() : 0);
%>
<%@ include file="header.jsp" %>

<div class="container py-4">
    
<%
    List<StudySession> upcomingSessions = (List<StudySession>) request.getAttribute("upcomingSessions");
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    
    // Removed avg rating calculation%>

    <!-- Welcome Banner -->
    <div class="bg-primary text-white rounded-4 p-4 p-md-5 mb-4" style="box-shadow: 0 4px 6px -1px rgba(37,99,235,0.2);">
        <h2 class="fw-bold mb-2">Welcome back, <%= loggedUser.getFullName() %>!</h2>
        <div class="opacity-75" style="font-size: 0.95rem;">
            <%= loggedUser.getMajor() != null ? loggedUser.getMajor() : "Computer Science" %> • 
            <%= loggedUser.getAcademicYear() != null ? loggedUser.getAcademicYear() : "3rd Year" %> • 
            <%= loggedUser.getUniversity() != null ? loggedUser.getUniversity() : "State University" %>
        </div>
    </div>

    <!-- 3 Stat Cards (Stacked vertically as per Figma) -->
    <div class="d-flex flex-column gap-3 mb-4">
        <!-- Active Groups -->
        <div class="simple-card p-4 d-flex align-items-center">
            <div class="rounded p-3 me-4 icon-container-blue">
                <i class="bi bi-people-fill fs-4"></i>
            </div>
            <div>
                <div class="text-muted small fw-medium mb-1">Active Groups</div>
                <h4 class="fw-bold mb-0 text-dark"><%= totalGroups %></h4>
            </div>
        </div>
        
        <!-- Upcoming Sessions -->
        <div class="simple-card p-4 d-flex align-items-center">
            <div class="rounded p-3 me-4 icon-container-green">
                <i class="bi bi-calendar-event fs-4"></i>
            </div>
            <div>
                <div class="text-muted small fw-medium mb-1">Upcoming Sessions</div>
                <h4 class="fw-bold mb-0 text-dark"><%= upcomingSessions != null ? upcomingSessions.size() : 0 %></h4>
            </div>
        </div>
        
        <!-- Groups Led -->
        <div class="simple-card p-4 d-flex align-items-center">
            <div class="rounded p-3 me-4 icon-container-purple">
                <i class="bi bi-star-fill fs-4"></i>
            </div>
            <div>
                <div class="text-muted small fw-medium mb-1">Groups Led</div>
                <h4 class="fw-bold mb-0 text-dark"><%= createdGroups != null ? createdGroups.size() : 0 %></h4>
            </div>
        </div>
    </div>



</div>

<%@ include file="footer.jsp" %>
