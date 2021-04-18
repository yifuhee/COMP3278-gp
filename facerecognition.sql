-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 17, 2020 at 09:41 PM
-- Server version: 5.7.28-0ubuntu0.18.04.4
-- PHP Version: 7.2.24-0ubuntu0.18.04.1

use facerecognition;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = '+8:00';


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `facerecognition`
--

-- --------------------------------------------------------

--
-- Tables
--
DROP TABLE IF EXISTS student_course_relationship, student, course, lecture, tutorial, teacher, teacher_course_relationship, login_history;

-- # Create TABLE student
create table student (
    uid int not null,
    name varchar(50) not null,
    email varchar(80) not null,
    login_date date not null,
    login_time time not null,
    primary key(uid)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO student VALUES (1, "JACK", "123@hku.hk", NOW(), NOW());
INSERT INTO student VALUES (2, "JAMES", "456@hku.hk", NOW(), NOW());

-- # Create TABLE course
create table course (
    course_id varchar (20) not null,
    course_name varchar (80) not null,
    year_semester varchar (50) not null,
    course_info varchar (512) not null,
    primary key (course_id, year_semester)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES course WRITE;
/*!40000 ALTER TABLE course DISABLE KEYS */;
INSERT INTO course VALUES ("COMP3278", "database management", "2021-1", "this course teaches database management");
/*!40000 ALTER TABLE course ENABLE KEYS */;
UNLOCK TABLES;

-- # Create TABLE teacher			    
			    
-- # Create TABLE student_course_relationship
create table student_course_relationship ( -- many to many relationship
    uid int not null,
    course_id varchar (20) not null,
    year_semester varchar (50) not null,
    primary key (uid, course_id, year_semester) ,
    foreign key (uid) references student (uid),
    foreign key (course_id,year_semester) references course (course_id, year_semester)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

insert into student_course_relationship values (1, "COMP3278", "2021-1");
insert into student_course_relationship values (2, "COMP3278", "2021-1");

-- # Create TABLE teacher
create table teacher (
    teacher_id int not NULL primary key,
    name varchar(50) NOT NULL,
    login_time time NOT NULL,
    login_date date NOT NULL,
    email varchar(50) NOT NULL,
    sex set ('F', 'M') NOT NULL
) ENGINE=InnoDB default charset=latin1;

insert into teacher values (1, 'Wang Wu', '07:55:20', '2021-04-11', 'wangwu@gmail.com','F');

-- # Create TABLE teacher_course_relationship
create table teacher_course_relationship(
	teacher_id int not null,
	course_id varchar (20) not null,
	year_semester varchar (50) not null,
	primary key (teacher_id, course_id, year_semester),
	foreign key (teacher_id) references teacher (teacher_id),
	foreign key (course_id,year_semester) references course (course_id, year_semester)
) ENGINE=InnoDB default charset=latin1;

insert into teacher_course_relationship values (1,"COMP3278","2021-1");

-- # Create TABLE lecture
create table lecture (
    lecture_id varchar (20) not null,
    course_id varchar (20) not null,
    year_semester varchar (50) not null,
    
    lecture_date date not null,
	lecture_start_time time not null,
    lecture_zoomlink varchar(256) not null,
    lecture_address varchar(256) not null, -- face to face classroom address
    lecture_material_link varchar(256) not null,
    lecturer_name varchar(50) not null,
    lecturer_msg varchar(512) not null,
    primary key (lecture_id, course_id, year_semester),
    foreign key (course_id,year_semester) references course (course_id, year_semester)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

insert into lecture values ("Lecture 1", "COMP3278", "2021-1", "2021-04-18", "22:00:00", "zoomlink", "lecture_address", "lecture_material_link", "Wang Wu", "lecturer_msg");

-- # Create TABLE tutorial
create table tutorial (
    tutorial_id varchar (20) not null,
    course_id varchar (20) not null,
    year_semester varchar (50) not null,
    
    tutorial_date date not null,
	tutorial_start_time time not null,
    tutorial_zoomlink varchar(256) not null,
    tutorial_address varchar(256) not null, -- face to face classroom address
    tutorial_material_link varchar(256) not null,
    tutor_name varchar(50) not null,
    tutor_msg varchar(512) not null,
    primary key (tutorial_id, course_id, year_semester),
    foreign key (course_id,year_semester) references course (course_id, year_semester)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

insert into tutorial values ("Tutorial 1", "COMP3278", "2021-1", "2021-04-18", "23:00:00", "zoomlink", "tutorial_address", "tutorial_material_link", "tutor_name", "tutor_msg");

-- # Create TABLE login_history
create table login_history(
    uid int,
    login_time datetime,
    FOREIGN KEY(uid) REFERENCES student(uid)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------

-- insert your data here

LOCK TABLES student WRITE;
/*!40000 ALTER TABLE student DISABLE KEYS */;

-- INSERT INTO student VALUES (1, "JACK", "123@hku.hk", NOW(), NOW());
-- INSERT INTO student VALUES (2, "JAMES", "456@hku.hk", NOW(), NOW());
-- insert here

/*!40000 ALTER TABLE student ENABLE KEYS */;
UNLOCK TABLES;

-- ---------------------------------------------------------------------------

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
