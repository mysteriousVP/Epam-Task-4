CREATE DATABASE Company;

USE Company;

CREATE TABLE Employee
(
	Id INT NOT NULL PRIMARY KEY IDENTITY, 
    FirstName VARCHAR(30) NOT NULL DEFAULT 'def_name', 
    LastSurname VARCHAR(30) NOT NULL DEFAULT 'def_surname', 
    Phone VARCHAR(30) UNIQUE,
	Email VARCHAR(30) UNIQUE
);

CREATE TABLE Project
(
	Id INT NOT NULL PRIMARY KEY IDENTITY, 
	ProjectName VARCHAR(30) NOT NULL DEFAULT 'Project_Name', 
	CreationDate DATE NOT NULL DEFAULT GETDATE(),
	ProjectState VARCHAR(30) NOT NULL DEFAULT 'Not finished',
	ClosingDate DATE NULL
);

CREATE TABLE Position
(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	PositionName VARCHAR(40)
);

CREATE TABLE Employee_Project 
(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	EmployeeId INT,
	ProjectId INT,
	PositionId INT,
	FOREIGN KEY (EmployeeId) REFERENCES Employee(Id),
	FOREIGN KEY (ProjectId) REFERENCES Project(Id),
	FOREIGN KEY (PositionId) REFERENCES Position(Id),
);

CREATE TABLE Task
(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	EmployeeProjectId INT,
	TaskState VARCHAR(35) NOT NULL,
	DateOfState DATE NOT NULL DEFAULT GETDATE(),
	Deadline DATE NULL
	FOREIGN KEY (EmployeeProjectId) REFERENCES Employee_Project(Id)
);

INSERT INTO Employee VALUES('Mykhail', 'Vasilev', '0505041941', 'hello@ukr.net');
INSERT INTO Employee VALUES('Igor', 'Budka', '0505051255', 'hello1@ukr.net');
INSERT INTO Employee VALUES('Mira', 'Lomaka', '0505047321', 'hello2@ukr.net');
INSERT INTO Employee VALUES('Vladislav', 'Korobka', '0505725341', 'hello3@ukr.net');
INSERT INTO Employee VALUES('Ludmila', 'Vorobey', '0506341941', 'hello4@ukr.net');

INSERT INTO Project(ProjectName) VALUES('Professional Task');
INSERT INTO Project(ProjectName, CreationDate) VALUES('Professional Task 2', CAST(22/07/2000 AS DATE));
INSERT INTO Project(ProjectName) VALUES('Professional Task 3');
INSERT INTO Project(ProjectName) VALUES('Professional Task 4');
INSERT INTO Project(ProjectName) VALUES('Professional Task 5');

INSERT INTO Position VALUES('DBA');
INSERT INTO Position VALUES('.NET developer');
INSERT INTO Position VALUES('Front End dev');
INSERT INTO Position VALUES('PM');
INSERT INTO Position VALUES('Team leader');

INSERT INTO Employee_Project VALUES(1, 2, 2);
INSERT INTO Employee_Project VALUES(2, 2, 2);
INSERT INTO Employee_Project VALUES(3, 3, 1);
INSERT INTO Employee_Project VALUES(3, 1, 1);
INSERT INTO Employee_Project VALUES(4, 2, 2);
INSERT INTO Employee_Project VALUES(5, 3, 3);
INSERT INTO Employee_Project VALUES(5, 4, 3);

INSERT INTO Task(EmployeeProjectId, TaskState, Deadline) VALUES(1, 'Not finished', CAST(22/07/2015 AS DATE));
INSERT INTO Task(EmployeeProjectId, TaskState, Deadline) VALUES(2, 'Not finished', CAST(21/10/2007 AS DATE));
INSERT INTO Task(EmployeeProjectId, TaskState, Deadline) VALUES(3, 'Not finished', CAST(22/12/2012 AS DATE));
INSERT INTO Task(EmployeeProjectId, TaskState, Deadline) VALUES(4, 'Not finished', CAST(12/05/2013 AS DATE));
INSERT INTO Task(EmployeeProjectId, TaskState, Deadline) VALUES(5, 'Not finished', CAST(21/10/2010 AS DATE));
INSERT INTO Task(EmployeeProjectId, TaskState, Deadline) VALUES(6, 'Not finished', CAST(22/12/2019 AS DATE));
INSERT INTO Task(EmployeeProjectId, TaskState, Deadline) VALUES(7, 'Not finished', CAST(12/05/2020 AS DATE));
