package dao;

import java.sql.*;
import java.util.*;
import model.Review;
import util.DBConnection;

/**
 * DAO - ReviewDAO
 * Handles review/rating CRUD for study groups.
 */
public class ReviewDAO {

    /** Submit or update a review (one review per user per group) */
    public boolean submitReview(Review r) throws SQLException {
        String sql = "INSERT INTO reviews (user_id, group_id, rating, review_text) VALUES (?,?,?,?) " +
                     "ON DUPLICATE KEY UPDATE rating=VALUES(rating), review_text=VALUES(review_text), created_at=NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, r.getUserId());
            ps.setInt(2, r.getGroupId());
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getReviewText());
            return ps.executeUpdate() > 0;
        }
    }

    /** Delete a review */
    public boolean delete(int reviewId) throws SQLException {
        String sql = "DELETE FROM reviews WHERE review_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Get all reviews for a group */
    public List<Review> getByGroup(int groupId) throws SQLException {
        String sql = "SELECT r.*, u.full_name AS reviewer_name, u.profile_pic AS reviewer_pic " +
                     "FROM reviews r JOIN users u ON u.user_id=r.user_id " +
                     "WHERE r.group_id=? ORDER BY r.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            List<Review> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }

    /** Check if user already reviewed a group */
    public boolean hasReviewed(int userId, int groupId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reviews WHERE user_id=? AND group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    /** Get a user's review for a group */
    public Review getUserReview(int userId, int groupId) throws SQLException {
        String sql = "SELECT r.*, u.full_name AS reviewer_name, u.profile_pic AS reviewer_pic " +
                     "FROM reviews r JOIN users u ON u.user_id=r.user_id " +
                     "WHERE r.user_id=? AND r.group_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("review_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setGroupId(rs.getInt("group_id"));
        r.setRating(rs.getInt("rating"));
        r.setReviewText(rs.getString("review_text"));
        r.setCreatedAt(rs.getString("created_at"));
        r.setReviewerName(rs.getString("reviewer_name"));
        String pic = rs.getString("reviewer_pic");
        r.setReviewerPic(pic != null ? pic : "default.png");
        return r;
    }
}
