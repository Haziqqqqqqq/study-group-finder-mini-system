package model;

/**
 * POJO - Notification entity
 */
public class Notification {
    private int    notificationId;
    private int    userId;
    private String message;
    private String link;
    private boolean read;
    private String createdAt;

    public Notification() {}

    public int    getNotificationId()       { return notificationId; }
    public void   setNotificationId(int v)  { notificationId = v; }

    public int  getUserId()       { return userId; }
    public void setUserId(int v)  { userId = v; }

    public String getMessage()          { return message; }
    public void   setMessage(String v)  { message = v; }

    public String getLink()          { return link; }
    public void   setLink(String v)  { link = v; }

    public boolean isRead()        { return read; }
    public void    setRead(boolean v){ read = v; }

    public String getCreatedAt()          { return createdAt; }
    public void   setCreatedAt(String v)  { createdAt = v; }
}
