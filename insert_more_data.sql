USE studygroup_db;

INSERT INTO users (full_name, email, password, university, major, academic_year, role) VALUES
('Eve Davis',    'eve@student.com',     'password', 'State University', 'Information Systems',  'Year 2', 'student'),
('Frank Miller', 'frank@student.com',   'password', 'State University', 'Computer Science',     'Year 3', 'student'),
('Grace Wilson', 'grace@student.com',   'password', 'State University', 'Software Engineering', 'Year 1', 'student'),
('Henry Moore',  'henry@student.com',   'password', 'State University', 'Computer Science',     'Year 4', 'student'),
('Ivy Taylor',   'ivy@student.com',     'password', 'State University', 'Information Systems',  'Year 2', 'student');

INSERT INTO study_groups (group_name, subject, course_code, description, meeting_type, capacity, creator_id) VALUES
('Mobile App Devs',      'Mobile App Development',  'CSE3040', 'Learning Flutter and Dart to build awesome mobile apps.', 'Hybrid',   10, 6),
('Cloud Computing Group','Cloud Architecture',      'CSE4020', 'Preparing for AWS Solutions Architect certification.',    'Online',   15, 7),
('UI/UX Designers',      'Human Computer Interaction','CSE3050', 'Figma prototyping and user interface design principles.', 'Physical', 8,  8),
('CyberSec Enthusiasts', 'Cybersecurity',           'CSE4030', 'Practicing CTF challenges and ethical hacking.',          'Online',   12, 9),
('Game Dev Guild',       'Game Development',        'CSE3060', 'Unity and C# game jam prep and project showcase.',        'Hybrid',   10, 10);

INSERT INTO memberships (user_id, group_id, status) VALUES
(6, 6, 'active'), (7, 6, 'active'),
(7, 7, 'active'), (8, 7, 'active'), (9, 7, 'active'),
(8, 8, 'active'), (10, 8, 'active'),
(9, 9, 'active'), (6, 9, 'active'),
(10, 10, 'active'), (6, 10, 'active'), (8, 10, 'active');
