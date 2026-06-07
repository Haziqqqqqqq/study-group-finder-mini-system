package controller;

import dao.*;
import model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * SessionServlet — Controller Layer
 * Handles study session scheduling CRUD within a group.
 * POST /sessions?action=create|update|delete
 * GET  /sessions?action=create&groupId=X
 */
@WebServlet("/sessions")
public class SessionServlet extends HttpServlet {

    private final StudySessionDAO sessionDAO = new StudySessionDAO();
    private final NotificationDAO notifDAO   = new NotificationDAO();
    private final MembershipDAO   memberDAO  = new MembershipDAO();
    private final StudyGroupDAO   groupDAO   = new StudyGroupDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        String action = nvl(req.getParameter("action"), "list");

        try {
            if ("create".equals(action)) {
                int groupId = parseInt(req.getParameter("groupId"), 0);
                StudyGroup g = groupDAO.findById(groupId);
                req.setAttribute("group", g);
                req.getRequestDispatcher("/session_create.jsp").forward(req, resp);
            } else if ("edit".equals(action)) {
                int sid = parseInt(req.getParameter("id"), 0);
                StudySession s = sessionDAO.findById(sid);
                if (s == null || s.getCreatedBy() != user.getUserId()) {
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                    return;
                }
                req.setAttribute("sessionData", s);
                req.getRequestDispatcher("/session_edit.jsp").forward(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        String action = nvl(req.getParameter("action"), "");
        try {
            if ("create".equals(action)) {
                handleCreate(req, resp, user);
            } else if ("update".equals(action)) {
                handleUpdate(req, resp, user);
            } else if ("delete".equals(action)) {
                handleDelete(req, resp, user);
            } else if ("attend".equals(action)) {
                handleAttend(req, resp, user);
            } else if ("unattend".equals(action)) {
                handleUnattend(req, resp, user);
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int groupId = parseInt(req.getParameter("group_id"), 0);

        // Only group members can schedule sessions
        if (!memberDAO.isMember(user.getUserId(), groupId)) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId);
            return;
        }

        StudySession s = buildFromRequest(req, user.getUserId());
        int newId = sessionDAO.create(s);

        if (newId > 0) {
            StudyGroup group = groupDAO.findById(groupId);
            // Notify all group members about the new session
            notifDAO.notifyGroupMembers(groupId, user.getUserId(),
                "New session scheduled in '" + (group != null ? group.getGroupName() : "your group") + "': " + s.getSessionTitle(),
                req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=sessions");
        }
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=sessions");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int sid = parseInt(req.getParameter("session_id"), 0);
        StudySession existing = sessionDAO.findById(sid);
        if (existing == null || existing.getCreatedBy() != user.getUserId()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        StudySession updated = buildFromRequest(req, user.getUserId());
        updated.setSessionId(sid);
        sessionDAO.update(updated);
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + existing.getGroupId() + "&tab=sessions");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        int sid = parseInt(req.getParameter("session_id"), 0);
        int sessionId = parseInt(req.getParameter("session_id"), 0);
        StudySession existing = sessionDAO.findById(sessionId);
        if (existing == null || (existing.getCreatedBy() != user.getUserId() && !user.isAdmin())) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        int groupId = existing.getGroupId();
        boolean ok = sessionDAO.delete(sessionId);
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId 
                + "&tab=sessions" + (ok ? "&msg=sessiondeleted" : "&error=deletefailed"));
    }

    private void handleAttend(HttpServletRequest req, HttpServletResponse resp, User user) throws Exception {
        int sessionId = parseInt(req.getParameter("session_id"), 0);
        int groupId = parseInt(req.getParameter("group_id"), 0);
        sessionDAO.attendSession(sessionId, user.getUserId());
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=sessions");
    }

    private void handleUnattend(HttpServletRequest req, HttpServletResponse resp, User user) throws Exception {
        int sessionId = parseInt(req.getParameter("session_id"), 0);
        int groupId = parseInt(req.getParameter("group_id"), 0);
        sessionDAO.unattendSession(sessionId, user.getUserId());
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=sessions");
    }

    private StudySession buildFromRequest(HttpServletRequest req, int createdBy) {
        StudySession s = new StudySession();
        s.setGroupId(parseInt(req.getParameter("group_id"), 0));
        s.setSessionTitle(nvl(req.getParameter("session_title")));
        s.setSessionDate(nvl(req.getParameter("session_date")));
        s.setSessionTime(nvl(req.getParameter("session_time")));
        s.setDurationMins(parseInt(req.getParameter("duration_mins"), 60));
        s.setLocation(req.getParameter("location"));
        s.setMeetingLink(req.getParameter("meeting_link"));
        s.setCreatedBy(createdBy);
        return s;
    }

    private String nvl(String s)             { return s != null ? s.trim() : ""; }
    private String nvl(String s, String def) { return (s != null && !s.trim().isEmpty()) ? s.trim() : def; }
    private int parseInt(String s, int def)  { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}
