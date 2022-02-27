--����� ��: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task1 (lesson5)
-- ������������ �����: ������� view (pages_all_products), 
--� ������� ����� ������������ �������� ���� ��������� 
--(�� ����� ���� ��������� �� ����� ��������). 
--�����: ��� ������ �� laptop, ����� ��������, ������ ���� �������

--sample:
--1 1
--2 1
--1 2
--2 2
--1 3
--2 3

--�������1: ��� ������ ������ �� ������� laptop; 
--���������, ��� ������ - ��� "�������"; 
--���������� �� ������
create view pages_all_products as
select 
*,
row_number() over (order by model) rn,
case 
	when mod(row_number() over (order by model),2)=0 
	then 2 
	else 1 
end as num_on_page,
div(row_number() over (order by model)+1,2) as page_num
from laptop;

--������� 2: �������� ��� ������ � ��������� ���� �� ������ pc, laptop, printer
select 
*,
--row_number() over (order by model) rn,
case 
	when mod(row_number() over (order by model),2)=0 
	then 2 
	else 1 
end as num_on_page,
div(row_number() over (order by model)+1,2) as page_num
from 	(	select model, code,'PC' as type from pc
			union all
			select model,code,'Laptop' from laptop
			union all
			select model,code,'Printer' from printer
		) a

--task2 (lesson5)
-- ������������ �����: ������� view (distribution_by_type), 
--� ������ �������� ����� ���������� ����������� ���� ������� �� ���� ����������. 
--�����: �������������, ���, ������� (%)

--�������1: ��� % ���������� ���������� ������� ������ ���� (��������, pc) � ������ ���-�� �������
create view distribution_by_type as
select 
distinct
maker,
type,
--count(model) over (partition by maker) as cnt_ttl,
--count(model) over (partition by maker,type) as cnt_products_per_maker,
round(100.0*count(model) over (partition by maker,type)/count(model) over (partition by maker),2) as fraction
from product
order by maker,type

		
--task3 (lesson5)
-- ������������ �����: ������� �� ���� ����������� view ������ - �������� ���������. ������ https://plotly.com/python/histograms/

--��. colab

--task4 (lesson5)
-- �������: ������� ����� ������� ships (ships_two_words), 
--�� �������� ������� ������ �������� �� ���� ����
create table ships_two_words as
select 
*
from ships
where name like '% %'


--task5 (lesson5)
-- �������: ������� ������ ��������, � ������� class ����������� (IS NULL) 
--� �������� ���������� � ����� "S"
select 
*
from ships
where class is null and name like 'S%'

--task6 (lesson5)
-- ������������ �����: ������� ��� �������� ������������� = 'A' 
--�� ���������� ���� ������� �� ��������� ������������� = 'C' 
--� ��� ����� ������� (����� ������� �������). ������� model
--������� 1 (������������): ���� ���� 4 ������ � ���������� ������������ �����, �� ������� ��� ����� ��������� �����������
with base as 
			(select 
			t1.model,
			t1.price,
			t2.maker,
			avg(price) over (partition by maker) as avg_price
			from printer t1 
			left join product t2 
			on t1.model = t2.model and t2.type='Printer')
select
model 
from base
where maker='A' and price>(	select 
							coalesce(avg(price),0) 
							from base 
							where maker='C'
							)
union
select 
a.model
from
(select
model,
row_number() over(order by price desc) as rn
from printer) a
where a.rn<=3


