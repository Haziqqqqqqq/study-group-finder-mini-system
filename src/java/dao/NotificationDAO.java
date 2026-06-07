package dao;

import java.sql.*;
import java.util.*;
import model.Notification;
import util.DBConnection;

/**
 * DAO - NotificationDAO
 * Handles sending and reading user notifications.
 */
public class NotificationDAO {

    /** Send notification to a single user */
    public boolean send(int userId, String message, String link) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, message, link) VALUES (?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, message);
            ps.setString(3, link);
            return ps.executeUpdate() > 0;
        }
    }

    /** Send notification to all active members of a group */
    public void notifyGroupMembers(int groupId, int excludeUserId, String message, String link) throws SQLException {
        String membersSql = "SELECT user_id FROM memberships WHERE group_id=? AND status='active' AND user_id != ?";
        String insertSql  = "INSERT INTO notifications (user_id, message, link) VALUES (?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement memberPs = conn.prepareStatement(membersSql);
             PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
            memberPs.setInt(1, groupId);
            memberPs.setInt(2, excludeUserId);
            ResultSet rs = memberPs.executeQuery();
            while (rs.next()) {
                insertPs.setInt(1, rs.getInt("user_id"));
                insertPs.setString(2, message);
                insertPs.setString(3, link);
                insertPs.addBatch();
            }
            insertPs.executeBatch();
        }
    }

    /** Get all notifications for a user (newest first) */
    public List<Notification> getForUser(int userId) throws SQLException {
        String sql = "SELECT * FROM notifications WHERE user_id=? ORDER BY created_at DESC LIMIT 50";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            List<Notification> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Count unread notifications for a user */
    public int countUnread(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Mark all notifications as read for a user */
    public boolean markAllRead(int userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read=1 WHERE user_id=? AND is_read=0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() >= 0;
        }
    }

    /** Mark a single notification as read */
    public boolean markRead(int notificationId) throws SQLException {
        String sql = "UPDATE notifications SET is_read=1 WHERE notification_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        }
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setUserId(rs.getInt("user_id"));
        n.setMessage(rs.getString("message"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getInt("is_read") == 1);
        n.setCreatedAt(rs.getString("created_at"));
        return n;
    }
}
