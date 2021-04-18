# create database facerecognition;
Use facerecognition;

-- you have to delete the table as following order
DROP TABLE IF EXISTS selectCourse;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS login_history;
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS classroom;
DROP TABLE IF EXISTS student;

-- teacher table
create table teacher (
    teacher_id int not NULL primary key,
    name varchar(50) NOT NULL,
    login_time time NOT NULL,
    login_date date NOT NULL,
    email varchar(50) NOT NULL,
    sex set ('F', 'M') NOT NULL
) ENGINE=InnoDB default charset=latin1;

insert into teacher
values (1, 'Wang Wu', '07:55:20', '2021-04-11', 'wangwu@gmail.com','F');

create table classroom(
	classroom_id int not NULL primary key,
	address varchar(100)
);

insert into classroom values(1, 'KB223');

-- course table
create table course (
    course_id int not NULL PRIMARY KEY,
    teacher_id int not null,
    name varchar(100) NOT NULL,
    info varchar(512),
    zoomUrl varchar(256),
	classroom_id int not NULL,
    start_time time not NULL,
    start_weekday int not NULL, -- 0 for Monday, 1 for Tuesday
	constraint fk_teacherId FOREIGN KEY(teacher_id) REFERENCES teacher(teacher_id),
	constraint fk_classroomId FOREIGN KEY(classroom_id) REFERENCES classroom(classroom_id)
) ENGINE=InnoDB DEFAULT charset=latin1;

insert into course
values (1, 1, 'MySQL', ' Database Management Systems', 'https://www.cs.hku.hk/index.php/programmes/course-offered?infile=2019/comp3278.html', 1, '20:30:00', 5);
insert into course
values (2, 1, 'Java', 'OOP and Java', 'https://www.cs.hku.hk/index.php/programmes/course-offered?infile=2019/comp2396.html', 1, '15:00:00', 6);

-- student table
CREATE TABLE student (
  student_id int NOT NULL primary key,
  name varchar(50) NOT NULL,
  login_time time NOT NULL,
  login_date date NOT NULL,
  email varchar(50) NOT NULL,
  sex set('F', 'M') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO student VALUES (1, "JACK", NOW(), '2021-01-20', 'jack@gmail.com','M');

create table selectCourse(
    course_id int not null,
    student_id int not null,
	constraint pk_sc PRIMARY KEY(course_id, student_id),
	constraint fk_sc_courseId FOREIGN KEY(course_id) REFERENCES course(course_id),
	constraint fk_sc_sid FOREIGN KEY(student_id) REFERENCES student(student_id)
);

insert into selectCourse values (1, 1);
insert into selectCourse values (2, 1);

create table login_history(
    student_id int,
    login_time datetime,
	constraint fk_sid FOREIGN KEY(student_id) REFERENCES student(student_id)
);

