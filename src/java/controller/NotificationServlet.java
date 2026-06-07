package controller;

import dao.NotificationDAO;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * NotificationServlet — Controller Layer
 * GET  /notifications          → view all notifications
 * POST /notifications?action=markAllRead|markRead
 */
@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notifDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        try {
            java.util.List<model.Notification> notifications = notifDAO.getForUser(user.getUserId());
            // Mark all as read when page is opened
            notifDAO.markAllRead(user.getUserId());
            req.setAttribute("notifications", notifications);
            req.getRequestDispatcher("/views/notifications/index.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/views/notifications/index.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        String action = req.getParameter("action");
        try {
            if ("markAllRead".equals(action)) {
                notifDAO.markAllRead(user.getUserId());
            } else if ("markRead".equals(action)) {
                int nid = Integer.parseInt(req.getParameter("id"));
                notifDAO.markRead(nid);
            }
        } catch (Exception e) { /* ignore */ }

        resp.sendRedirect(req.getContextPath() + "/notifications");
    }
}
