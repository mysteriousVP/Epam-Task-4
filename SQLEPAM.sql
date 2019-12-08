/*CREATE DATABASE Company;

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
*/
--1 Получить список всех должностей компании с количеством сотрудников на каждой из них
SELECT Position.PositionName, COUNT(Employee_Project.Id) AS 'Employees' FROM Position
LEFT JOIN Employee_Project
ON Position.Id = Employee_Project.PositionId
GROUP BY(Position.PositionName); 

--2 Определить список должностей компании, на которых нет сотрудников
SELECT Position.PositionName FROM Position 
LEFT JOIN Employee_Project 
ON Position.Id = Employee_Project.PositionId
WHERE Employee_Project.Id IS NULL;

--3 Получить список проектов с указанием, сколько сотрудников каждой должности работает на проекте
SELECT Project.ProjectName, Position.PositionName, COUNT(Employee_Project.PositionId) AS 'Employeers'
FROM Employee_Project
RIGHT JOIN Position
ON Position.Id = Employee_Project.PositionId
JOIN Project
ON Employee_Project.ProjectId = Project.Id
GROUP BY Project.ProjectName, Position.PositionName
ORDER BY Project.ProjectName;

--4 Посчитать на каждом проекте, какое в среднем количество задач приходится на каждого сотрудника
SELECT ProjectName, AVG(quantyty) as AVG FROM
	(SELECT Project.ProjectName as ProjectName, COUNT(Task.Id) as quantyty FROM Employee_Project 
	JOIN Project
	ON Project.Id = Employee_Project.ProjectId
	JOIN Employee 
	ON Employee.Id = Employee_Project.EmployeeId
	JOIN Task 
	ON Task.EmployeeProjectId = Employee_Project.Id 
	GROUP BY Project.ProjectName
	) as MaxUnitPrice
GROUP BY ProjectName;

--5 Подсчитать длительность выполнения каждого проекта
SELECT Project.ProjectName, DATEDIFF(d, Project.CreationDate, Project.ClosingDate) FROM Project
WHERE Project.ClosingDate IS NOT NULL;

--6 Определить сотрудников с минимальным количеством незакрытых задач
SELECT Employee.FirstName, Employee.LastSurname, COUNT(Task.Id) as Amount FROM Employee_Project
JOIN Employee
ON Employee.Id = Employee_Project.EmployeeId
JOIN Task
On Task.EmployeeProjectId = Employee_Project.Id
WHERE Task.TaskState != 'finished'
GROUP BY Employee.FirstName, Employee.LastSurname
ORDER BY Amount;

--7 Определить сотрудников с максимальным количеством незакрытых задач, дедлайн которых уже истек
SELECT Employee.FirstName, Employee.LastSurname, COUNT(Task.Id) as Amount FROM Employee_Project
JOIN Employee
ON Employee.Id = Employee_Project.EmployeeId
JOIN Task
On Task.EmployeeProjectId = Employee_Project.Id
WHERE Task.TaskState != 'finished' AND CAST(GETDATE() AS DATE) > Task.Deadline
GROUP BY Employee.FirstName, Employee.LastSurname
ORDER BY Amount DESC;

--8 Продлить дедлайн незакрытых задач на 5 дней
UPDATE Task 
SET Task.Deadline = DATEADD(d, 5, Task.Deadline)
WHERE Task.TaskState != 'finished';

--9 Посчитать на каждом проекте количество задач, к которым еще не приступили
SELECT Project.ProjectName, COUNT(Task.Id) AS OpenTasks FROM Employee_Project
RIGHT JOIN Project
ON Project.Id = Employee_Project.ProjectId 
JOIN Task
ON Task.EmployeeProjectId = Employee_Project.Id
WHERE Task.TaskState = 'Not yet'
GROUP BY Project.ProjectName;

--10 Перевести проекты в состояние закрыт, для которых все задачи закрыты и 
--задать время закрытия временем закрытия задачи проекта, принятой последней

DECLARE @ProjId int;
SET @ProjId = 1;
UPDATE Project
SET Project.ProjectState = 'Finished',@ProjId = Project.Id, Project.ClosingDate = 
	(SELECT TOP(1) Task.DateOfState FROM Employee_Project 
	JOIN Task
	ON Task.EmployeeProjectId = Employee_Project.Id
	WHERE Employee_Project.ProjectId = @ProjId
	ORDER BY Task.DateOfState DESC)
WHERE Project.Id NOT IN (SELECT Project.Id FROM Employee_Project 
	RIGHT JOIN Project 
	ON Project.Id = Employee_Project.ProjectId
	JOIN Task
	ON Task.EmployeeProjectId = Employee_Project.Id
	WHERE Task.TaskState != 'Finished'
	GROUP BY Project.Id);

--11 Выяснить по всем проектам, какие сотрудники на проекте не имеют незакрытых задач
DECLARE @ProjectsCount INT;
	SET @ProjectsCount = (SELECT COUNT(*) FROM Project);
DECLARE @Iterator INT = 1;

WHILE (@Iterator <= @ProjectsCount)
BEGIN
	SELECT Project.ProjectName, Employee.FirstName, Employee.LastSurname
	FROM Employee_Project 
	INNER JOIN Task 
	ON Task.EmployeeProjectId = Employee_Project.Id
	INNER JOIN Employee
	ON Employee.Id = Employee_Project.EmployeeId
	INNER JOIN Project
	ON Project.Id = Employee_Project.ProjectId
	WHERE (Task.TaskState = 'Finished') AND (Project.Id = @Iterator)
	SET @Iterator = @Iterator + 1;
END

--12 Заданную задачу (по названию) проекта перевести на сотрудника с минимальным количеством выполняемых им задач
UPDATE Task
SET Task.EmployeeProjectId = 
(
SELECT TOP(1) sub2.EmployeeProjectId FROM (
	SELECT sub1.EmployeeProjectId FROM
		(SELECT Task.EmployeeProjectId, COUNT(Task.TaskState) AS 'OpenTasks'
		FROM Task 
		INNER JOIN Employee_Project
		ON Employee_Project.Id = Task.EmployeeProjectId
		INNER JOIN Employee
		ON Employee.Id = Employee_Project.EmployeeId
		GROUP BY Task.EmployeeProjectId, Task.TaskState
		HAVING Task.TaskState != 'Finished')sub1

	WHERE sub1.OpenTasks = 
	(
		SELECT MIN(sub1.OpenTasks) FROM
		(SELECT Task.EmployeeProjectId, COUNT(Task.TaskState) AS 'OpenTasks'
		FROM Task 
		INNER JOIN Employee_Project
		ON Employee_Project.Id = Task.EmployeeProjectId
		INNER JOIN Employee
		ON Employee.Id = Employee_Project.EmployeeId
		GROUP BY Task.EmployeeProjectId, Task.TaskState
		HAVING Task.TaskState != 'Finished')sub1
	)) AS sub2
	ORDER BY sub2.EmployeeProjectId DESC
)
WHERE Task.Id = 20;
