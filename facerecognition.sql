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
SET time_zone = "+00:00";


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
DROP TABLE IF EXISTS student_course_relationship, student, course, lecture, tutorial;

-- # Create TABLE student
create table student (
	  uid int not null,
    student_name varchar(50) not null,
    email varchar(80) not null,
	  login_time datetime not null, -- latest login time
    exit_system_time datetime not null, -- to calculate amount of time spent on our application
    primary key(uid)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES student WRITE;
/*!40000 ALTER TABLE student DISABLE KEYS */;
INSERT INTO student VALUES (1, "JACK", "123@hku.hk", NOW(), NOW());
/*!40000 ALTER TABLE student ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO course VALUES (1, "database management", "2021-1", "this course teaches database management");
/*!40000 ALTER TABLE course ENABLE KEYS */;
UNLOCK TABLES;

-- # Create TABLE student_course_relationship
create table student_course_relationship ( -- many to many relationship
	  uid int not null,
    course_id varchar (20) not null,
    year_semester varchar (50) not null,
    primary key (uid, course_id, year_semester) ,
    foreign key (uid) references student (uid),
    foreign key (course_id,year_semester) references course (course_id, year_semester)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- # Create TABLE lecture
create table lecture (
	  lecture_id int not null,
    course_id varchar (20) not null,
    year_semester varchar (50) not null,
    
    lecture_date datetime not null, 
    lecture_zoomlink varchar(256) not null,
    lecture_address varchar(256) not null, -- face to face classroom address
    lecture_material_link varchar(256) not null,
    lecturer_name varchar(50) not null,
    lecturer_msg varchar(512) not null,
    primary key (lecture_id, course_id, year_semester),
    foreign key (course_id,year_semester) references course (course_id, year_semester)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- # Create TABLE tutorial
create table tutorial (
	  tutorial_id int not null,
    course_id varchar (20) not null,
    year_semester varchar (50) not null,
    
    tutorial_date datetime not null,
    tutorial_zoomlink varchar(256) not null,
    tutorial_address varchar(256) not null, -- face to face classroom address
    tutorial_material_link varchar(256) not null,
    tutor_name varchar(50) not null,
    tutor_msg varchar(512) not null,
    primary key (tutorial_id, course_id, year_semester),
    foreign key (course_id,year_semester) references course (course_id, year_semester)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
