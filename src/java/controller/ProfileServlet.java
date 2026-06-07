package controller;

import dao.UserDAO;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * ProfileServlet — Controller Layer
 * GET  /profile           → view/edit profile form
 * POST /profile?action=update|changePassword
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        String action = nvl(req.getParameter("action"));
        try {
            if ("update".equals(action)) {
                handleUpdate(req, resp, user, session);
            } else if ("changePassword".equals(action)) {
                handleChangePassword(req, resp, user);
            } else {
                resp.sendRedirect(req.getContextPath() + "/profile");
            }
        } catch (Exception e) {
            req.setAttribute("error", "System error: " + e.getMessage());
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User user, HttpSession session)
            throws Exception {
        String fullName     = nvl(req.getParameter("full_name"));
        String university   = nvl(req.getParameter("university"));
        String major        = nvl(req.getParameter("major"));
        String academicYear = req.getParameter("academic_year");

        if (fullName.trim().isEmpty()) {
            req.setAttribute("error", "Full name is required.");
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            return;
        }

        user.setFullName(fullName);
        user.setUniversity(university);
        user.setMajor(major);
        user.setAcademicYear(academicYear);

        boolean ok = userDAO.updateProfile(user);
        if (ok) {
            // Refresh session with updated user data
            User refreshed = userDAO.findById(user.getUserId());
            session.setAttribute("loggedUser", refreshed);
            req.setAttribute("success", "Profile updated successfully!");
        } else {
            req.setAttribute("error", "Failed to update profile.");
        }
        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse resp, User user)
            throws Exception {
        String current  = nvl(req.getParameter("current_password"));
        String newPass  = nvl(req.getParameter("new_password"));
        String confirm  = nvl(req.getParameter("confirm_password"));

        if (!newPass.equals(confirm)) {
            req.setAttribute("error", "New passwords do not match.");
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            return;
        }
        if (newPass.length() < 8) {
            req.setAttribute("error", "Password must be at least 8 characters.");
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            return;
        }
        if (!userDAO.verifyPassword(user.getUserId(), current)) {
            req.setAttribute("error", "Current password is incorrect.");
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            return;
        }

        boolean ok = userDAO.changePassword(user.getUserId(), newPass);
        if (ok) {
            req.setAttribute("success", "Password changed successfully!");
        } else {
            req.setAttribute("error", "Failed to change password.");
        }
        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    private String nvl(String s) { return s != null ? s.trim() : ""; }
}
