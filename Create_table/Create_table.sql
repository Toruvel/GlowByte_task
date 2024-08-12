CREATE TABLE T (
  Name VARCHAR,
  Mark INT,
  Date DATE,
  Subject VARCHAR );


insert into T (Name, Mark, Date, Subject)
VALUES
    ("Иванов", 5, "01.01.2020", "алгебра"),
    ("Иванов", 5, "02.01.2020", "изо"),
    ("Иванов", 4, "03.01.2020", "изо"),
    ("Иванов", 2, "04.01.2020", "музыка"),
    ("Петров", 2, "05.01.2020", "алгебра"),
    ("Петров", 2, "06.01.2020", "алгебра"),
    ("Петров", 3, "07.01.2020", "музыка"),
    ("Петров", 2, "08.01.2020", "изо"),
    ("Сидоров", 5, "05.01.2020", "алгебра"),
    ("Сидоров", 4, "06.01.2020", "изо"),
    ("Сидоров", 5, "07.01.2020", "алгебра"),
    ("Сидоров", 3, "08.01.2020", "музыка")
-- Задание 1
SELECT Name, SUM(CASE WHEN Mark = 2 THEN 1 ELSE 0 END) as Two
FROM T
WHERE Name IN (SELECT Name FROM T WHERE Mark  = 5 GROUP BY Name HAVING COUNT(Mark) >= 10)
GROUP BY Name
ORDER BY Name;

-- Задание 2

SELECT  Name, Subject, COUNT(Mark) AS GradeCount
FROM T
GROUP BY Name, Subject
ORDER BY Name, Subject;
