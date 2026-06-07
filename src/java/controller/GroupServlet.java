package controller;

import dao.*;
import model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * GroupServlet — Controller Layer
 * Handles all study group actions:
 *   GET  /groups?action=find        → search/browse groups
 *   GET  /groups?action=my          → my groups
 *   GET  /groups?action=create      → show create form
 *   GET  /groups?action=detail&id=X → group detail page
 *   GET  /groups?action=edit&id=X   → show edit form
 *   POST /groups?action=create      → save new group
 *   POST /groups?action=update      → update group
 *   POST /groups?action=delete      → delete group
 *   POST /groups?action=join        → join group
 *   POST /groups?action=leave       → leave group
 */
@WebServlet("/groups")
public class GroupServlet extends HttpServlet {

    private final StudyGroupDAO   groupDAO   = new StudyGroupDAO();
    private final MembershipDAO   memberDAO  = new MembershipDAO();
    private final NotificationDAO notifDAO   = new NotificationDAO();
    private final StudySessionDAO sessionDAO = new StudySessionDAO();
    private final DiscussionDAO   discDAO    = new DiscussionDAO();
    private final ReviewDAO       reviewDAO  = new ReviewDAO();

    // ============================================================
    // GET requests
    // ============================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "find";

        try {
            if ("my".equals(action)) {
                showMyGroups(req, resp, user);
            } else if ("create".equals(action)) {
                req.getRequestDispatcher("/group_create.jsp").forward(req, resp);
            } else if ("detail".equals(action)) {
                showDetail(req, resp, user);
            } else if ("edit".equals(action)) {
                showEdit(req, resp, user);
            } else {
                showFind(req, resp, user);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/groups_find.jsp").forward(req, resp);
        }
    }

