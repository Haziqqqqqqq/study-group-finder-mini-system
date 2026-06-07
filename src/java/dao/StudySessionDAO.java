package dao;

import java.sql.*;
import java.util.*;
import model.StudySession;
import util.DBConnection;

/**
 * DAO - StudySessionDAO
 * CRUD for study_sessions. Also notifies group members when created.
 */
public class StudySessionDAO {

    /** Create new session — returns generated ID or -1 */
    public int create(StudySession s) throws SQLException {
        String sql = "INSERT INTO study_sessions (group_id, session_title, session_date, session_time, " +
                     "duration_mins, location, meeting_link, created_by) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, s.getGroupId());
            ps.setString(2, s.getSessionTitle());
            ps.setString(3, s.getSessionDate());
            ps.setString(4, s.getSessionTime());
            ps.setInt(5, s.getDurationMins());
            ps.setString(6, s.getLocation());
            ps.setString(7, s.getMeetingLink());
            ps.setInt(8, s.getCreatedBy());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        }
    }

    /** Update session */
    public boolean update(StudySession s) throws SQLException {
        String sql = "UPDATE study_sessions SET session_title=?, session_date=?, session_time=?, " +
                     "duration_mins=?, location=?, meeting_link=?, updated_at=NOW() WHERE session_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getSessionTitle());
            ps.setString(2, s.getSessionDate());
            ps.setString(3, s.getSessionTime());
            ps.setInt(4, s.getDurationMins());
            ps.setString(5, s.getLocation());
            ps.setString(6, s.getMeetingLink());
            ps.setInt(7, s.getSessionId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Delete session */
    public boolean delete(int sessionId) throws SQLException {
        String sql = "DELETE FROM study_sessions WHERE session_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Find session by ID */
    public StudySession findById(int sessionId) throws SQLException {
        String sql = "SELECT ss.*, sg.group_name, u.full_name AS creator_name " +
                     "FROM study_sessions ss " +
                     "JOIN study_groups sg ON sg.group_id=ss.group_id " +
                     "JOIN users u ON u.user_id=ss.created_by " +
                     "WHERE ss.session_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    /** Get all sessions for a group, ordered by date/time */
    public List<StudySession> getByGroup(int groupId, int userId) throws SQLException {
        String sql = "SELECT ss.*, sg.group_name, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM session_attendees sa WHERE sa.session_id=ss.session_id) AS attendee_count, " +
                     "(SELECT COUNT(*) FROM session_attendees sa2 WHERE sa2.session_id=ss.session_id AND sa2.user_id=?) AS is_attending " +
                     "FROM study_sessions ss " +
                     "JOIN study_groups sg ON sg.group_id=ss.group_id " +
                     "JOIN users u ON u.user_id=ss.created_by " +
                     "WHERE ss.group_id=? ORDER BY ss.session_date ASC, ss.session_time ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            ResultSet rs = ps.executeQuery();
            List<StudySession> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Attend a session */
    public boolean attendSession(int sessionId, int userId) throws SQLException {
        String sql = "INSERT IGNORE INTO session_attendees (session_id, user_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Unattend a session */
    public boolean unattendSession(int sessionId, int userId) throws SQLException {
        String sql = "DELETE FROM session_attendees WHERE session_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Get upcoming sessions for a user (across all their groups) */
    public List<StudySession> getUpcomingForUser(int userId, int limit) throws SQLException {
        String sql = "SELECT ss.*, sg.group_name, u.full_name AS creator_name " +
                     "FROM study_sessions ss " +
                     "JOIN study_groups sg ON sg.group_id=ss.group_id " +
                     "JOIN users u ON u.user_id=ss.created_by " +
                     "WHERE ss.group_id IN (" +
                     "  SELECT group_id FROM memberships WHERE user_id=? AND status='active'" +
                     ") AND CONCAT(ss.session_date,' ',ss.session_time) >= NOW() " +
                     "ORDER BY ss.session_date ASC, ss.session_time ASC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            List<StudySession> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Count total sessions (admin) */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM study_sessions";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private StudySession mapRow(ResultSet rs) throws SQLException {
        StudySession s = new StudySession();
        s.setSessionId(rs.getInt("session_id"));
        s.setGroupId(rs.getInt("group_id"));
        s.setSessionTitle(rs.getString("session_title"));
        s.setSessionDate(rs.getString("session_date"));
        s.setSessionTime(rs.getString("session_time"));
        s.setDurationMins(rs.getInt("duration_mins"));
        s.setLocation(rs.getString("location"));
        s.setMeetingLink(rs.getString("meeting_link"));
        s.setCreatedBy(rs.getInt("created_by"));
        s.setCreatedAt(rs.getString("created_at"));
        
        try { s.setGroupName(rs.getString("group_name")); } catch(Exception e){}
        try { s.setCreatorName(rs.getString("creator_name")); } catch(Exception e){}
        try { s.setAttendeeCount(rs.getInt("attendee_count")); } catch(Exception e){}
        try { s.setUserAttending(rs.getInt("is_attending") > 0); } catch(Exception e){}
        
        return s;
    }
}
