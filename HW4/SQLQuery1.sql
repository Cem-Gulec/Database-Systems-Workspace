-- age computed column
ALTER TABLE dbo.STAFF ADD age AS DATEDIFF(YY, birthDate, GETDATE())

-- part 1: problem b
alter table dbo.STUDENT add constraint df_city default 'İstanbul' for city
alter table dbo.STUDENT add constraint df_postalCode default '34722' for postalCode

-- part 2: queries
-- a)
SELECT s.fName, s.lName, s.birthDate, s.city
FROM STUDENT s

-- b)
SELECT stu.fName as StudentFName, stu.lName as StudentLName, d.dName, stf.fName as AdvisorFName, stf.lName as AdvisorLName
FROM STUDENT stu inner join DEPARTMENT d on stu.deptCode=d.deptCode
     inner join STAFF stf on d.deptCode=stf.deptCode
ORDER BY dName ASC, StudentFName


-- c)
SELECT Distinct stu.fName, stu.lName
FROM STUDENT stu inner join DEPARTMENT d on stu.deptCode=d.deptCode
WHERE d.dName = 'Computer Engineering'

-- d)
SELECT *
FROM STUDENT stu
WHERE stu.fName like '%at%'

-- e)
SELECT stf.staffID, stf.fName, stf.lName
FROM STAFF stf
WHERE stf.isMarried = 'True' and stf.age > 40 and stf.noOfChildren >= 2
ORDER BY stf.birthDate

-- f)
SELECT stu.studentID, stu.fName, stu.lName, d.dName, dip.dateOfGraduation
FROM STUDENT stu inner join DEPARTMENT d on stu.deptCode=d.deptCode
     inner join DIPLOMA dip on stu.studentID=dip.studentID
WHERE dateOfGraduation > '2010-05-21'