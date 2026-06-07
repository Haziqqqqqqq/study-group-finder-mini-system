package controller;

import dao.*;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * AdminServlet — Controller Layer
 * Only accessible by users with role = 'admin'.
 * GET  /admin                   → admin dashboard stats
 * GET  /admin?action=users      → manage users
 * GET  /admin?action=groups     → manage groups
 * POST /admin?action=deleteUser → delete a user
 * POST /admin?action=deleteGroup → delete a group
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final UserDAO       userDAO  = new UserDAO();
    private final StudyGroupDAO groupDAO = new StudyGroupDAO();
    private final StudySessionDAO sessionDAO = new StudySessionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getAdminUser(req, resp);
        if (user == null) return;

        String action = nvl(req.getParameter("action"), "dashboard");
        try {
            if ("users".equals(action)) {
                showUsers(req, resp);
            } else if ("groups".equals(action)) {
                showGroups(req, resp);
            } else {
                showDashboard(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/admin_dashboard.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getAdminUser(req, resp);
        if (user == null) return;

        String action = nvl(req.getParameter("action"));
        try {
            if ("deleteUser".equals(action)) {
                int uid = parseInt(req.getParameter("user_id"), 0);
                userDAO.deleteUser(uid);
                resp.sendRedirect(req.getContextPath() + "/admin?action=users&msg=deleted");
            } else if ("deleteGroup".equals(action)) {
                int gid = parseInt(req.getParameter("group_id"), 0);
                groupDAO.delete(gid);
                resp.sendRedirect(req.getContextPath() + "/admin?action=groups&msg=deleted");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        req.setAttribute("totalStudents",  userDAO.countStudents());
        req.setAttribute("totalGroups",    groupDAO.countAll());
        req.setAttribute("totalSessions",  sessionDAO.countAll());
        req.setAttribute("recentUsers",    userDAO.getAllUsers());
        req.getRequestDispatcher("/admin_dashboard.jsp").forward(req, resp);
    }

    private void showUsers(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        req.setAttribute("users", userDAO.getAllUsers());
        req.getRequestDispatcher("/admin_users.jsp").forward(req, resp);
    }

    private void showGroups(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        req.setAttribute("groups", groupDAO.getAllForAdmin());
        req.getRequestDispatcher("/admin_groups.jsp").forward(req, resp);
    }

    /** Auth guard — only admins allowed */
    private User getAdminUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return null;
        }
        if (!user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return null;
        }
        return user;
    }

    private String nvl(String s, String def) { return (s != null && !s.trim().isEmpty()) ? s.trim() : def; }
    private String nvl(String s)             { return s != null ? s.trim() : ""; }
    private int parseInt(String s, int def)  { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}
