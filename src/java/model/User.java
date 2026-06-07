package model;

/**
 * POJO - User entity
 * Represents a row in the 'users' table
 */
public class User {
    private int userId;
    private String fullName;
    private String email;
    private String password;
    private String university;
    private String major;
    private String academicYear;
    private String profilePic;
    private String role;        // "student" or "admin"
    private String createdAt;

    public User() {}

    public User(int userId, String fullName, String email, String university,
                String major, String academicYear, String profilePic, String role) {
        this.userId       = userId;
        this.fullName     = fullName;
        this.email        = email;
        this.university   = university;
        this.major        = major;
        this.academicYear = academicYear;
        this.profilePic   = profilePic;
        this.role         = role;
    }

    // ---- Getters & Setters ----
    public int    getUserId()       { return userId; }
    public void   setUserId(int v)  { userId = v; }

    public String getFullName()          { return fullName; }
    public void   setFullName(String v)  { fullName = v; }

    public String getEmail()          { return email; }
    public void   setEmail(String v)  { email = v; }

    public String getPassword()          { return password; }
    public void   setPassword(String v)  { password = v; }

    public String getUniversity()          { return university; }
    public void   setUniversity(String v)  { university = v; }

    public String getMajor()          { return major; }
    public void   setMajor(String v)  { major = v; }

    public String getAcademicYear()          { return academicYear; }
    public void   setAcademicYear(String v)  { academicYear = v; }

    public String getProfilePic()          { return profilePic; }
    public void   setProfilePic(String v)  { profilePic = v; }

    public String getRole()          { return role; }
    public void   setRole(String v)  { role = v; }

    public String getCreatedAt()          { return createdAt; }
    public void   setCreatedAt(String v)  { createdAt = v; }

    public boolean isAdmin()   { return "admin".equals(role); }
    public boolean isStudent() { return "student".equals(role); }

    @Override
    public String toString() {
        return "User{userId=" + userId + ", fullName='" + fullName + "', email='" + email + "', role='" + role + "'}";
    }
}
