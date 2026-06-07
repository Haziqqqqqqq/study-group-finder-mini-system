package model;

/**
 * POJO - StudyGroup entity
 * Represents a row in the 'study_groups' table
 */
public class StudyGroup {
    private int    groupId;
    private String groupName;
    private String subject;
    private String courseCode;
    private String description;
    private String meetingType;   // Online / Physical / Hybrid
    private int    capacity;
    private int    creatorId;
    private String creatorName;   // joined from users table
    private int    memberCount;   // derived
    private int    slotsLeft;     // derived
    private double avgRating;     // derived
    private int    reviewCount;   // derived
    private int    isActive;
    private String createdAt;

    public StudyGroup() {}

    // ---- Getters & Setters ----
    public int    getGroupId()        { return groupId; }
    public void   setGroupId(int v)   { groupId = v; }

    public String getGroupName()          { return groupName; }
    public void   setGroupName(String v)  { groupName = v; }

    public String getSubject()          { return subject; }
    public void   setSubject(String v)  { subject = v; }

    public String getCourseCode()          { return courseCode; }
    public void   setCourseCode(String v)  { courseCode = v; }

    public String getDescription()          { return description; }
    public void   setDescription(String v)  { description = v; }

    public String getMeetingType()          { return meetingType; }
    public void   setMeetingType(String v)  { meetingType = v; }

    public int  getCapacity()       { return capacity; }
    public void setCapacity(int v)  { capacity = v; }

    public int  getCreatorId()       { return creatorId; }
    public void setCreatorId(int v)  { creatorId = v; }

    public String getCreatorName()          { return creatorName; }
    public void   setCreatorName(String v)  { creatorName = v; }

    public int  getMemberCount()       { return memberCount; }
    public void setMemberCount(int v)  { memberCount = v; }

    public int  getSlotsLeft()       { return slotsLeft; }
    public void setSlotsLeft(int v)  { slotsLeft = v; }

    public double getAvgRating()        { return avgRating; }
    public void   setAvgRating(double v){ avgRating = v; }

    public int  getReviewCount()       { return reviewCount; }
    public void setReviewCount(int v)  { reviewCount = v; }

    public int  getIsActive()       { return isActive; }
    public void setIsActive(int v)  { isActive = v; }

    public String getCreatedAt()          { return createdAt; }
    public void   setCreatedAt(String v)  { createdAt = v; }

    /** Returns star-rating string like "★★★★☆" */
    public String getStarRating() {
        int rounded = (int) Math.round(avgRating);
        StringBuilder sb = new StringBuilder();
        for(int i=0; i<rounded; i++) sb.append("★");
        for(int i=0; i<(5-rounded); i++) sb.append("☆");
        return sb.toString();
    }

    /** Badge color for meeting type */
    public String getMeetingTypeBadge() {
        if ("Online".equals(meetingType)) return "bg-success";
        if ("Physical".equals(meetingType)) return "bg-primary";
        return "bg-warning text-dark";
    }
}
