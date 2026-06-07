<%@ page contentType="text/html;charset=UTF-8" import="model.User, model.StudyGroup, java.util.List" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }
    
    List<StudyGroup> groups = (List<StudyGroup>) request.getAttribute("groups");
    String q = request.getAttribute("q") != null ? (String) request.getAttribute("q") : "";
    String selSubj = request.getAttribute("subject") != null ? (String) request.getAttribute("subject") : "";
    String selYear = request.getAttribute("year") != null ? (String) request.getAttribute("year") : "";
    String selMeet = request.getAttribute("meetingType") != null ? (String) request.getAttribute("meetingType") : "";
    java.util.Set<Integer> joinedGroupIds = (java.util.Set<Integer>) request.getAttribute("joinedGroupIds");
    if (joinedGroupIds == null) joinedGroupIds = new java.util.HashSet<>();
%>
<%@ include file="header.jsp" %>

<div class="container py-4">
    
    <div class="mb-4">
        <h2 class="fw-bold text-dark mb-1">Find Study Groups</h2>
        <p class="text-muted">Discover and join study groups that match your interests</p>
    </div>

    <!-- Search and Filters Box -->
    <div class="simple-card p-4 mb-4">
        <form action="<%= ctx %>/groups" method="get">
            <input type="hidden" name="action" value="find">
            
            <div class="input-group mb-4">
                <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                <input type="text" name="q" class="form-control border-start-0 ps-0" placeholder="Search by name, subject, course code..." value="<%= q %>">
            </div>

            <div class="d-flex align-items-center mb-2">
                <i class="bi bi-funnel text-muted me-2"></i>
                <span class="text-dark fw-medium">Filters:</span>
            </div>

            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label text-muted small">Subject</label>
                    <select name="subject" class="form-select" onchange="this.form.submit()">
                        <option value="">All Subjects</option>
                        <option value="Mathematics" <%= "Mathematics".equals(selSubj) ? "selected" : "" %>>Mathematics</option>
                        <option value="Computer Science" <%= "Computer Science".equals(selSubj) ? "selected" : "" %>>Computer Science</option>
                        <option value="Chemistry" <%= "Chemistry".equals(selSubj) ? "selected" : "" %>>Chemistry</option>
                        <option value="Physics" <%= "Physics".equals(selSubj) ? "selected" : "" %>>Physics</option>
                        <option value="Biology" <%= "Biology".equals(selSubj) ? "selected" : "" %>>Biology</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label text-muted small">Academic Year</label>
                    <select name="year" class="form-select" onchange="this.form.submit()">
                        <option value="">All Years</option>
                        <option value="Year 1" <%= "Year 1".equals(selYear) ? "selected" : "" %>>Year 1</option>
                        <option value="Year 2" <%= "Year 2".equals(selYear) ? "selected" : "" %>>Year 2</option>
                        <option value="Year 3" <%= "Year 3".equals(selYear) ? "selected" : "" %>>Year 3</option>
                        <option value="Year 4" <%= "Year 4".equals(selYear) ? "selected" : "" %>>Year 4</option>
                        <option value="Postgraduate" <%= "Postgraduate".equals(selYear) ? "selected" : "" %>>Postgraduate</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label text-muted small">Meeting Type</label>
                    <select name="meeting_type" class="form-select" onchange="this.form.submit()">
                        <option value="">All Types</option>
                        <option value="Online" <%= "Online".equals(selMeet) ? "selected" : "" %>>Online</option>
                        <option value="Physical" <%= "Physical".equals(selMeet) ? "selected" : "" %>>In-Person</option>
                        <option value="Hybrid" <%= "Hybrid".equals(selMeet) ? "selected" : "" %>>Hybrid</option>
                    </select>
                </div>
            </div>
            
            <div class="mt-4 text-end d-none">
                <!-- Keep button hidden, submit on enter for simplicity matching wireframe -->
                <button type="submit" class="btn btn-primary">Apply Filters</button>
            </div>
        </form>
    </div>

    <div class="text-muted small mb-3">Found <%= groups != null ? groups.size() : 0 %> groups</div>

    <!-- Groups Grid -->
    <div class="row g-4">
        <% if (groups != null) { 
            for (StudyGroup g : groups) { %>
        <div class="col-md-6">
            <div class="simple-card p-4 h-100 d-flex flex-column">
                <h4 class="fw-bold text-dark mb-1"><%= g.getGroupName() %></h4>
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
                    <a href="<%= ctx %>/groups?action=detail&id=<%= g.getGroupId() %>" class="btn btn-outline-primary flex-grow-1 fw-semibold py-2">View Details</a>
                    <% if (joinedGroupIds.contains(g.getGroupId())) { %>
                        <button type="button" class="btn btn-secondary flex-grow-1 fw-semibold py-2" disabled>Joined</button>
                    <% } else { %>
                        <form action="<%= ctx %>/groups" method="POST" class="flex-grow-1">
                            <input type="hidden" name="action" value="join">
                            <input type="hidden" name="group_id" value="<%= g.getGroupId() %>">
                            <button type="submit" class="btn btn-primary w-100 fw-semibold py-2">Join</button>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>
        <% } } %>
    </div>

</div>

<%@ include file="footer.jsp" %>
