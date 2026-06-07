package controller;

import dao.*;
import model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * DiscussionServlet — Controller Layer
 * Handles discussion board post/reply CRUD.
 * POST /discussion?action=post|reply|edit|delete
 */
@WebServlet("/discussion")
public class DiscussionServlet extends HttpServlet {

    private final DiscussionDAO   discDAO   = new DiscussionDAO();
    private final NotificationDAO notifDAO  = new NotificationDAO();
    private final MembershipDAO   memberDAO = new MembershipDAO();
    private final StudyGroupDAO   groupDAO  = new StudyGroupDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        String action = nvl(req.getParameter("action"));
        int    groupId = parseInt(req.getParameter("group_id"), 0);

        try {
            if ("post".equals(action)) {
                handlePost(req, resp, user, groupId);
            } else if ("reply".equals(action)) {
                handleReply(req, resp, user, groupId);
            } else if ("edit".equals(action)) {
                handleEdit(req, resp, user, groupId);
            } else if ("delete".equals(action)) {
                handleDelete(req, resp, user, groupId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=discussion");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=discussion");
        }
    }

    private void handlePost(HttpServletRequest req, HttpServletResponse resp, User user, int groupId)
            throws Exception {
        String content = nvl(req.getParameter("content"));
        if (content.trim().isEmpty()) {
            resp.sendRedirect(redirectToBoard(req, groupId));
            return;
        }
        // Only members can post
        if (!memberDAO.isMember(user.getUserId(), groupId)) {
            resp.sendRedirect(redirectToBoard(req, groupId));
            return;
        }

        Discussion d = new Discussion();
        d.setGroupId(groupId);
        d.setUserId(user.getUserId());
        d.setContent(content);
        discDAO.create(d);

        // Notify other group members
        StudyGroup group = groupDAO.findById(groupId);
        notifDAO.notifyGroupMembers(groupId, user.getUserId(),
            user.getFullName() + " posted in '" + (group != null ? group.getGroupName() : "your group") + "'",
            req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=discussion");

        resp.sendRedirect(redirectToBoard(req, groupId));
    }

    private void handleReply(HttpServletRequest req, HttpServletResponse resp, User user, int groupId)
            throws Exception {
        int    parentId = parseInt(req.getParameter("parent_id"), 0);
        String content  = nvl(req.getParameter("content"));
        if (content.trim().isEmpty()) {
            resp.sendRedirect(redirectToBoard(req, groupId));
            return;
        }

        Discussion d = new Discussion();
        d.setGroupId(groupId);
        d.setUserId(user.getUserId());
        d.setParentId(parentId);
        d.setContent(content);
        discDAO.create(d);

        // Notify original poster
        Discussion parent = discDAO.findById(parentId);
        if (parent != null && parent.getUserId() != user.getUserId()) {
            notifDAO.send(parent.getUserId(),
                user.getFullName() + " replied to your post.",
                req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=discussion");
        }

        resp.sendRedirect(redirectToBoard(req, groupId));
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp, User user, int groupId)
            throws Exception {
        int    messageId = parseInt(req.getParameter("message_id"), 0);
        String content   = nvl(req.getParameter("content"));
        discDAO.update(messageId, content, user.getUserId());
        resp.sendRedirect(redirectToBoard(req, groupId));
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User user, int groupId)
            throws Exception {
        int messageId = parseInt(req.getParameter("message_id"), 0);
        Discussion d  = discDAO.findById(messageId);
        if (d != null && (d.getUserId() == user.getUserId() || user.isAdmin())) {
            discDAO.delete(messageId);
        }
        resp.sendRedirect(redirectToBoard(req, groupId));
    }

    private String redirectToBoard(HttpServletRequest req, int groupId) {
        return req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=discussion";
    }

    private String nvl(String s)            { return s != null ? s.trim() : ""; }
    private int parseInt(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}
