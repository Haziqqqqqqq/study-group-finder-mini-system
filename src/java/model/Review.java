package model;

/**
 * POJO - Review entity
 */
public class Review {
    private int    reviewId;
    private int    userId;
    private int    groupId;
    private int    rating;     // 1-5
    private String reviewText;
    private String createdAt;
    // Joined fields
    private String reviewerName;
    private String reviewerPic;

    public Review() {}

    public int    getReviewId()       { return reviewId; }
    public void   setReviewId(int v)  { reviewId = v; }

    public int  getUserId()       { return userId; }
    public void setUserId(int v)  { userId = v; }

    public int  getGroupId()       { return groupId; }
    public void setGroupId(int v)  { groupId = v; }

    public int  getRating()       { return rating; }
    public void setRating(int v)  { rating = v; }

    public String getReviewText()          { return reviewText; }
    public void   setReviewText(String v)  { reviewText = v; }

    public String getCreatedAt()          { return createdAt; }
    public void   setCreatedAt(String v)  { createdAt = v; }

    public String getReviewerName()          { return reviewerName; }
    public void   setReviewerName(String v)  { reviewerName = v; }

    public String getReviewerPic()          { return reviewerPic; }
    public void   setReviewerPic(String v)  { reviewerPic = v; }

    /** Get stars */
    public String getStars() {
        StringBuilder sb = new StringBuilder();
        for(int i=0; i<rating; i++) sb.append("★");
        for(int i=0; i<(5-rating); i++) sb.append("☆");
        return sb.toString();
    }
}
