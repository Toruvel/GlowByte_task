CREATE TABLE T (
  Name VARCHAR,
  Mark INT,
  Date DATE,
  Subject VARCHAR );

-- Вопрос 1
INSERT INTO T (Name, Mark, Date, Subject)
VALUES
    ('Иванов', 5, '01.01.2020', 'алгебра'),
    ('Иванов', 5, '02.01.2020', 'изо'),
    ('Иванов', 4, '03.01.2020', 'изо'),
    ('Иванов', 2, '04.01.2020', 'музыка'),
    ('Петров', 2, '05.01.2020', 'алгебра'),
    ('Петров', 2, '06.01.2020', 'алгебра'),
    ('Петров', 3, '07.01.2020', 'музыка'),
    ('Петров', 2, '08.01.2020', 'изо'),
    ('Сидоров', 5, '05.01.2020', 'алгебра'),
    ('Сидоров', 4, '06.01.2020', 'изо'),
    ('Сидоров', 5, '07.01.2020', 'алгебра'),
    ('Сидоров', 3, '08.01.2020', 'музыка');
-- Задание 1
SELECT 
  Name, 
  SUM(CASE WHEN Mark = 2 THEN 1 ELSE 0 END) as MarcСount
FROM T
WHERE Name IN (SELECT Name FROM T WHERE Mark  = 5 GROUP BY Name HAVING COUNT(Mark) >= 10)
GROUP BY Name
ORDER BY Name;

-- Задание 2

SELECT
  Name, 
  Subject, 
  COUNT(Mark) AS AllMarkCount
FROM  T
GROUP BY Name, Subject
ORDER BY Name, Subject;
-- Вопрос 2
CREATE TABLE Op (
  CUSTOMER_RK INT,
  OPERATION_DTTM DATETIME,
  OPERATION_TYPE_CD VARCHAR );

insert into Op (CUSTOMER_RK, OPERATION_DTTM, OPERATION_TYPE_CD)
VALUES
(2001, '2019-12-31 12:12:01', 'Оплата штрафов'),
(2001, '2020-01-10 20:48:58', NULL),
(2001, '2020-01-13 09:14:05', 'Покупка товаров и услуг'),
(2001, '2020-01-20 17:43:51', 'Оплата мобильного'),
(2001, '2020-01-29 01:26:45', 'Оплата мобильного'),
(2001, '2020-01-31 12:02:31', 'Покупка товаров и услуг'),
(2001, '2020-02-09 05:32:52', 'Покупка товаров и услуг'),
(2001, '2020-02-13 08:37:38', 'Переводы между своими счетами'),
(2001, '2020-02-15 14:39:56', 'Покупка товаров и услуг'),
(2001, '2020-02-24 12:42:16', 'Оплата мобильного'),
(2001, '2020-03-02 16:59:59', 'Оплата штрафов');

-- Задача 1
SELECT 
    CUSTOMER_RK,
    MIN(OPERATION_DTTM) OVER (PARTITION BY CUSTOMER_RK) AS FirstDate,
    MAX(OPERATION_DTTM) OVER (PARTITION BY CUSTOMER_RK) AS LastDate,
    FIRST_VALUE(OPERATION_TYPE_CD) OVER (PARTITION BY CUSTOMER_RK ORDER BY OPERATION_DTTM ASC) AS FirstType,
    FIRST_VALUE(OPERATION_TYPE_CD) OVER (PARTITION BY CUSTOMER_RK ORDER BY OPERATION_DTTM DESC) AS LastType
FROM Op
ORDER BY CUSTOMER_RK;


-- Задача 2

SELECT 
    CUSTOMER_RK,
    OPERATION_DTTM,
    OPERATION_TYPE_CD,
    DATEDIFF(DAY, 
             MAX(CASE WHEN OPERATION_TYPE_CD = 'Оплата мобильного' THEN OPERATION_DTTM END) 
             OVER (PARTITION BY CUSTOMER_RK ORDER BY OPERATION_DTTM),
             OPERATION_DTTM) AS Days_Since_Last_Mobile_Payment
FROM  Op
ORDER BY  CUSTOMER_RK, OPERATION_DTTM;


-- Вопрос 3


CREATE TABLE DayBalance (
  Name VARCHAR,
  Balance INT,
  Date DATE );

