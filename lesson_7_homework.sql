--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task1  (lesson7)
-- sqlite3: Сделать тестовый проект с БД (sqlite3, project name: task1_7). В таблицу table1 записать 1000 строк с случайными значениями (3 колонки, тип int) от 0 до 1000.
-- Далее построить гистаграмму распределения этих трех колонко
import pandas as pd
import numpy as np
import random as rnd
import matplotlib.pyplot as plt

import sqlite3
conn_sqlite=sqlite3.connect('task1_7')
c=conn_sqlite.cursor()

request="Create table random_int_3f(f1 int, f2 int, f3 int)"
c.execute(request)
tables=c.fetchall()

df_0=pd.DataFrame({'f1':np.random.randint(0,1000,1000),'f2':np.random.randint(0,1000,1000),'f3':np.random.randint(0,1000,1000)})
df_0.set_index('f1',inplace=True)

df_0.to_sql(name='random_int_3f',con=conn_sqlite,if_exists='append')

query_="select * from random_int_3f"
df_1=pd.read_sql(query_,con=conn_sqlite)

plt.figure(figsize=(15,5))
for i,col in enumerate(df_1.columns):
  plt.subplot(1,3,i+1)
  plt.title(col)
  df_1[col].hist(bins=10)



--task2  (lesson7)
-- oracle: https://leetcode.com/problems/duplicate-emails/

select
email
from
    (select
    email, count(*) as cnt
    from Person
    group by email)
where cnt>1

--task3  (lesson7)
-- oracle: https://leetcode.com/problems/employees-earning-more-than-their-managers/

select
	t1.name as Employee
from Employee t1
join Employee t2
on t1.managerId=t2.id and t1.salary>t2.salary

--task4  (lesson7)
-- oracle: https://leetcode.com/problems/rank-scores/

select
score,
dense_rank() over (order by score desc) as rank
from Scores
order by score desc

--task5  (lesson7)
-- oracle: https://leetcode.com/problems/combine-two-tables/

select
p.firstName,
p.lastName,
a.city,
a.state
from Person p
left join Address a
on p.personId=a.personId