package model;

/**
 * POJO - Membership entity
 * Represents a row in the 'memberships' table
 */
public class Membership {
    private int    membershipId;
    private int    userId;
    private int    groupId;
    private String joinDate;
    private String status;      // active / pending / left
    // Joined fields
    private String fullName;
    private String email;
    private String major;
    private String academicYear;
    private String profilePic;

    public Membership() {}

    public int    getMembershipId()       { return membershipId; }
    public void   setMembershipId(int v)  { membershipId = v; }

    public int  getUserId()       { return userId; }
    public void setUserId(int v)  { userId = v; }

    public int  getGroupId()       { return groupId; }
    public void setGroupId(int v)  { groupId = v; }

    public String getJoinDate()          { return joinDate; }
    public void   setJoinDate(String v)  { joinDate = v; }

    public String getStatus()          { return status; }
    public void   setStatus(String v)  { status = v; }

    public String getFullName()          { return fullName; }
    public void   setFullName(String v)  { fullName = v; }

    public String getEmail()          { return email; }
    public void   setEmail(String v)  { email = v; }

    public String getMajor()          { return major; }
    public void   setMajor(String v)  { major = v; }

    public String getAcademicYear()          { return academicYear; }
    public void   setAcademicYear(String v)  { academicYear = v; }

    public String getProfilePic()          { return profilePic; }
    public void   setProfilePic(String v)  { profilePic = v; }
}