INSERT INTO DayBalance (Name, Balance, Date)
VALUES
('Иванов Иван Иванович', 1000, '2021-01-01'),
('Иванов Иван Иванович', 1000, '2021-01-02'),
('Иванов Иван Иванович', 800, '2021-01-03'),
('Иванов Иван Иванович', 700, '2021-01-04'),
('Иванов Иван Иванович', 700, '2021-01-05'),
('Степанов Степан Степанович', 2000, '2021-01-01'),
('Степанов Степан Степанович', 3000, '2021-01-02'),
('Степанов Степан Степанович', 3000, '2021-01-03'),
('Степанов Степан Степанович', 2000, '2021-01-04'),
('Степанов Степан Степанович', 3000, '2021-01-05'),
('Еленина Елена Еленовна', 1500, '2021-01-01'),
('Еленина Елена Еленовна', 1500, '2021-01-02'),
('Еленина Елена Еленовна', 1500, '2021-01-03'),
('Еленина Елена Еленовна', 1500, '2021-01-04'),
('Еленина Елена Еленовна', 1500, '2021-01-05');

WITH Ranked AS (
    SELECT Name, Balance, Date,
        ROW_NUMBER() OVER (PARTITION BY Name ORDER BY Date) - ROW_NUMBER() OVER (PARTITION BY Name, Balance ORDER BY Date) AS GroupIndex
    FROM DayBalance
),
Grouped AS (
    SELECT 
        Name,
        Balance,
        MIN(date) AS StartDate,
        MAX(date) AS EndDate
    FROM Ranked
    GROUP BY 
        Name, Balance, GroupIndex
)
SELECT 
    Name,
    Balance,
    Startdate,
    CASE WHEN DATE_ADD(EndDate, INTERVAL 1 DAY) = LEAD(StartDate) OVER (PARTITION BY Name ORDER BY StartDate) THEN DATE_ADD(EndDate, INTERVAL 1 DAY) ELSE NULL END AS EndDate
FROM Grouped
ORDER BY Name, StartDate;


/*

1)	В чем преимущества/недостатки хранения и использования данных в таком формате?
В таблице хранятся данные о состояния баланса за каждый день для каждого пользователя. 
Преимущества такого подохода: 
 - простота работы с таблицей - что бы получить данные о балансе определенного человека за определенный день достаточно написать запроса простой запрос, 
 без использования группировок или сложных условий отбора записей, например вот такой:
  
 select Balance from DayBalance where Name = 'Иванов Иван Иванович' and Date = '2021-01-02'
 
 Недостатки такого подхода:
 - происходит дублирование данных, как следствие - в пустую расходуется дисковое пространство. Например, у пользователя Еленина Елена Еленовна баланс не менялся на протяжении 5 дней, 
 но при этом каждый день создавалась новая запись с информацией о текущем балансе.


2)	Есть ли альтернативные варианты хранения той же информации? Если есть, то какие? Какие у них преимущества/недостатки?

Есть несколько вариантов альтернативного хранения информации о балансах:
1. Методика SCD1 - позволяет сохранять только текущие данные о балансе для пользователей, 
перезаписывая значения полей и не сохраняя историю изменений баланса. В этом случае для кажодого пользователя в таблице будет только одна запись, 
значения полей Balance и Date будет перезаписываться при изменении баланса актуальными данными. Возможно, от поля Date можно будет отказаться. 
Преимущества такого подхода: 
 - МАКСИМАЛЬНАЯ простота работы с таблицей. Проще не бывает.
 - минимум занимаемого дискового пространства
 
Недостатки такого подхода:
 - Не сохраняется история изменения данных о балансе. 
 
2. Методика SCD2 - позволяет сохранять только изменения баланса для пользователей. Данный подход подразумевает использование двух полей с датами - DateStart и DateEnd,
значения в которых определяют временной интервал, в котором конкретная запись была актуальной. Для актуальной записи на данный момент значение поле DateEnd будет не установлено (null), 
при изменении баланса будет заполняться поле DateEnd текущей датой и создаваться новая запись, в которой DateStart будет заполнено текущей датой, в поле Balance указано 
актулальное значение баланса пользователя и поле DateEnd будет оставаться пустым. Запись, в которой поле DateEnd пустое - можно считать актуальной.

Преимущества такого подхода: 
 - хранение ТОЛЬКО необходимой информации для возможности восстановить историю баланса 

Недостатки такого подхода:
 - некоторая сложность при работе с таблицей - например, при изменении баланса требуется выполнять два запроса 
 (update для изменения предыдущей записи и insert для вставки новой записи)

В целом, SCD2 является наиболее оптимальным методом хранения подобных данных, так как являет собой компромисс между занимаемым дисковым пространством и простотой работы с таблицей.



3)	Возможно ли с помощью SQL-запроса преобразовать данную таблицу к виду SCD2? Если да, то как 
(задачу необходимо решить одним запросом, приведя данные на выходе к виду SCD2, не добавляя данные руками с помощью команды INSERT INTO)?

Как уже было описано выше, "классический" SCD2 подразумевает использование двух полей для хранения дат, определяющих временной интервал актуальности записи. 
В нашей таблице поле для даты только одно, условие про один запрос подарузумевает, что дополнять таблицу новыми полями не получится. 
Поэтому напишем запрос на выборку данных, который будет формировать ответ в виде SCD2: */


