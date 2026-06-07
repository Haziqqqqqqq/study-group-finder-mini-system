package dao;

import java.sql.*;
import java.util.*;
import model.StudyGroup;
import util.DBConnection;

/**
 * DAO - StudyGroupDAO
 * All database operations for study_groups and search/filter logic.
 */
public class StudyGroupDAO {

    /** Create group — returns generated group_id or -1 */
    public int create(StudyGroup g) throws SQLException {
        String sql = "INSERT INTO study_groups (group_name, subject, course_code, description, meeting_type, capacity, creator_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, g.getGroupName().trim());
            ps.setString(2, g.getSubject().trim());
            ps.setString(3, g.getCourseCode().toUpperCase().trim());
            ps.setString(4, g.getDescription());
            ps.setString(5, g.getMeetingType());
            ps.setInt(6, g.getCapacity());
            ps.setInt(7, g.getCreatorId());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        }
    }

    /** Update group */
    public boolean update(StudyGroup g) throws SQLException {
        String sql = "UPDATE study_groups SET group_name=?, subject=?, course_code=?, description=?, " +
                     "meeting_type=?, capacity=?, updated_at=NOW() WHERE group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, g.getGroupName().trim());
            ps.setString(2, g.getSubject().trim());
            ps.setString(3, g.getCourseCode().toUpperCase().trim());
            ps.setString(4, g.getDescription());
            ps.setString(5, g.getMeetingType());
            ps.setInt(6, g.getCapacity());
            ps.setInt(7, g.getGroupId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Delete group */
    public boolean delete(int groupId) throws SQLException {
        String sql = "DELETE FROM study_groups WHERE group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Find group by ID with creator name, member count, avg rating */
    public StudyGroup findById(int groupId) throws SQLException {
        String sql = "SELECT sg.*, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM memberships m WHERE m.group_id=sg.group_id AND m.status='active') AS member_count, " +
                     "(sg.capacity - (SELECT COUNT(*) FROM memberships mc WHERE mc.group_id=sg.group_id AND mc.status='active')) AS slots_left, " +
                     "COALESCE((SELECT AVG(r.rating) FROM reviews r WHERE r.group_id=sg.group_id),0) AS avg_rating, " +
                     "(SELECT COUNT(*) FROM reviews rv WHERE rv.group_id=sg.group_id) AS review_count " +
                     "FROM study_groups sg JOIN users u ON u.user_id=sg.creator_id " +
                     "WHERE sg.group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    /**
     * Search + filter groups.
     * Supports: keyword (q), subject, academicYear, meetingType, available slots only.
     */
    public List<StudyGroup> search(String q, String subject, String academicYear, String meetingType, boolean availableOnly, int limit, int offset) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT sg.*, u.full_name AS creator_name, " +
            "(SELECT COUNT(*) FROM memberships m WHERE m.group_id=sg.group_id AND m.status='active') AS member_count, " +
            "(sg.capacity - (SELECT COUNT(*) FROM memberships mc WHERE mc.group_id=sg.group_id AND mc.status='active')) AS slots_left, " +
            "COALESCE((SELECT AVG(r.rating) FROM reviews r WHERE r.group_id=sg.group_id),0) AS avg_rating " +
            "FROM study_groups sg JOIN users u ON u.user_id=sg.creator_id " +
            "WHERE sg.is_active=1 "
        );
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sb.append("AND (sg.group_name LIKE ? OR sg.course_code LIKE ?) ");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }
        if (subject != null && !subject.trim().isEmpty()) {
            sb.append("AND sg.subject = ? ");
            params.add(subject);
        }
        if (academicYear != null && !academicYear.trim().isEmpty()) {
            sb.append("AND u.academic_year = ? ");
            params.add(academicYear);
        }
        if (meetingType != null && !meetingType.trim().isEmpty()) {
            sb.append("AND sg.meeting_type = ? ");
            params.add(meetingType);
        }
        if (availableOnly) {
            sb.append("AND (sg.capacity - (SELECT COUNT(*) FROM memberships av WHERE av.group_id=sg.group_id AND av.status='active')) > 0 ");
        }
        sb.append("ORDER BY sg.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) ps.setInt(i + 1, (Integer) params.get(i));
                else ps.setString(i + 1, (String) params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            List<StudyGroup> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Count matching groups for pagination */
    public int countSearch(String q, String subject, String academicYear, String meetingType, boolean availableOnly) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT COUNT(*) FROM study_groups sg JOIN users u ON u.user_id=sg.creator_id WHERE sg.is_active=1 "
        );
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sb.append("AND (sg.group_name LIKE ? OR sg.course_code LIKE ?) ");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }
        if (subject != null && !subject.trim().isEmpty()) {
            sb.append("AND sg.subject = ? ");
            params.add(subject);
        }
        if (academicYear != null && !academicYear.trim().isEmpty()) {
            sb.append("AND u.academic_year = ? ");
            params.add(academicYear);
        }
        if (meetingType != null && !meetingType.trim().isEmpty()) {
            sb.append("AND sg.meeting_type = ? ");
            params.add(meetingType);
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setString(i + 1, (String) params.get(i));
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Groups created by a specific user */
    public List<StudyGroup> getByCreator(int userId) throws SQLException {
        String sql = "SELECT sg.*, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM memberships m WHERE m.group_id=sg.group_id AND m.status='active') AS member_count, " +
                     "(sg.capacity - (SELECT COUNT(*) FROM memberships mc WHERE mc.group_id=sg.group_id AND mc.status='active')) AS slots_left, " +
                     "0.0 AS avg_rating " +
                     "FROM study_groups sg JOIN users u ON u.user_id=sg.creator_id " +
                     "WHERE sg.creator_id=? AND sg.is_active=1 ORDER BY sg.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            List<StudyGroup> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Groups joined by a user (not created by them) */
    public List<StudyGroup> getJoinedByUser(int userId) throws SQLException {
        String sql = "SELECT sg.*, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM memberships m WHERE m.group_id=sg.group_id AND m.status='active') AS member_count, " +
                     "(sg.capacity - (SELECT COUNT(*) FROM memberships mc WHERE mc.group_id=sg.group_id AND mc.status='active')) AS slots_left, " +
                     "0.0 AS avg_rating " +
                     "FROM memberships mb " +
                     "JOIN study_groups sg ON sg.group_id=mb.group_id " +
                     "JOIN users u ON u.user_id=sg.creator_id " +
                     "WHERE mb.user_id=? AND mb.status='active' AND sg.creator_id != ? " +
                     "ORDER BY mb.join_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            List<StudyGroup> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** All groups for admin view */
    public List<StudyGroup> getAllForAdmin() throws SQLException {
        String sql = "SELECT sg.*, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM memberships m WHERE m.group_id=sg.group_id AND m.status='active') AS member_count, " +
                     "0 AS slots_left, 0.0 AS avg_rating " +
                     "FROM study_groups sg JOIN users u ON u.user_id=sg.creator_id ORDER BY sg.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            List<StudyGroup> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Total active groups count */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM study_groups WHERE is_active=1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private StudyGroup mapRow(ResultSet rs) throws SQLException {
        StudyGroup g = new StudyGroup();
        g.setGroupId(rs.getInt("group_id"));
        g.setGroupName(rs.getString("group_name"));
        g.setSubject(rs.getString("subject"));
        g.setCourseCode(rs.getString("course_code"));
        g.setDescription(rs.getString("description"));
        g.setMeetingType(rs.getString("meeting_type"));
        g.setCapacity(rs.getInt("capacity"));
        g.setCreatorId(rs.getInt("creator_id"));
        g.setCreatorName(rs.getString("creator_name"));
        g.setMemberCount(rs.getInt("member_count"));
        g.setSlotsLeft(rs.getInt("slots_left"));
        g.setAvgRating(rs.getDouble("avg_rating"));
        try { g.setReviewCount(rs.getInt("review_count")); } catch (Exception e) { g.setReviewCount(0); }
        g.setIsActive(rs.getInt("is_active"));
        g.setCreatedAt(rs.getString("created_at"));
        return g;
    }
}
