--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task13 (lesson3)
--Компьютерная фирма: Вывести список всех продуктов и производителя 
--с указанием типа продукта (pc, printer, laptop). 
--Вывести: model, maker, type

select 
model,
maker,
type
from product;

--select 
--pr.model,
--p.maker,
--pr.type
--from
--(select model,'PC' as type from pc
--union
--select model,'Printer' from printer
--union 
--select model,'Laptop' from laptop) pr
--left join product p
--on p.model=pr.model


--task14 (lesson3)
--Компьютерная фирма: При выводе всех значений из таблицы printer 
--дополнительно вывести для тех, у кого цена вышей средней PC - "1", 
--у остальных - "0"
select 
*,
case when price>(select avg(price) from printer) then 1 else 0 end as flag 
from printer;


--task15 (lesson3)
--Корабли: Вывести список кораблей, 
--у которых class отсутствует (IS NULL)
select 
* 
from ships
where class is null



--task16 (lesson3)
--Корабли: Укажите сражения, которые произошли в годы, 
--не совпадающие ни с одним из годов спуска кораблей на воду.

select * from battles
where extract(year from date) not in (select launched from ships);

select
battles.*
from battles
left join ships
on extract(year from battles.date)=ships.launched
where ships.launched is null


--task17 (lesson3)
--Корабли: Найдите сражения, в которых участвовали 
--корабли класса Kongo из таблицы Ships.
select 
battle
from outcomes
where ship in (select name from ships where class='Kongo');

select 
o.battle,
s.class 
from outcomes o
left join ships s
on o.ship=s.name
where s.class='Kongo';


--task1  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_300) 
--для всех товаров (pc, printer, laptop) с флагом, 
--если стоимость больше > 300. 
--Во view три колонки: model, price, flag
create or replace view all_products_flag_300 as
select 
distinct
ap.model,
case when ap.price>300 then 1 else 0 end as flag 
from 	(
		select model,price from pc
		union 
		select model,price from laptop
		union
		select model,price from printer
		) ap;
	
create or replace view all_products_flag_300 as
select 
ap.model,
ap.flag 
from 	(
		select model,case when price>300 then 1 else 0 end as flag from pc
		union 
		select model,case when price>300 then 1 else 0 end as flag from laptop
		union
		select model,case when price>300 then 1 else 0 end as flag from printer
		) ap;

select * from all_products_flag_300



--task2  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_avg_price) 
--для всех товаров (pc, printer, laptop) с флагом, 
--если стоимость больше cредней . 
--Во view три колонки: model, price, flag

-- Вар.1: если под средней стоимостью подразумевается средняя цена по всем продуктам
create or replace view all_products_flag_avg_price as 
with ap as 	(
			select model,price from pc
			union 
			select model,price from laptop
			union 
			select model,price from printer
			)

select 
model,
price,
case when price>(select avg(price) from ap) then 1 else 0 end as flag
from ap
		
		
--task3  (lesson4)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' 
--со стоимостью выше средней по принтерам производителя = 'D' и 'C'. 
--Вывести model
with pr_$ as 
			(select 
			p.model,
			p.price,
			prd.maker
			from printer p
			left join product prd
			on p.model=prd.model and prd.type='Printer')
select 
model
from pr_$ 
where maker='A' and price>	all	(select avg_price
								from 	(
										select 
										maker,
										avg(price) as avg_price
										from pr_$
										group by 1
										having maker in ('C','D')
										) a
								)		

--task4 (lesson4)
-- Компьютерная фирма: Вывести все товары производителя = 'A' 
--со стоимостью выше средней по принтерам производителя = 'D' и 'C'. 
--Вывести model
								
--Вариант1: среднее считается как среднее по всем принтерам, 
--которые сделаны производетелем 'D' или 'C'
with base as
			(
			select 
			t2.maker,
			t1.model,
			t1.price,
			t2.type
			from
				(select model,price,'PC' as type from pc
				union 
				select model,price,'Printer' from printer
				union 
				select model,price,'Laptop' from laptop) t1
				left join product t2
				on t1.model=t2.model and t1.type=t2.type
			)
select 
distinct
model 
from base 
where maker='A' and price> (select 
							avg(price) 
							from base 
							where type='Printer' and maker in ('D','С')
							)
