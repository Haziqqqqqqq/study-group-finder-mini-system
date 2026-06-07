package dao;

import java.sql.*;
import java.util.*;
import model.Membership;
import util.DBConnection;

/**
 * DAO - MembershipDAO
 * Handles join, leave, and member listing operations.
 */
public class MembershipDAO {

    /** Join a group — returns false if already a member or group is full */
    public boolean joinGroup(int userId, int groupId) throws SQLException {
        // Check capacity
        String capSql = "SELECT capacity, " +
                        "(SELECT COUNT(*) FROM memberships WHERE group_id=? AND status='active') AS cnt " +
                        "FROM study_groups WHERE group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(capSql)) {
            ps.setInt(1, groupId);
            ps.setInt(2, groupId);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getInt("cnt") >= rs.getInt("capacity")) {
                return false; // Group is full
            }
        }

        // Upsert membership (re-join if left before)
        String sql = "INSERT INTO memberships (user_id, group_id, status) VALUES (?, ?, 'active') " +
                     "ON DUPLICATE KEY UPDATE status='active', join_date=NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Leave a group */
    public boolean leaveGroup(int userId, int groupId) throws SQLException {
        String sql = "UPDATE memberships SET status='left' WHERE user_id=? AND group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Check if user is an active member of a group */
    public boolean isMember(int userId, int groupId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM memberships WHERE user_id=? AND group_id=? AND status='active'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    /** Get all active members of a group with user details */
    public List<Membership> getMembersByGroup(int groupId) throws SQLException {
        String sql = "SELECT mb.*, u.full_name, u.email, u.major, u.academic_year, u.profile_pic " +
                     "FROM memberships mb JOIN users u ON u.user_id=mb.user_id " +
                     "WHERE mb.group_id=? AND mb.status='active' ORDER BY mb.join_date ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            List<Membership> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Remove a member from a group (admin/creator action) */
    public boolean removeMember(int userId, int groupId) throws SQLException {
        String sql = "DELETE FROM memberships WHERE user_id=? AND group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            return ps.executeUpdate() > 0;
        }
    }

    private Membership mapRow(ResultSet rs) throws SQLException {
        Membership m = new Membership();
        m.setMembershipId(rs.getInt("membership_id"));
        m.setUserId(rs.getInt("user_id"));
        m.setGroupId(rs.getInt("group_id"));
        m.setJoinDate(rs.getString("join_date"));
        m.setStatus(rs.getString("status"));
        m.setFullName(rs.getString("full_name"));
        m.setEmail(rs.getString("email"));
        m.setMajor(rs.getString("major"));
        m.setAcademicYear(rs.getString("academic_year"));
        m.setProfilePic(rs.getString("profile_pic") != null ? rs.getString("profile_pic") : "default.png");
        return m;
    }
}
