-- ============================================================
-- Study Group Finder System — Database Schema
-- Course: Web Application Development (CSE3023)
-- Server: MySQL via XAMPP
-- Normalization: 3NF
-- ============================================================

CREATE DATABASE IF NOT EXISTS studygroup_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE studygroup_db;

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    user_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(120)  NOT NULL,
    email       VARCHAR(180)  NOT NULL UNIQUE,
    password    VARCHAR(255)  NOT NULL,
    university  VARCHAR(150)  DEFAULT NULL,
    major       VARCHAR(150)  DEFAULT NULL,
    academic_year ENUM('Year 1','Year 2','Year 3','Year 4','Postgraduate') DEFAULT NULL,
    profile_pic VARCHAR(255)  DEFAULT 'default.png',
    role        ENUM('student','admin') NOT NULL DEFAULT 'student',
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: study_groups
-- ============================================================
CREATE TABLE IF NOT EXISTS study_groups (
    group_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    group_name    VARCHAR(150) NOT NULL,
    subject       VARCHAR(150) NOT NULL,
    course_code   VARCHAR(30)  NOT NULL,
    description   TEXT         DEFAULT NULL,
    meeting_type  ENUM('Online','Physical','Hybrid') NOT NULL DEFAULT 'Online',
    capacity      TINYINT UNSIGNED NOT NULL DEFAULT 10,
    creator_id    INT UNSIGNED NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_group_creator FOREIGN KEY (creator_id)
        REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: memberships
-- ============================================================
CREATE TABLE IF NOT EXISTS memberships (
    membership_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       INT UNSIGNED NOT NULL,
    group_id      INT UNSIGNED NOT NULL,
    join_date     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status        ENUM('active','pending','left') NOT NULL DEFAULT 'active',
    UNIQUE KEY uq_user_group (user_id, group_id),
    CONSTRAINT fk_mem_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)  ON DELETE CASCADE,
    CONSTRAINT fk_mem_group FOREIGN KEY (group_id) REFERENCES study_groups(group_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: study_sessions
-- ============================================================
CREATE TABLE IF NOT EXISTS study_sessions (
    session_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    group_id      INT UNSIGNED NOT NULL,
    session_title VARCHAR(200) NOT NULL,
    session_date  DATE         NOT NULL,
    session_time  TIME         NOT NULL,
    duration_mins SMALLINT UNSIGNED NOT NULL DEFAULT 60,
    location      VARCHAR(255) DEFAULT NULL,
    meeting_link  VARCHAR(500) DEFAULT NULL,
    created_by    INT UNSIGNED NOT NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_sess_group   FOREIGN KEY (group_id)   REFERENCES study_groups(group_id) ON DELETE CASCADE,
    CONSTRAINT fk_sess_creator FOREIGN KEY (created_by) REFERENCES users(user_id)         ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: discussions
-- ============================================================
CREATE TABLE IF NOT EXISTS discussions (
    message_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    group_id    INT UNSIGNED NOT NULL,
    user_id     INT UNSIGNED NOT NULL,
    parent_id   INT UNSIGNED DEFAULT NULL,   -- NULL = top-level post, else reply
    content     TEXT         NOT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_disc_group  FOREIGN KEY (group_id)  REFERENCES study_groups(group_id) ON DELETE CASCADE,
    CONSTRAINT fk_disc_user   FOREIGN KEY (user_id)   REFERENCES users(user_id)         ON DELETE CASCADE,
    CONSTRAINT fk_disc_parent FOREIGN KEY (parent_id) REFERENCES discussions(message_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,
    message         VARCHAR(500) NOT NULL,
    link            VARCHAR(500) DEFAULT NULL,
    is_read         TINYINT(1)   NOT NULL DEFAULT 0,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: reviews
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    group_id    INT UNSIGNED NOT NULL,
    rating      TINYINT UNSIGNED NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT         DEFAULT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_review_user_group (user_id, group_id),
    CONSTRAINT fk_rev_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)         ON DELETE CASCADE,
    CONSTRAINT fk_rev_group FOREIGN KEY (group_id) REFERENCES study_groups(group_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Plain text passwords
-- All sample users login with password: password

INSERT INTO users (full_name, email, password, university, major, academic_year, role) VALUES
('Admin User',    'admin@studygroup.com',  'password', 'State University', 'Computer Science',     'Year 4', 'admin'),
('Alice Johnson', 'alice@student.com',    'password', 'State University', 'Computer Science',     'Year 2', 'student'),
('Bob Williams',  'bob@student.com',      'password', 'State University', 'Software Engineering', 'Year 3', 'student'),
('Carol Smith',   'carol@student.com',    'password', 'State University', 'Information Systems',  'Year 1', 'student'),
('David Lee',     'david@student.com',    'password', 'State University', 'Computer Science',     'Year 4', 'student');

INSERT INTO study_groups (group_name, subject, course_code, description, meeting_type, capacity, creator_id) VALUES
('CS Algorithm Crew',     'Data Structures & Algorithms', 'CSE2012', 'We solve LeetCode problems and prepare for technical interviews.', 'Online',   8,  2),
('Web Dev Warriors',      'Web Application Development',  'CSE3023', 'Building real-world full-stack projects together.', 'Hybrid',   10, 3),
('Database Explorers',    'Database Systems',             'CSE2021', 'Mastering SQL, normalization, and database design.', 'Physical', 6,  2),
('AI Study Circle',       'Artificial Intelligence',      'CSE4010', 'Discussing ML models, neural networks and AI ethics.', 'Online',   12, 4),
('Networks & Security',   'Computer Networks',            'CSE3031', 'Hands-on labs for networking protocols and cyber security.', 'Physical', 8,  5);

INSERT INTO memberships (user_id, group_id, status) VALUES
(2, 1, 'active'), (3, 1, 'active'), (4, 1, 'active'),
(3, 2, 'active'), (4, 2, 'active'), (5, 2, 'active'),
(2, 3, 'active'), (5, 3, 'active'),
(4, 4, 'active'), (5, 4, 'active'),
(5, 5, 'active'), (2, 5, 'active');

INSERT INTO study_sessions (group_id, session_title, session_date, session_time, duration_mins, location, meeting_link, created_by) VALUES
(1, 'Sorting Algorithms Deep Dive',     '2026-06-10', '14:00:00', 90,  NULL,            'https://meet.google.com/abc-def-ghi', 2),
(1, 'Graph Traversal Problems',         '2026-06-17', '14:00:00', 90,  NULL,            'https://meet.google.com/abc-def-ghi', 2),
(2, 'PHP MVC Project Kickoff',          '2026-06-08', '10:00:00', 120, NULL,            'https://zoom.us/j/1234567890',        3),
(3, 'ERD Design Workshop',              '2026-06-12', '15:00:00', 60,  'Library Room 3', NULL,                                 2),
(4, 'Intro to Neural Networks',         '2026-06-11', '16:00:00', 90,  NULL,            'https://teams.microsoft.com/l/xyz',   4),
(5, 'Wireshark Lab Session',            '2026-06-09', '09:00:00', 120, 'Lab 204',       NULL,                                  5);

INSERT INTO discussions (group_id, user_id, parent_id, content) VALUES
(1, 2, NULL,  'Welcome everyone! Let\'s start with Big O notation review.'),
(1, 3, 1,     'Great idea! I suggest we also cover space complexity.'),
(1, 4, 1,     'I found a great resource on Coursera for this topic.'),
(2, 3, NULL,  'What framework are we using for the frontend — Bootstrap or Tailwind?'),
(2, 4, 4,     'Let\'s stick with Bootstrap 5 since most of us know it already.'),
(3, 2, NULL,  'Don\'t forget to bring your ERD diagrams for review!'),
(4, 4, NULL,  'Has anyone read the new GPT-4 technical paper?'),
(5, 5, NULL,  'Lab equipment is booked for Tuesday. Please be on time.');

INSERT INTO notifications (user_id, message, link) VALUES
(2, 'New session scheduled: Sorting Algorithms Deep Dive', '?page=group_detail&id=1'),
(3, 'Bob Williams joined Web Dev Warriors', '?page=group_detail&id=2'),
(4, 'New post in AI Study Circle discussion board', '?page=group_detail&id=4'),
(5, 'Wireshark Lab Session has been scheduled', '?page=group_detail&id=5'),
(2, 'New post in CS Algorithm Crew discussion board', '?page=group_detail&id=1');

INSERT INTO reviews (user_id, group_id, rating, review_text) VALUES
(3, 1, 5, 'Amazing group! Alice keeps everything organized and we make great progress every session.'),
(4, 1, 4, 'Very helpful sessions. Sometimes we run over time but the content is excellent.'),
(4, 2, 5, 'Web Dev Warriors is the best study group I have joined. Very collaborative!'),
(5, 3, 4, 'Good group for database fundamentals. Would love more advanced topics.'),
(2, 5, 5, 'Lab sessions are very practical. David runs them very professionally.');
