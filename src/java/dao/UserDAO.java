package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.User;
import util.DBConnection;

/**
 * DAO - UserDAO
 * All database operations for the users table.
 * Uses PreparedStatements to prevent SQL injection.
 */
public class UserDAO {

    /** Register new student — returns true on success */
    public boolean register(User user, String rawPassword) throws SQLException {
        String sql = "INSERT INTO users (full_name, email, password, university, major, academic_year) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName().trim());
            ps.setString(2, user.getEmail().toLowerCase().trim());
            ps.setString(3, rawPassword);
            ps.setString(4, user.getUniversity());
            ps.setString(5, user.getMajor());
            ps.setString(6, user.getAcademicYear());
            return ps.executeUpdate() > 0;
        }
    }

    /** Authenticate user — returns User object or null */
    public User authenticate(String email, String rawPassword) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.toLowerCase().trim());
            ps.setString(2, rawPassword);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    /** Find user by ID */
    public User findById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    /** Check if email already registered */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.toLowerCase().trim());
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    /** Update profile (excluding email and password) */
    public boolean updateProfile(User user) throws SQLException {
        String sql = "UPDATE users SET full_name=?, university=?, major=?, academic_year=?, updated_at=NOW() " +
                     "WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getUniversity());
            ps.setString(3, user.getMajor());
            ps.setString(4, user.getAcademicYear());
            ps.setInt(5, user.getUserId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Change password */
    public boolean changePassword(int userId, String newRawPassword) throws SQLException {
        String sql = "UPDATE users SET password=?, updated_at=NOW() WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newRawPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Update profile picture filename */
    public boolean updateProfilePic(int userId, String filename) throws SQLException {
        String sql = "UPDATE users SET profile_pic=?, updated_at=NOW() WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, filename);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Get all users (admin) */
    public List<User> getAllUsers() throws SQLException {
        List<User> list = new ArrayList<User>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /** Delete user (admin) */
    public boolean deleteUser(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Count total students */
    public int countStudents() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE role='student'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Verify current password (for change-password check) */
    public boolean verifyPassword(int userId, String rawPassword) throws SQLException {
        String sql = "SELECT password FROM users WHERE user_id=? AND password=? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, rawPassword);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    /** Map ResultSet row to User object */
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setUniversity(rs.getString("university"));
        u.setMajor(rs.getString("major"));
        u.setAcademicYear(rs.getString("academic_year"));
        u.setProfilePic(rs.getString("profile_pic") != null ? rs.getString("profile_pic") : "default.png");
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getString("created_at"));
        return u;
    }
}