    // ============================================================
    // POST requests
    // ============================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            if ("create".equals(action)) {
                handleCreate(req, resp, user);
            } else if ("update".equals(action)) {
                handleUpdate(req, resp, user);
            } else if ("delete".equals(action)) {
                handleDelete(req, resp, user);
            } else if ("join".equals(action)) {
                handleJoin(req, resp, user);
            } else if ("leave".equals(action)) {
                handleLeave(req, resp, user);
            } else {
                resp.sendRedirect(req.getContextPath() + "/groups");
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/groups_find.jsp").forward(req, resp);
        }
    }

    // ============================================================
    // GET Handlers
    // ============================================================

    private void showFind(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        String q            = req.getParameter("q");
        String subject      = req.getParameter("subject");
        String year         = req.getParameter("year");
        String meetingType  = req.getParameter("meeting_type");
        boolean availOnly   = "1".equals(req.getParameter("available"));
        int page            = parseIntOrDefault(req.getParameter("page"), 1);
        int pageSize        = 9;
        int offset          = (page - 1) * pageSize;

        java.util.List<StudyGroup> groups = groupDAO.search(q, subject, year, meetingType, availOnly, pageSize, offset);
        int total      = groupDAO.countSearch(q, subject, year, meetingType, availOnly);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("groups",      groups);
        req.setAttribute("total",       total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages",  totalPages);
        req.setAttribute("q",           q);
        req.setAttribute("subject",     subject);
        req.setAttribute("year",        year);
        req.setAttribute("meetingType", meetingType);
        req.setAttribute("availOnly",   availOnly);

        java.util.List<StudyGroup> myJoined = groupDAO.getJoinedByUser(user.getUserId());
        java.util.List<StudyGroup> myCreated = groupDAO.getByCreator(user.getUserId());
        java.util.Set<Integer> joinedGroupIds = new java.util.HashSet<>();
        if (myJoined != null) for (StudyGroup g : myJoined) joinedGroupIds.add(g.getGroupId());
        if (myCreated != null) for (StudyGroup g : myCreated) joinedGroupIds.add(g.getGroupId());
        req.setAttribute("joinedGroupIds", joinedGroupIds);

        req.getRequestDispatcher("/groups_find.jsp").forward(req, resp);
    }

    private void showMyGroups(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        java.util.List<StudyGroup> createdGroups = groupDAO.getByCreator(user.getUserId());
        java.util.List<StudyGroup> joinedGroups  = groupDAO.getJoinedByUser(user.getUserId());
        req.setAttribute("createdGroups", createdGroups);
        req.setAttribute("joinedGroups",  joinedGroups);
        req.getRequestDispatcher("/my_groups.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int groupId     = parseIntOrDefault(req.getParameter("id"), 0);
        StudyGroup group = groupDAO.findById(groupId);
        if (group == null) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=find");
            return;
        }
        boolean isMember  = memberDAO.isMember(user.getUserId(), groupId);
        boolean isCreator = (group.getCreatorId() == user.getUserId());
        boolean hasReview = reviewDAO.hasReviewed(user.getUserId(), groupId);

        java.util.List<Membership>   members  = memberDAO.getMembersByGroup(groupId);
        java.util.List<StudySession> sessions = sessionDAO.getByGroup(groupId, user.getUserId());
        java.util.List<Discussion>   posts    = discDAO.getTopLevelByGroup(groupId);
        java.util.List<Review>       reviews  = reviewDAO.getByGroup(groupId);

        // Build replies map for threaded discussion display
        java.util.Map<Integer, java.util.List<Discussion>> repliesMap = new java.util.HashMap<>();
        if (posts != null) {
            for (Discussion p : posts) {
                java.util.List<Discussion> replies = discDAO.getReplies(p.getMessageId());
                if (replies != null && !replies.isEmpty()) {
                    repliesMap.put(p.getMessageId(), replies);
                }
            }
        }

        req.setAttribute("group",      group);
        req.setAttribute("isMember",   isMember);
        req.setAttribute("isCreator",  isCreator);
        req.setAttribute("hasReview",  hasReview);
        req.setAttribute("members",    members);
        req.setAttribute("sessions",   sessions);
        req.setAttribute("posts",      posts);
        req.setAttribute("reviews",    reviews);
        req.setAttribute("repliesMap", repliesMap);

        req.getRequestDispatcher("/group_detail.jsp").forward(req, resp);
    }

    private void showEdit(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int groupId = parseIntOrDefault(req.getParameter("id"), 0);
        StudyGroup group = groupDAO.findById(groupId);
        if (group == null || group.getCreatorId() != user.getUserId()) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=my");
            return;
        }
        req.setAttribute("group", group);
        req.getRequestDispatcher("/group_edit.jsp").forward(req, resp);
    }

    // ============================================================
    // POST Handlers
    // ============================================================

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        StudyGroup g = buildGroupFromRequest(req, user.getUserId());

        // Validation
        if (g.getGroupName().trim().isEmpty() || g.getSubject().trim().isEmpty() || g.getCourseCode().trim().isEmpty()) {
            req.setAttribute("error", "Group name, subject, and course code are required.");
            req.getRequestDispatcher("/group_create.jsp").forward(req, resp);
            return;
        }

        int newId = groupDAO.create(g);
        if (newId > 0) {
            // Auto-join creator as member
            memberDAO.joinGroup(user.getUserId(), newId);
            resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + newId);
        } else {
            req.setAttribute("error", "Failed to create group. Please try again.");
            req.getRequestDispatcher("/group_create.jsp").forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int groupId     = parseIntOrDefault(req.getParameter("group_id"), 0);
        StudyGroup existing = groupDAO.findById(groupId);

        if (existing == null || existing.getCreatorId() != user.getUserId()) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=my");
            return;
        }

        StudyGroup updated = buildGroupFromRequest(req, user.getUserId());
        updated.setGroupId(groupId);

        boolean ok = groupDAO.update(updated);
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId
                + (ok ? "&msg=updated" : "&error=updatefailed"));
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int groupId = parseIntOrDefault(req.getParameter("group_id"), 0);
        StudyGroup existing = groupDAO.findById(groupId);

        if (existing == null || (existing.getCreatorId() != user.getUserId() && !user.isAdmin())) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=my");
            return;
        }

        groupDAO.delete(groupId);
        resp.sendRedirect(req.getContextPath() + "/groups?action=my&msg=deleted");
    }

    private void handleJoin(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int groupId = parseIntOrDefault(req.getParameter("group_id"), 0);
        StudyGroup group = groupDAO.findById(groupId);
        if (group == null) {
            resp.sendRedirect(req.getContextPath() + "/groups");
            return;
        }

        boolean ok = memberDAO.joinGroup(user.getUserId(), groupId);
        if (ok) {
            // Notify group creator
            notifDAO.send(group.getCreatorId(),
                user.getFullName() + " joined your group: " + group.getGroupName(),
                req.getContextPath() + "/groups?action=detail&id=" + groupId);
        }
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId
                + (ok ? "&msg=joined" : "&error=full"));
    }

    private void handleLeave(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int groupId = parseIntOrDefault(req.getParameter("group_id"), 0);
        memberDAO.leaveGroup(user.getUserId(), groupId);
        resp.sendRedirect(req.getContextPath() + "/groups?action=my&msg=left");
    }

    // ============================================================
    // Helpers
    // ============================================================

    private StudyGroup buildGroupFromRequest(HttpServletRequest req, int creatorId) {
        StudyGroup g = new StudyGroup();
        g.setGroupName(nvl(req.getParameter("group_name")));
        g.setSubject(nvl(req.getParameter("subject")));
        g.setCourseCode(nvl(req.getParameter("course_code")));
        g.setDescription(nvl(req.getParameter("description")));
        g.setMeetingType(nvl(req.getParameter("meeting_type"), "Online"));
        g.setCapacity(parseIntOrDefault(req.getParameter("capacity"), 10));
        g.setCreatorId(creatorId);
        return g;
    }

    private String nvl(String s)             { return s != null ? s.trim() : ""; }
    private String nvl(String s, String def) { return (s != null && !s.trim().isEmpty()) ? s.trim() : def; }
    private int parseIntOrDefault(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
