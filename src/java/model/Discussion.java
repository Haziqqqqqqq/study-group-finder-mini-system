package model;

/**
 * POJO - Discussion entity
 * Represents a row in the 'discussions' table.
 * Supports threaded replies via parentId.
 */
public class Discussion {
    private int    messageId;
    private int    groupId;
    private int    userId;
    private Integer parentId;   // null = top-level post
    private String content;
    private String createdAt;
    private String updatedAt;
    // Joined fields
    private String authorName;
    private String authorPic;
    private int    replyCount;  // only for top-level posts

    public Discussion() {}

    public int    getMessageId()       { return messageId; }
    public void   setMessageId(int v)  { messageId = v; }

    public int  getGroupId()       { return groupId; }
    public void setGroupId(int v)  { groupId = v; }

    public int  getUserId()       { return userId; }
    public void setUserId(int v)  { userId = v; }

    public Integer getParentId()          { return parentId; }
    public void    setParentId(Integer v) { parentId = v; }

    public String getContent()          { return content; }
    public void   setContent(String v)  { content = v; }

    public String getCreatedAt()          { return createdAt; }
    public void   setCreatedAt(String v)  { createdAt = v; }

    public String getUpdatedAt()          { return updatedAt; }
    public void   setUpdatedAt(String v)  { updatedAt = v; }

    public String getAuthorName()          { return authorName; }
    public void   setAuthorName(String v)  { authorName = v; }

    public String getAuthorPic()          { return authorPic; }
    public void   setAuthorPic(String v)  { authorPic = v; }

    public int  getReplyCount()       { return replyCount; }
    public void setReplyCount(int v)  { replyCount = v; }

    public boolean isReply() { return parentId != null; }
}
