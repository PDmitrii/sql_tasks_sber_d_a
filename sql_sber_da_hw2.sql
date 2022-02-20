--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing

--task1
--Корабли: Для каждого класса определите число кораблей этого класса, потопленных в сражениях. Вывести: класс и число потопленных кораблей.
select 
a.class,
sum(case when a.result = 'sunk' then 1 else 0 end) as cnt_sunk_ships
from
(select 
outcomes.ship,
case when ships.class is null then 'Unknown' else ships.class end as class,
outcomes.result
from outcomes
left join ships
on outcomes.ship=ships.name) a
group by 1
order by cnt_sunk_ships desc;


--task2
--Корабли: Для каждого класса определите год, когда был спущен на воду первый корабль этого класса. 
--Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду кораблей этого класса. Вывести: класс, год.
select 
class,
min(launched) as year
from ships
group by class;

select 
a.class,
case when min(a.synth_launched) is null then min(a.launched) else min(a.synth_launched) end as year
from
	(select 
	name,
	class,
	case when name=class then launched else null end as synth_launched,
	launched
	from ships
	) a
group by 1


--task3
--Корабли: Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, вывести имя класса и число потопленных кораблей.

select 
class,
sum(cnt_sunk_ships) as cnt_sunk_ships
from
(select 
class,
0 as cnt_sunk_ships
from ships
group by 1,2
having count(name)>=3

union all

select 
ships.class,
sum(case when outcomes.result='sunk' then 1 else 0 end) as cnt_sunk_ships
from ships
left join outcomes
on ships.name=outcomes.ship
group by 1) a
group by 1

--task4
--Корабли: Найдите названия кораблей, имеющих наибольшее число орудий среди всех кораблей такого же водоизмещения (учесть корабли из таблицы Outcomes).
with s as 	(
			select 
			name,
			class
			from ships
			union 
			select
			ship,
			null
			from outcomes
			)
select 
s.name
--s.class,
--classes.class,
--classes.numguns,
--classes.displacement 
from s
left join classes 
on s.class=classes.class
left join 
(select 
c.displacement as displacement,
max(c.numguns) as max_numguns
from s
left join ships s2 
on s.name=s2.name
left join classes c 
on s2.class = c.class
group by 1) a
on classes.numguns = a.max_numguns and classes.displacement = a.displacement
where s.class is not null


--task5
--Компьютерная фирма: Найдите производителей принтеров, 
--которые производят ПК с наименьшим объемом RAM и с самым быстрым процессором среди всех ПК, 
--имеющих наименьший объем RAM. 
--Вывести: Maker

with need_models_1 as 
					(
					select 
					distinct model
					from pc
					left join
								(
								select 
								max(speed) as max_speed,
								ram as min_ram
								from pc
								where ram=(select min(ram) from pc)
								group by ram
								) par
					on pc.speed=par.max_speed and pc.ram=par.min_ram
					where par.max_speed is not null and par.min_ram is not null
					)

select 
distinct pc_pr.maker
from 	(
		select 
		maker
		from product
		group by 1
		having max(case when type='PC' then 1 else 0 end) + max(case when type='Printer' then 1 else 0 end) =2
		) pc_pr
where pc_pr.maker in 	(
						select 
						maker 
						from product 
						where model in (
										select 
										model 
										from need_models_1
										)
						)


