package model;

/**
 * POJO - StudySession entity
 * Represents a row in the 'study_sessions' table
 */
public class StudySession {
    private int    sessionId;
    private int    groupId;
    private String sessionTitle;
    private String sessionDate;
    private String sessionTime;
    private int    durationMins;
    private String location;
    private String meetingLink;
    private int    createdBy;
    private String createdAt;
    // Joined fields
    private String groupName;
    private String creatorName;
    private int attendeeCount;
    private boolean isUserAttending;

    public StudySession() {}

    public int    getSessionId()       { return sessionId; }
    public void   setSessionId(int v)  { sessionId = v; }

    public int  getGroupId()       { return groupId; }
    public void setGroupId(int v)  { groupId = v; }

    public String getSessionTitle()          { return sessionTitle; }
    public void   setSessionTitle(String v)  { sessionTitle = v; }

    public String getSessionDate()          { return sessionDate; }
    public void   setSessionDate(String v)  { sessionDate = v; }

    public String getSessionTime()          { return sessionTime; }
    public void   setSessionTime(String v)  { sessionTime = v; }

    public int  getDurationMins()       { return durationMins; }
    public void setDurationMins(int v)  { durationMins = v; }

    public String getLocation()          { return location; }
    public void   setLocation(String v)  { location = v; }

    public String getMeetingLink()          { return meetingLink; }
    public void   setMeetingLink(String v)  { meetingLink = v; }

    public int  getCreatedBy()       { return createdBy; }
    public void setCreatedBy(int v)  { createdBy = v; }

    public String getCreatedAt()          { return createdAt; }
    public void   setCreatedAt(String v)  { createdAt = v; }

    public String getGroupName()          { return groupName; }
    public void   setGroupName(String v)  { groupName = v; }

    public String getCreatorName()          { return creatorName; }
    public void   setCreatorName(String v)  { creatorName = v; }

    public int  getAttendeeCount()       { return attendeeCount; }
    public void setAttendeeCount(int v)  { attendeeCount = v; }

    public boolean isUserAttending()       { return isUserAttending; }
    public void    setUserAttending(boolean v) { isUserAttending = v; }

    /** Format duration: "90 mins" → "1h 30m" */
    public String getFormattedDuration() {
        if (durationMins < 60) return durationMins + " mins";
        int h = durationMins / 60, m = durationMins % 60;
        return m == 0 ? h + "h" : h + "h " + m + "m";
    }
}
