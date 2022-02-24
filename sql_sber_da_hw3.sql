--����� ��: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task13 (lesson3)
--������������ �����: ������� ������ ���� ��������� � ������������� 
--� ��������� ���� �������� (pc, printer, laptop). 
--�������: model, maker, type

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
--������������ �����: ��� ������ ���� �������� �� ������� printer 
--������������� ������� ��� ���, � ���� ���� ����� ������� PC - "1", 
--� ��������� - "0"
select 
*,
case when price>(select avg(price) from printer) then 1 else 0 end as flag 
from printer;


--task15 (lesson3)
--�������: ������� ������ ��������, 
--� ������� class ����������� (IS NULL)
select 
* 
from ships
where class is null



--task16 (lesson3)
--�������: ������� ��������, ������� ��������� � ����, 
--�� ����������� �� � ����� �� ����� ������ �������� �� ����.

select * from battles
where extract(year from date) not in (select launched from ships);

select
battles.*
from battles
left join ships
on extract(year from battles.date)=ships.launched
where ships.launched is null


--task17 (lesson3)
--�������: ������� ��������, � ������� ����������� 
--������� ������ Kongo �� ������� Ships.
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
-- ������������ �����: ������� view (�������� all_products_flag_300) 
--��� ���� ������� (pc, printer, laptop) � ������, 
--���� ��������� ������ > 300. 
--�� view ��� �������: model, price, flag
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
-- ������������ �����: ������� view (�������� all_products_flag_avg_price) 
--��� ���� ������� (pc, printer, laptop) � ������, 
--���� ��������� ������ c������ . 
--�� view ��� �������: model, price, flag

-- ���.1: ���� ��� ������� ���������� ��������������� ������� ���� �� ���� ���������
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
-- ������������ �����: ������� ��� �������� ������������� = 'A' 
--�� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'. 
--������� model
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
-- ������������ �����: ������� ��� ������ ������������� = 'A' 
--�� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'. 
--������� model
								
--�������1: ������� ��������� ��� ������� �� ���� ���������, 
--������� ������� �������������� 'D' ��� 'C'
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
							where type='Printer' and maker in ('D','�')
							)
--�������2:������� ��������� �������� �� ������������� 'D' � �� ������������� 'C',
-- � ����� ���� ������������ � ������� �� ���
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
									where type='Printer' and maker in ('D','�')
									group by 1) a
								)						
							
--============
-- ���� ��� ������� �������� ��������� �������� null (� ������ ��������) ��� ��� null (�� ������), �� ������ ������ null - ��� ������� where ��� ������� ���� �� ������ ���������� ����������� ��������� null ����� ��������� �������������
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
-- ������������ �����: ����� ������� ���� ����� ���������� ��������� 
-- ������������� = 'A' (printer & laptop & pc)
-- ������ ��������� (pc,laptop,priner) ����������� ������ � ����������� ������, �� ������� ������� ���������������� (speed, screen, ram, color � ����.)
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
-- ������������ �����: ������� view � ����������� ������� 
--(�������� count_products_by_makers) �� ������� �������������. 
--�� view: maker, count

--�������1: ������ ��������� ������� ��� �������� � ��� ���� �� ������ �� ����������
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

--������� 2: ������ ��������� ������� ������ ��� �������� ���� (type), ������ (model) � ������������� (maker)
create or replace view count_products_by_makers as
select 
maker,
count(*)
from product
group by 1;
select * from count_products_by_makers



--task7 (lesson4)
-- �� ����������� view (count_products_by_makers) ������� ������ � colab (X: maker, y: count)

--��. notebook

--task8 (lesson4)
-- ������������ �����: ������� ����� ������� printer (�������� printer_updated) 
--� ������� �� ��� ��� �������� ������������� 'D'
create table printer_updated as table printer
delete from printer_updated 
where model in (select model from product where maker='D' and type='Printer')
select * from printer_updated
--task9 (lesson4)
-- ������������ �����: ������� �� ���� ������� (printer_updated) 
--view � �������������� �������� ������������� (�������� printer_updated_with_makers)

create or replace view printer_updated_with_makers as
select
a.*,
b.maker
from printer_updated a
left join product b 
on a.model=b.model;

select * from printer_updated_with_makers

--task10 (lesson4)
-- �������: ������� view c ����������� ����������� �������� 
--� ������� ������� (�������� sunk_ships_by_classes). 
--�� view: count, class (���� �������� ������ ���/IS NULL, �� �������� �� 0)
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
-- �������: �� ����������� view (sunk_ships_by_classes) ������� ������ � colab (X: class, Y: count)

--��. colab

--task12 (lesson4)
-- �������: ������� ����� ������� classes (�������� classes_with_flag) 
--� �������� � ��� flag: ���� ���������� ������ ������ ��� ����� 9 - �� 1, ����� 0
create table classes_with_flag as
select
*,
case when numguns>=9 then 1 else 0 end as flag 
from classes


--task13 (lesson4)
-- �������: ������� ������ � colab �� ������� classes 
--� ����������� ������� �� ������� (X: country, Y: count)
select 
country,
count(class)
from classes
group by 1


--task14 (lesson4)
-- �������: ������� ���������� ��������, � ������� �������� 
--���������� � ����� "O" ��� "M".
select count(*) from ships where name like 'O%' or name like 'M%'

--task15 (lesson4)
-- �������: ������� ���������� ��������, � ������� �������� ������� �� ���� ����.

select count(*) from ships where name like '% %'

--task16 (lesson4)
-- �������: ��������� ������ � ����������� ���������� 
--�� ���� �������� � ����� ������� (X: year, Y: count)
select 
launched,
count(name)
from ships
group by 1
order by 1
