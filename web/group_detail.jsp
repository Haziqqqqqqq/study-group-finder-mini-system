<%@ page contentType="text/html;charset=UTF-8" import="model.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }
    
    StudyGroup group = (StudyGroup) request.getAttribute("group");
    Boolean isMember = (Boolean) request.getAttribute("isMember");
    Boolean isCreator = (Boolean) request.getAttribute("isCreator");
    List<Membership> members = (List<Membership>) request.getAttribute("members");
    List<StudySession> sessionsList = (List<StudySession>) request.getAttribute("sessions");
    List<Discussion> posts = (List<Discussion>) request.getAttribute("posts");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    java.util.Map<Integer, java.util.List<Discussion>> repliesMap = 
        (java.util.Map<Integer, java.util.List<Discussion>>) request.getAttribute("repliesMap");
    if (repliesMap == null) repliesMap = new java.util.HashMap<>();
    
    boolean hasAccess = (isMember != null && isMember) || (isCreator != null && isCreator);
%>
<%@ include file="header.jsp" %>

<div class="container py-4">
    
    <!-- Back Button -->
    <a href="<%= ctx %>/groups?action=find" class="text-decoration-none text-primary fw-medium small d-inline-flex align-items-center mb-4">
        <i class="bi bi-arrow-left me-2"></i>Back to Find Groups
    </a>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger py-2 mb-4"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success py-2 mb-4"><%= request.getAttribute("success") %></div>
    <% } %>

    <!-- Header Section -->
    <div class="simple-card p-4 p-md-5 mb-4">
        <div class="d-flex justify-content-between align-items-start mb-3">
            <div>
                <h2 class="fw-bold text-dark mb-1"><%= group.getGroupName() %></h2>
                <div class="text-primary fw-semibold mb-3">
                    <%= group.getCourseCode() %> &bull; <%= group.getSubject() %>
                </div>
            </div>
            
            <div>
                <% if (!hasAccess) { %>
                    <% if (group.getSlotsLeft() > 0) { %>
                        <form action="<%= ctx %>/groups" method="POST" class="d-inline">
                            <input type="hidden" name="action" value="join">
                            <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                            <button type="submit" class="btn btn-primary px-4 fw-semibold py-2">Join Group</button>
                        </form>
                    <% } else { %>
                        <button class="btn btn-secondary px-4 fw-semibold py-2" disabled>Group Full</button>
                    <% } %>
                <% } else if (isCreator) { %>
                    <a href="<%= ctx %>/groups?action=edit&id=<%= group.getGroupId() %>" class="btn btn-outline-primary px-4 fw-semibold py-2">Edit Group</a>
                <% } else if (isMember) { %>
                    <form action="<%= ctx %>/groups" method="POST" class="d-inline" onsubmit="return confirm('Leave this group?');">
                        <input type="hidden" name="action" value="leave">
                        <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                        <button type="submit" class="btn btn-outline-secondary px-4 fw-semibold py-2">Leave Group</button>
                    </form>
                <% } %>
            </div>
        </div>
        
        <p class="text-muted" style="line-height: 1.6; max-width: 900px;">
            <%= group.getDescription() != null && !group.getDescription().trim().isEmpty() ? group.getDescription().replace("\n", "<br/>") : "No description provided." %>
        </p>

        <!-- Stats Bar -->
        <div class="row mt-5 pt-4 border-top">
            <div class="col-6 col-md-3 mb-3 mb-md-0 d-flex align-items-center">
                <i class="bi bi-people fs-4 text-muted me-3"></i>
                <div>
                    <div class="small text-muted mb-1">Members</div>
                    <div class="fw-bold text-dark"><%= group.getMemberCount() %>/<%= group.getCapacity() %></div>
                </div>
            </div>
            <div class="col-6 col-md-3 mb-3 mb-md-0 d-flex align-items-center">
                <i class="bi bi-star-fill fs-4 text-warning me-3"></i>
                <div>
                    <div class="small text-muted mb-1">Rating</div>
                    <div class="fw-bold text-dark"><%= String.format("%.1f", group.getAvgRating()) %></div>
                </div>
            </div>
            <div class="col-6 col-md-3 d-flex align-items-center">
                <i class="bi bi-geo-alt fs-4 text-muted me-3"></i>
                <div>
                    <div class="small text-muted mb-1">Meeting Type</div>
                    <div class="fw-bold text-dark"><%= group.getMeetingType() %></div>
                </div>
            </div>
            <div class="col-6 col-md-3 d-flex align-items-center">
                <i class="bi bi-person fs-4 text-muted me-3"></i>
                <div>
                    <div class="small text-muted mb-1">Organizer</div>
                    <div class="fw-bold text-dark"><%= group.getCreatorName() %></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs Section -->
    <ul class="nav nav-tabs border-bottom-0 mb-4" id="groupTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-tabs-link active border-0 bg-transparent fw-semibold px-4 pb-3" style="border-bottom: 2px solid #2563eb !important; color: #2563eb;" id="discussion-tab" data-bs-toggle="tab" data-bs-target="#discussion" type="button" role="tab">Discussion</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-tabs-link border-0 bg-transparent fw-medium text-muted px-4 pb-3" id="sessions-tab" data-bs-toggle="tab" data-bs-target="#sessions" type="button" role="tab">Sessions</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-tabs-link border-0 bg-transparent fw-medium text-muted px-4 pb-3" id="members-tab" data-bs-toggle="tab" data-bs-target="#members" type="button" role="tab">Members</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-tabs-link border-0 bg-transparent fw-medium text-muted px-4 pb-3" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews" type="button" role="tab">Reviews</button>
        </li>
    </ul>

    <!-- Tabs Content -->
    <div class="tab-content" id="groupTabsContent">
        
        <!-- Discussion Tab -->
        <div class="tab-pane fade show active" id="discussion" role="tabpanel">
            <h5 class="fw-bold text-dark mb-4">Discussion Board</h5>
            
            <% if (hasAccess) { %>
            <!-- Post Form -->
            <div class="simple-card p-4 mb-4">
                <form action="<%= ctx %>/discussion" method="POST">
                    <input type="hidden" name="action" value="post">
                    <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                    <textarea class="form-control bg-light bg-opacity-50 border-0 mb-3" name="content" rows="3" placeholder="Share something with the group..." required></textarea>
                    <div class="text-end">
                        <button type="submit" class="btn btn-primary px-4 fw-semibold">Post</button>
                    </div>
                </form>
            </div>
            <% } %>

            <% if (posts != null && !posts.isEmpty()) { 
                for (Discussion p : posts) { 
                    java.util.List<Discussion> replies = repliesMap.get(p.getMessageId());
                    int rCount = (replies != null) ? replies.size() : p.getReplyCount();
            %>
                <div class="simple-card p-4 mb-3">
                    <!-- Post Header -->
                    <div class="d-flex align-items-center mb-3">
                        <div class="bg-primary text-white rounded-circle d-flex justify-content-center align-items-center me-3" style="width: 40px; height: 40px;">
                            <i class="bi bi-person"></i>
                        </div>
                        <div class="flex-grow-1">
                            <div class="fw-bold text-dark"><%= p.getAuthorName() %></div>
                            <div class="small text-muted" style="font-size: 0.75rem;"><%= p.getCreatedAt() %></div>
                        </div>
                        <% if (p.getUserId() == user.getUserId()) { %>
                        <form action="<%= ctx %>/discussion" method="POST" class="d-inline" onsubmit="return confirm('Delete this post?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                            <input type="hidden" name="message_id" value="<%= p.getMessageId() %>">
                            <button type="submit" class="btn btn-sm btn-outline-danger border-0"><i class="bi bi-trash"></i></button>
                        </form>
                        <% } %>
                    </div>
                    <!-- Post Content -->
                    <p class="text-dark mb-3" style="line-height: 1.6;"><%= p.getContent().replace("\n", "<br/>") %></p>

                    <!-- Reply Count & Toggle -->
                    <div class="d-flex align-items-center gap-3 pt-2 border-top">
                        <% if (rCount > 0) { %>
                        <button class="btn btn-sm btn-link text-muted text-decoration-none p-0" type="button" data-bs-toggle="collapse" data-bs-target="#replies-<%= p.getMessageId() %>">
                            <i class="bi bi-chat-dots me-1"></i><%= rCount %> <%= rCount == 1 ? "reply" : "replies" %>
                        </button>
                        <% } %>
                        <% if (hasAccess) { %>
                        <button class="btn btn-sm btn-link text-primary text-decoration-none p-0" type="button" data-bs-toggle="collapse" data-bs-target="#replyForm-<%= p.getMessageId() %>">
                            <i class="bi bi-reply me-1"></i>Reply
                        </button>
                        <% } %>
                    </div>

                    <!-- Inline Reply Form (collapsed) -->
                    <% if (hasAccess) { %>
                    <div class="collapse mt-3" id="replyForm-<%= p.getMessageId() %>">
                        <form action="<%= ctx %>/discussion" method="POST">
                            <input type="hidden" name="action" value="reply">
                            <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                            <input type="hidden" name="parent_id" value="<%= p.getMessageId() %>">
                            <textarea class="form-control form-control-sm mb-2" name="content" rows="2" placeholder="Write a reply..." required></textarea>
                            <button type="submit" class="btn btn-sm btn-primary">Reply</button>
                        </form>
                    </div>
                    <% } %>

                    <!-- Replies Thread (collapsed if > 0) -->
                    <% if (replies != null && !replies.isEmpty()) { %>
                    <div class="collapse mt-3" id="replies-<%= p.getMessageId() %>">
                        <% for (Discussion r : replies) { %>
                        <div class="d-flex ms-4 mb-2 ps-3" style="border-left: 2px solid #e2e8f0;">
                            <div class="rounded-circle d-flex justify-content-center align-items-center me-2 flex-shrink-0" style="width: 30px; height: 30px; background-color: #dbeafe; color: #2563eb;">
                                <i class="bi bi-person" style="font-size: 0.75rem;"></i>
                            </div>
                            <div class="flex-grow-1">
                                <div class="d-flex align-items-center">
                                    <span class="fw-bold text-dark small"><%= r.getAuthorName() %></span>
                                    <span class="text-muted ms-2" style="font-size: 0.7rem;"><%= r.getCreatedAt() %></span>
                                    <% if (r.getUserId() == user.getUserId()) { %>
                                    <form action="<%= ctx %>/discussion" method="POST" class="d-inline ms-auto" onsubmit="return confirm('Delete this reply?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                                        <input type="hidden" name="message_id" value="<%= r.getMessageId() %>">
                                        <button type="submit" class="btn btn-sm btn-link text-danger p-0" style="font-size: 0.75rem;"><i class="bi bi-trash"></i></button>
                                    </form>
                                    <% } %>
                                </div>
                                <p class="text-dark small mb-0" style="line-height: 1.5;"><%= r.getContent().replace("\n", "<br/>") %></p>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            <% } } else { %>
                <div class="text-center py-5">
                    <i class="bi bi-chat-square-text text-muted mb-2" style="font-size: 2rem; opacity: 0.5;"></i>
                    <p class="text-muted mb-0">No discussions yet. Be the first to start one!</p>
                </div>
            <% } %>
        </div>

        <!-- Sessions Tab -->
        <div class="tab-pane fade" id="sessions" role="tabpanel">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="fw-bold text-dark mb-0">Study Sessions</h5>
                <% if (hasAccess) { %>
                <a href="<%= ctx %>/sessions?action=create&groupId=<%= group.getGroupId() %>" class="btn btn-primary btn-sm fw-semibold px-3">
                    <i class="bi bi-plus-lg me-1"></i>Schedule Session
                </a>
                <% } %>
            </div>
            <% if (sessionsList != null && !sessionsList.isEmpty()) { 
                for (StudySession s : sessionsList) { 
                    boolean isVirtual = (s.getMeetingLink() != null && !s.getMeetingLink().trim().isEmpty());
                    boolean hasLocation = (s.getLocation() != null && !s.getLocation().trim().isEmpty());
            %>
                <div class="simple-card p-4 mb-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <div class="d-flex flex-grow-1">
                            <% 
                                String dateStr = s.getSessionDate() != null ? s.getSessionDate().toString() : ""; 
                                String month = "N/A";
                                String day = "--";
                                try {
                                    java.time.LocalDate ld = java.time.LocalDate.parse(dateStr);
                                    month = ld.getMonth().name().substring(0,3);
                                    day = String.valueOf(ld.getDayOfMonth());
                                } catch(Exception e) { }
                            %>
                            <div class="date-square me-4 flex-shrink-0">
                                <div class="month"><%= month %></div>
                                <div class="day"><%= day %></div>
                            </div>
                            <div>
                                <h5 class="fw-bold text-dark mb-1"><%= s.getSessionTitle() %></h5>
                                <div class="text-muted small mb-3">Duration: <%= s.getFormattedDuration() %></div>
                                
                                <div class="d-flex flex-wrap gap-4 small text-muted">
                                    <div class="d-flex align-items-center">
                                        <i class="bi bi-clock me-2"></i><%= s.getSessionTime() %>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <% if (isVirtual) { %>
                                            <i class="bi bi-camera-video text-primary me-2"></i><a href="<%= s.getMeetingLink() %>" target="_blank" class="text-decoration-none"><%= s.getMeetingLink() %></a>
                                        <% } else { %>
                                            <i class="bi bi-geo-alt text-primary me-2"></i><span class="text-dark"><%= s.getLocation() %></span>
                                        <% } %>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <i class="bi bi-people me-2"></i><%= s.getAttendeeCount() %> attending
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-column align-items-end ms-3 gap-2">
                            <% if (isMember || isCreator) { %>
                                <% if (s.isUserAttending()) { %>
                                    <form action="<%= ctx %>/sessions" method="POST" class="m-0">
                                        <input type="hidden" name="action" value="unattend">
                                        <input type="hidden" name="session_id" value="<%= s.getSessionId() %>">
                                        <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                                        <button type="submit" class="btn btn-sm btn-success fw-semibold shadow-sm"><i class="bi bi-check-circle me-1"></i>Attending</button>
                                    </form>
                                <% } else { %>
                                    <form action="<%= ctx %>/sessions" method="POST" class="m-0">
                                        <input type="hidden" name="action" value="attend">
                                        <input type="hidden" name="session_id" value="<%= s.getSessionId() %>">
                                        <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                                        <button type="submit" class="btn btn-sm btn-outline-primary fw-semibold shadow-sm">Attend</button>
                                    </form>
                                <% } %>
                            <% } %>

                            <% if (s.getCreatedBy() == user.getUserId()) { %>
                            <div class="d-flex gap-1 mt-auto">
                                <a href="<%= ctx %>/sessions?action=edit&id=<%= s.getSessionId() %>" class="btn btn-sm btn-outline-secondary border-0"><i class="bi bi-pencil"></i></a>
                                <form action="<%= ctx %>/sessions" method="POST" class="d-inline" onsubmit="return confirm('Delete this session?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="session_id" value="<%= s.getSessionId() %>">
                                    <button type="submit" class="btn btn-sm btn-outline-danger border-0"><i class="bi bi-trash"></i></button>
                                </form>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } } else { %>
                <div class="text-center py-5">
                    <i class="bi bi-calendar-x text-muted mb-2" style="font-size: 2rem; opacity: 0.5;"></i>
                    <p class="text-muted mb-2">No sessions scheduled yet.</p>
                    <% if (hasAccess) { %>
                    <a href="<%= ctx %>/sessions?action=create&groupId=<%= group.getGroupId() %>" class="btn btn-primary btn-sm fw-semibold px-3">Schedule the first session</a>
                    <% } %>
                </div>
            <% } %>
        </div>

        <!-- Members Tab -->
        <div class="tab-pane fade" id="members" role="tabpanel">
            <h5 class="fw-bold text-dark mb-4">Group Members (<%= members != null ? members.size() : 0 %>)</h5>
            <div class="row g-3">
                <% if (members != null && !members.isEmpty()) { 
                    for (Membership m : members) { %>
                    <div class="col-md-6 col-lg-4">
                        <div class="simple-card p-3 d-flex align-items-center">
                            <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex justify-content-center align-items-center me-3" style="width: 45px; height: 45px;">
                                <i class="bi bi-person"></i>
                            </div>
                            <div>
                                <div class="fw-bold text-dark"><%= m.getFullName() %></div>
                                <div class="small text-muted">Joined <%= m.getJoinDate().substring(0, 10) %></div>
                            </div>
                        </div>
                    </div>
                <% } } %>
            </div>
        </div>

        <!-- Reviews Tab -->
        <div class="tab-pane fade" id="reviews" role="tabpanel">
            <h5 class="fw-bold text-dark mb-4">Group Reviews</h5>
            
            <% if (hasAccess && !(Boolean)request.getAttribute("hasReview")) { %>
                <div class="simple-card p-4 mb-4 bg-primary bg-opacity-10 border-primary border-opacity-25">
                    <h6 class="fw-bold text-primary mb-3">Leave a Review</h6>
                    <form action="<%= ctx %>/review" method="POST">
                        <input type="hidden" name="action" value="submit">
                        <input type="hidden" name="group_id" value="<%= group.getGroupId() %>">
                        <div class="mb-3 d-flex align-items-center">
                            <label class="form-label text-dark fw-medium small mb-0 me-3">Rating:</label>
                            <div id="starRating" class="d-flex" style="cursor: pointer;">
                                <i class="bi bi-star-fill text-warning fs-5 me-1" data-val="1"></i>
                                <i class="bi bi-star-fill text-warning fs-5 me-1" data-val="2"></i>
                                <i class="bi bi-star-fill text-warning fs-5 me-1" data-val="3"></i>
                                <i class="bi bi-star-fill text-warning fs-5 me-1" data-val="4"></i>
                                <i class="bi bi-star-fill text-warning fs-5 me-1" data-val="5"></i>
                            </div>
                            <input type="hidden" name="rating" id="ratingValue" value="5">
                        </div>
                        <textarea class="form-control bg-white border-0 mb-3" name="review_text" rows="2" placeholder="Write your feedback..." required></textarea>
                        <button type="submit" class="btn btn-primary px-4 fw-semibold btn-sm">Submit Review</button>
                    </form>
                </div>
            <% } %>

            <div class="row g-3">
                <% if (reviews != null && !reviews.isEmpty()) { 
                    for (Review r : reviews) { %>
                    <div class="col-12">
                        <div class="simple-card p-4">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div class="fw-bold text-dark"><%= r.getReviewerName() %></div>
                                <div class="text-warning small"><i class="bi bi-star-fill me-1"></i><%= r.getRating() %>/5</div>
                            </div>
                            <p class="text-muted small mb-0">"<%= r.getReviewText() %>"</p>
                        </div>
                    </div>
                <% } } else { %>
                    <div class="text-center py-5">
                        <p class="text-muted mb-0">No reviews yet.</p>
                    </div>
                <% } %>
            </div>
        </div>

    </div>
</div>

<script>
    // Helper: apply active/inactive styling to tab buttons
    function activateTab(activeBtn) {
        document.querySelectorAll('#groupTabs .nav-tabs-link').forEach(t => {
            t.style.borderBottom = 'none';
            t.style.color = '#6c757d';
            t.classList.remove('active', 'fw-semibold');
            t.classList.add('text-muted', 'fw-medium');
        });
        activeBtn.style.borderBottom = '2px solid #2563eb';
        activeBtn.style.color = '#2563eb';
        activeBtn.classList.add('active', 'fw-semibold');
        activeBtn.classList.remove('text-muted', 'fw-medium');
    }

    // Tab click styling
    document.querySelectorAll('#groupTabs .nav-tabs-link').forEach(tab => {
        tab.addEventListener('click', function() { activateTab(this); });
    });

    // Auto-activate tab from URL ?tab= parameter
    (function() {
        var params = new URLSearchParams(window.location.search);
        var tab = params.get('tab');
        if (tab) {
            var tabBtn = document.getElementById(tab + '-tab');
            if (tabBtn) {
                var bsTab = new bootstrap.Tab(tabBtn);
                bsTab.show();
                activateTab(tabBtn);
            }
        }
    })();

    // Star Rating Logic
    const stars = document.querySelectorAll('#starRating i');
    const ratingInput = document.getElementById('ratingValue');
    
    if (stars.length > 0) {
        document.getElementById('starRating').setAttribute('data-selected', '5');
        
        stars.forEach(star => {
            star.addEventListener('mouseover', function() {
                const val = this.getAttribute('data-val');
                stars.forEach(s => {
                    if (s.getAttribute('data-val') <= val) {
                        s.classList.remove('bi-star');
                        s.classList.add('bi-star-fill');
                    } else {
                        s.classList.remove('bi-star-fill');
                        s.classList.add('bi-star');
                    }
                });
            });
            
            star.addEventListener('click', function() {
                const val = this.getAttribute('data-val');
                ratingInput.value = val;
                document.getElementById('starRating').setAttribute('data-selected', val);
            });
        });
        
        document.getElementById('starRating').addEventListener('mouseout', function() {
            const selectedVal = this.getAttribute('data-selected');
            stars.forEach(s => {
                if (s.getAttribute('data-val') <= selectedVal) {
                    s.classList.remove('bi-star');
                    s.classList.add('bi-star-fill');
                } else {
                    s.classList.remove('bi-star-fill');
                    s.classList.add('bi-star');
                }
            });
        });
    }
</script>

<%@ include file="footer.jsp" %>
