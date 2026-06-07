<%@ page contentType="text/html;charset=UTF-8" import="model.User, model.StudyGroup, java.util.List, java.util.Set, java.util.HashSet" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }

    List<StudyGroup> createdGroups = (List<StudyGroup>) request.getAttribute("createdGroups");
    List<StudyGroup> joinedGroups = (List<StudyGroup>) request.getAttribute("joinedGroups");
    
    // Combine and deduplicate
    Set<Integer> uniqueIds = new HashSet<>();
    java.util.ArrayList<StudyGroup> myGroups = new java.util.ArrayList<>();
    
    if (createdGroups != null) {
        for (StudyGroup g : createdGroups) {
            if (uniqueIds.add(g.getGroupId())) {
                myGroups.add(g);
            }
        }
    }
    if (joinedGroups != null) {
        for (StudyGroup g : joinedGroups) {
            if (uniqueIds.add(g.getGroupId())) {
                myGroups.add(g);
            }
        }
    }
%>
<%@ include file="header.jsp" %>

<div class="container py-4">
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-dark mb-1">My Study Groups</h2>
            <p class="text-muted mb-0">Manage your active study groups</p>
        </div>
        <a href="<%= ctx %>/groups?action=create" class="btn btn-primary fw-semibold px-4 py-2">Create New Group</a>
    </div>

    <% if (myGroups.isEmpty()) { %>
        <!-- Empty State Box -->
        <div class="simple-card p-5 d-flex flex-column align-items-center justify-content-center text-center mt-4" style="min-height: 400px;">
            <i class="bi bi-people text-black-50 mb-3" style="font-size: 4rem; opacity: 0.5;"></i>
            <h4 class="fw-bold text-dark mb-2">No groups yet</h4>
            <p class="text-muted mb-4">Join or create a study group to get started</p>
            
            <div class="d-flex gap-3">
                <a href="<%= ctx %>/groups?action=find" class="btn btn-primary fw-semibold px-4 py-2">Find Groups</a>
                <a href="<%= ctx %>/groups?action=create" class="btn btn-outline-primary fw-semibold px-4 py-2 bg-white">Create Group</a>
            </div>
        </div>
    <% } else { %>
        <!-- Groups Grid -->
        <div class="row g-4">
            <% for (StudyGroup g : myGroups) { %>
            <div class="col-md-6">
                <div class="simple-card p-4 h-100 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-start mb-1">
                        <h4 class="fw-bold text-dark mb-0"><%= g.getGroupName() %></h4>
                        <% if (g.getCreatorId() == user.getUserId()) { %>
                            <span class="badge bg-warning text-dark rounded-pill px-2 py-1" style="font-size: 0.7rem;"><i class="bi bi-star-fill me-1"></i>Leader</span>
                        <% } %>
                    </div>
                    <div class="text-primary fw-semibold mb-3"><%= g.getCourseCode() %></div>
                    
                    <p class="text-muted mb-4 flex-grow-1" style="font-size: 0.95rem;">
                        <% String desc = g.getDescription() != null && !g.getDescription().trim().isEmpty() ? g.getDescription() : "Study group for " + g.getSubject();
                           if(desc.length() > 100) desc = desc.substring(0, 100) + "...";
                        %>
                        <%= desc %>
                    </p>

                    <div class="d-flex flex-column gap-2 text-muted mb-3" style="font-size: 0.95rem;">
                        <div><i class="bi bi-people me-2"></i><%= g.getMemberCount() %>/<%= g.getCapacity() %> members</div>
                        <div><i class="bi bi-geo-alt me-2"></i><%= g.getMeetingType() %></div>
                        <div class="text-dark"><i class="bi bi-star-fill text-warning me-2"></i><%= String.format("%.1f", g.getAvgRating()) %> rating</div>
                    </div>

                    <div class="d-flex flex-wrap gap-2 mb-4">
                        <span class="tag-badge-blue"><%= g.getSubject().toLowerCase() %></span>
                        <span class="tag-badge-blue"><%= g.getMeetingType().toLowerCase() %></span>
                        <span class="tag-badge-blue">study</span>
                    </div>

                    <div class="d-flex gap-3 mt-auto">
                        <a href="<%= ctx %>/groups?action=detail&id=<%= g.getGroupId() %>" class="btn btn-primary w-100 fw-semibold py-2">Open Group</a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>

</div>

<%@ include file="footer.jsp" %>
