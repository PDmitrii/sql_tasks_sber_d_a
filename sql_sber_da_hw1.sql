--����� ��: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

-- ������� 1: ������� name, class �� ��������, ���������� ����� 1920
select 
name,
class 
from ships
where launched>1920;

-- ������� 2: ������� name, class �� ��������, ���������� ����� 1920, �� �� ������� 1942
select
name,
class 
from ships
where launched >1920 and launched <=1942;

-- ������� 3: ����� ���������� �������� � ������ ������. ������� ���������� � class
select 
count(*),
class
from ships
group by class
order by 1 desc;

-- ������� 4: ��� ������� ��������, ������ ������ ������� �� ����� 16, ������� ����� � ������. (������� classes)
select
class,
country
from classes 
where bore>=16;

-- ������� 5: ������� �������, ����������� � ��������� � �������� ��������� (������� Outcomes, North Atlantic). �����: ship.
select ship 
from outcomes
where battle='North Atlantic' and result='sunk';

-- ������� 6: ������� �������� (ship) ���������� ������������ �������
select 
ship
from outcomes
left join battles
on outcomes.battle=battles.name
where outcomes.result='sunk'
and date=(select 
			max(date)
			from outcomes
			left join battles
			on outcomes.battle=battles.name
			where outcomes.result='sunk'
		);

-- ������� 7: ������� �������� ������� (ship) � ����� (class) ���������� ������������ �������
select 
ship,class
from outcomes
left join battles
on outcomes.battle=battles.name
left join ships
on outcomes.ship=ships.name
where outcomes.result='sunk'
and date=(select 
			max(date)
			from outcomes
			left join battles
			on outcomes.battle=battles.name
			where outcomes.result='sunk'
		);

-- ������� 8: ������� ��� ����������� �������, � ������� ������ ������ �� ����� 16, � ������� ���������. �����: ship, class
select 
outcomes.ship,
ships.class 
from outcomes
left join ships
on outcomes.ship = ships.name
left join classes
on ships.class=classes.class
where outcomes.result='sunk' and classes.bore >=16;


-- ������� 9: ������� ��� ������ ��������, ���������� ��� (������� classes, country = 'USA'). �����: class
select 
class 
from classes 
where country='USA';

-- ������� 10: ������� ��� �������, ���������� ��� (������� classes & ships, country = 'USA'). �����: name, class
select 
ships.name,
ships.class
from ships
left join classes
on ships.class=classes.class
where classes.country='USA'