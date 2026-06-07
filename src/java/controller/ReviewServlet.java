package controller;

import dao.ReviewDAO;
import dao.MembershipDAO;
import model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * ReviewServlet — Controller Layer
 * POST /review?action=submit|delete
 */
@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO    reviewDAO = new ReviewDAO();
    private final MembershipDAO memberDAO = new MembershipDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        String action  = nvl(req.getParameter("action"));
        int    groupId = parseInt(req.getParameter("group_id"), 0);

        try {
            if ("submit".equals(action)) {
                handleSubmit(req, resp, user, groupId);
            } else if ("delete".equals(action)) {
                handleDelete(req, resp, user, groupId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=reviews");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=reviews");
        }
    }

    private void handleSubmit(HttpServletRequest req, HttpServletResponse resp, User user, int groupId)
            throws Exception {
        // Must be a group member to review
        if (!memberDAO.isMember(user.getUserId(), groupId)) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=reviews");
            return;
        }

        int    rating     = parseInt(req.getParameter("rating"), 0);
        String reviewText = nvl(req.getParameter("review_text"));

        if (rating < 1 || rating > 5) {
            resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&error=invalidrating&tab=reviews");
            return;
        }

        Review r = new Review();
        r.setUserId(user.getUserId());
        r.setGroupId(groupId);
        r.setRating(rating);
        r.setReviewText(reviewText);
        reviewDAO.submitReview(r);

        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=reviews&msg=reviewed");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User user, int groupId)
            throws Exception {
        int reviewId = parseInt(req.getParameter("review_id"), 0);
        Review existing = reviewDAO.getUserReview(user.getUserId(), groupId);
        if (existing != null && (existing.getUserId() == user.getUserId() || user.isAdmin())) {
            reviewDAO.delete(reviewId);
        }
        resp.sendRedirect(req.getContextPath() + "/groups?action=detail&id=" + groupId + "&tab=reviews");
    }

    private String nvl(String s)            { return s != null ? s.trim() : ""; }
    private int parseInt(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}