--Вариант2:среднее считается отдельно по производителю 'D' и по производителю 'C',
-- а потом цена сравнивается с большим из них
with base as
			(
			select 
			t2.maker,
			t1.model,
			t1.price,
			t2.type
			from
				(select model,price,'PC' as type from pc
				union 
				select model,price,'Printer' from printer
				union 
				select model,price,'Laptop' from laptop) t1
				left join product t2
				on t1.model=t2.model and t1.type=t2.type
				)
select 
distinct
model 
from base 
where maker='A' and price> All (select 
								a.avg_price 
								from
									(select
									maker,
									avg(price) as avg_price 
									from base 
									where type='Printer' and maker in ('D','С')
									group by 1) a
								)						
							
--============
-- Если при расчете среднего возникает значение null (в первом варианте) или все null (во втором), то запрос вернет null - все условие where при наличии хотя бы одного результата логического выражения null будет считаться невыполненным
--select 
--*
--from
--(select 'D' as maker,300 as price 
--union 
--select 'C',null 
--union 
--select 'B',200) a
--where maker in ('D','C') and price>100
														
--============


--task5 (lesson4)
-- Компьютерная фирма: Какая средняя цена среди уникальных продуктов 
-- производителя = 'A' (printer & laptop & pc)
-- внутри категории (pc,laptop,priner) сохраняются записи с одинаковыми ценами, но разными прочими характеристиками (speed, screen, ram, color и проч.)
select 
avg(base.price)
from 	(
		select model,price from pc
		union all 
		select model,price from laptop
		union all
		select model,price from printer
		) base
left join product
on base.model=product.model
where product.maker='A'

								
								
--task6 (lesson4)
-- Компьютерная фирма: Сделать view с количеством товаров 
--(название count_products_by_makers) по каждому производителю. 
--Во view: maker, count

--Вариант1: товары считаются разными при различии у них хотя бы одного из параметров
create or replace view count_products_by_makers as
select
p.maker,
count(*)
from
(select model from pc
union all 
select model from laptop
union all 
select model from printer) a
left join product p 
on p.model=a.model
group by 1;
select * from count_products_by_makers

--Вариант 2: товары считаются разными только при различии типа (type), модели (model) и производителя (maker)
create or replace view count_products_by_makers as
select 
maker,
count(*)
from product
group by 1;
select * from count_products_by_makers



--task7 (lesson4)
-- По предыдущему view (count_products_by_makers) сделать график в colab (X: maker, y: count)

--см. notebook

--task8 (lesson4)
-- Компьютерная фирма: Сделать копию таблицы printer (название printer_updated) 
--и удалить из нее все принтеры производителя 'D'
create table printer_updated as table printer
delete from printer_updated 
where model in (select model from product where maker='D' and type='Printer')
select * from printer_updated
--task9 (lesson4)
-- Компьютерная фирма: Сделать на базе таблицы (printer_updated) 
--view с дополнительной колонкой производителя (название printer_updated_with_makers)

create or replace view printer_updated_with_makers as
select
a.*,
b.maker
from printer_updated a
left join product b 
on a.model=b.model;

select * from printer_updated_with_makers

--task10 (lesson4)
-- Корабли: Сделать view c количеством потопленных кораблей 
--и классом корабля (название sunk_ships_by_classes). 
--Во view: count, class (если значения класса нет/IS NULL, то заменить на 0)
create or replace view sunk_ships_by_classes as
select 
case when s.class is null then '0' else s.class end as class,
count(*)
from outcomes o 
left join ships s 
on o.ship=s.name
where result='sunk'
group by 1;

select * from sunk_ships_by_classes


--task11 (lesson4)
-- Корабли: По предыдущему view (sunk_ships_by_classes) сделать график в colab (X: class, Y: count)

--см. colab

--task12 (lesson4)
-- Корабли: Сделать копию таблицы classes (название classes_with_flag) 
--и добавить в нее flag: если количество орудий больше или равно 9 - то 1, иначе 0
create table classes_with_flag as
select
*,
case when numguns>=9 then 1 else 0 end as flag 
from classes


--task13 (lesson4)
-- Корабли: Сделать график в colab по таблице classes 
--с количеством классов по странам (X: country, Y: count)
select 
country,
count(class)
from classes
group by 1


--task14 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название 
--начинается с буквы "O" или "M".
select count(*) from ships where name like 'O%' or name like 'M%'

--task15 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название состоит из двух слов.

select count(*) from ships where name like '% %'

--task16 (lesson4)
-- Корабли: Построить график с количеством запущенных 
--на воду кораблей и годом запуска (X: year, Y: count)
select 
launched,
count(name)
from ships
group by 1
order by 1
