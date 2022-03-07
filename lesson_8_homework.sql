--task1  (lesson8)
-- oracle: https://leetcode.com/problems/department-top-three-salaries/



--task2  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/17

SELECT 
f.member_name as member_name,
f.status as status,
sum(p.amount*p.unit_price) as costs
from FamilyMembers f
left join Payments p 
on f.member_id=p.family_member
where extract(year from p.date)=2005
group by 1,2

--task3  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/13

SELECT 
name
from passenger
group by 1
having count(*)>1

--task4  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

SELECT 
count(*) as count 
from Student
where first_name='Anna' 

--task5  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/35

SELECT 
count(distinct classroom) as count 
from Schedule
where date = '2019-09-02'

--task6  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

SELECT 
count(*) as count 
from Student
where first_name='Anna' 

--task7  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/32

SELECT 
floor(avg(timestampdiff(YEAR,birthday,now()))) as age
FROM FamilyMembers


--task8  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/27

SELECT 
t4.good_type_name,
sum(t3.amount*t3.unit_price) as costs
FROM Payments t3
LEFT JOIN 
(SELECT 
t1.good_id,
t2.good_type_name
from Goods t1
left join GoodTypes t2
on t1.type=t2.good_type_id) t4
on t3.good=t4.good_id
where year(t3.date)=2005
group by 1

--task9  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/37

SELECT 
min(timestampdiff(YEAR,birthday,now())) as year
FROM Student

--task10  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/44

SELECT 
max(TIMESTAMPDIFF(YEAR,birthday,now())) as max_year
from Student
WHERE id in (
            SELECT student
            FROM Student_in_class
            WHERE class in (
                            SELECT id 
                            FROM Class 
                            WHERE name like '10%'
                            )
            )

--task11 (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/20

SELECT 
t2.status,
t2.member_name,
(t1.amount*t1.unit_price) as costs
FROM Payments t1
left join FamilyMembers t2
on t1.family_member=t2.member_id
WHERE t1.good in    (
                    SELECT 
                    t3.good_id
                    FROM Goods t3
                    LEFT JOIN GoodTypes t4
                    on t3.type=t4.good_type_id
                    where t4.good_type_name='entertainment'
                    )

--task12  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/55

with comp_name as   (SELECT 
                    company,
                    count(*) as cnt
                    FROM Trip
                    GROUP BY 1)
SELECT 
id,
name
FROM Company
where id not in (
                SELECT 
                company
                from comp_name
                where cnt=(select min(cnt) from comp_name)
                )

--task13  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/45

SELECT 
b.classroom
FROM 
(SELECT 
a.classroom,
a.cnt,
dense_rank() over (order by a.cnt desc) as dr
FROM (SELECT 
      classroom,
      COUNT(*) as cnt
      FROM Schedule
      group by 1) a 
 ) b
WHERE b.dr=1

--task14  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/43

SELECT 
last_name
FROM Teacher
where id in (SELECT 
            Teacher
            FROM Schedule
            WHERE subject in (  select 
                                id 
                                from Subject
                                WHERE name = 'Physical Culture')
            )
order by last_name

--task15  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/63
так и не понял, почему неверно

SELECT 
concat(concat(upper(substring(last_name,1,1)),lower(substring(last_name,2))),'.',upper(SUBSTRING(first_name,1,1)),'.',upper(SUBSTRING(middle_name,1,1)),'.') as name
FROM Student
GROUP BY 1
order by 1