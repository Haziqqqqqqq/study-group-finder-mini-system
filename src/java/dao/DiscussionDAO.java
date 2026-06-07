package dao;

import java.sql.*;
import java.util.*;
import model.Discussion;
import util.DBConnection;

/**
 * DAO - DiscussionDAO
 * Handles threaded discussion board operations.
 */
public class DiscussionDAO {

    /** Create a new post or reply */
    public int create(Discussion d) throws SQLException {
        String sql = "INSERT INTO discussions (group_id, user_id, parent_id, content) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, d.getGroupId());
            ps.setInt(2, d.getUserId());
            if (d.getParentId() != null) ps.setInt(3, d.getParentId());
            else ps.setNull(3, Types.INTEGER);
            ps.setString(4, d.getContent().trim());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        }
    }

    /** Update a post's content */
    public boolean update(int messageId, String newContent, int userId) throws SQLException {
        String sql = "UPDATE discussions SET content=?, updated_at=NOW() WHERE message_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newContent.trim());
            ps.setInt(2, messageId);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Delete a post (owner or admin) */
    public boolean delete(int messageId) throws SQLException {
        String sql = "DELETE FROM discussions WHERE message_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Get top-level posts for a group (with reply counts) */
    public List<Discussion> getTopLevelByGroup(int groupId) throws SQLException {
        String sql = "SELECT d.*, u.full_name AS author_name, u.profile_pic AS author_pic, " +
                     "(SELECT COUNT(*) FROM discussions r WHERE r.parent_id=d.message_id) AS reply_count " +
                     "FROM discussions d JOIN users u ON u.user_id=d.user_id " +
                     "WHERE d.group_id=? AND d.parent_id IS NULL " +
                     "ORDER BY d.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            List<Discussion> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Get replies to a specific post */
    public List<Discussion> getReplies(int parentId) throws SQLException {
        String sql = "SELECT d.*, u.full_name AS author_name, u.profile_pic AS author_pic, 0 AS reply_count " +
                     "FROM discussions d JOIN users u ON u.user_id=d.user_id " +
                     "WHERE d.parent_id=? ORDER BY d.created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ResultSet rs = ps.executeQuery();
            List<Discussion> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Find a single post by ID */
    public Discussion findById(int messageId) throws SQLException {
        String sql = "SELECT d.*, u.full_name AS author_name, u.profile_pic AS author_pic, 0 AS reply_count " +
                     "FROM discussions d JOIN users u ON u.user_id=d.user_id WHERE d.message_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    private Discussion mapRow(ResultSet rs) throws SQLException {
        Discussion d = new Discussion();
        d.setMessageId(rs.getInt("message_id"));
        d.setGroupId(rs.getInt("group_id"));
        d.setUserId(rs.getInt("user_id"));
        int pid = rs.getInt("parent_id");
        d.setParentId(rs.wasNull() ? null : pid);
        d.setContent(rs.getString("content"));
        d.setCreatedAt(rs.getString("created_at"));
        d.setUpdatedAt(rs.getString("updated_at"));
        d.setAuthorName(rs.getString("author_name"));
        String pic = rs.getString("author_pic");
        d.setAuthorPic(pic != null ? pic : "default.png");
        d.setReplyCount(rs.getInt("reply_count"));
        return d;
    }
}
