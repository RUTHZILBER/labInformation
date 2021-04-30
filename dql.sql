
select * from test
--this a question for Ms. edelstein:
--how can i add error message,error line etc.
--together without select or by cast
--as nvarchar, it does problems...

alter proc addTestSql(@germName nvarchar(20),@medicineName nvarchar(20),@testDate date,@reactionType nvarchar(10))
 as
begin
begin try
	declare @flag int =0;
	declare @germ int=0,@medicine int=0;
	select @germ = germId from germ where germName=@germName
	select @medicine=medicineId from medicine where @medicineName=medicineName

	insert into test(germId,medicineId,testDate,reactionType) values
					 (@germ,@medicine,@testDate,@reactionType)

				if @reactionType='dead' 
					begin
					update germ set medicineId=@medicine, medicineDate=@testDate
					where germId=@germ
					
					exec movToArchive select germId from germ where germId=@germName
			         end
end try

begin catch
	
	if(@germ=0)
		begin
		
		insert into exceptoin values(cast((select ERROR_PROCEDURE())as nvarchar(188)) ,GETDATE())
			set @flag=1;
		end
	if (@medicine=0)
		begin
			print 'the medicineId value is not correct';
			insert into exceptoin values('The INSERT statement conflicted with the FOREIGN KEY constraint "FK__test__germId__60A75C0F". The conflict occurred in database "germ", table "dbo.germ", column 
"medcineId"',GETDATE())
			set @flag=1;
		end
		
	if(@reactionType not in('dying','alive','dead'))
		begin
		print 'the statusType of the germ is wrong';
		insert into exceptoin values ('the statusType of the germ is wrong',GETDATE())
		set @flag=1;
		end
if @flag=0
begin
	select * from test t join medicine m
	on t.medicineId=m.medicineId join germ g on g.germId=t.germId
	 where @medicineName=m.medicineName
	 and @germName=g.germName
	 if @@ROWCOUNT!=0
		begin
			set @flag=1;
			insert into exceptoin values ('the term was tried on this term at past',GETDATE())
		end

end 
end catch
end

select * from test
select * from Medicine
 exec movToArchive 112
 select * from exceptoin
 select * from archive 
 exec addTestSql 'baktus','unti','5-8-2029','dying' 
select * from medicine
select * from germ g join test t on t.germId=g.germId
select * from archive
insert into test values(77,1204,'5-05-2001','dying')
execute updateStatus 113,1003,'dead'

create view vShuts
as
select g.germName 'germName',m.medicineName  'medicineName',g.medicineDate 'medicineDate' 
from
Medicine m join Germ g on g.medicineId=m.medicineId
select * from test
select * from germ
insert into germ values('YOCUS','1005','1998-7-30',1000,'01-01-2001')
insert into test values(111,1004,'07-01-2003','dying')
insert into archive values('yocus',)
select * from vShuts
create proc movToArchive(@id int)--insert the test into archive
as
begin
begin tran
begin try
insert into Archive select g.germName,g.germId,t.testDate,m.medicineName,t.reactionType  
from Test t join Germ g on t.germId=g.germId join Medicine m on m.medicineId=t.medicineId
where g.germId=@id
delete Test where germId=@id
commit tran
end try
begin catch
rollback tran
end catch
end
go
declare  @b int=111
execute  movToArchive @b
select * from test
exec updateStatus 102,1000,'alive'
alter proc stayingAlive(@germId int,@medicineId int)
as
begin
	declare @diff int
	select @diff=DATEDIFF(month, getDate(),testDate) from Test where germId=@germId
	and medicineId=@medicineId
	
	if(@diff>2)
		exec updateStatus @germId,@medicineId,'alive'
end

select * from test
exec stayingAlive  112,1001

drop function testToGerm(@id int)--some of tests of germ
returns int
as
begin
declare @num int
select @num=count(*) from Germ g join Test t on t.germId=g.germId
where g.germId=@id
return @num
end
print dbo.testToGerm(104)

create function germForShut(@medicineName nvarchar(20))--list of the germs
returns @table table(
germName nvarchar(20)
)
as
begin
insert into @table
select distinct m.medicineName 
from Test t join Medicine m on m.medicineId=t.medicineId
where @medicineName=m.medicineName
return
end
select * from dbo.germForShut('penitziln')
create proc updateStatus(@germId int,@medicineId int,@reactionType nvarchar(10))
as
begin
	update test set reactionType=@reactionType where
	medicineId=@medicineId and @germId=germId
if ((@reactionType!='alive')and(@reactionType!='dying'))
	begin
		 update germ set medicineId=@medicineId ,medicineDate=(select top 1 test.testDate
		 from test where test.germId=@germId order by test.testDate)
		 execute  movToArchive @germId
	end
end
select * from test
inselect * from dbo.germMostPrensistent()sert into test values (111,1003,'2016-05-08','alive')
 select  * from dbo.germMostPrensistent()


create function germMostPrensistent()
returns @t table(
germNumberTest int,
germName nvarchar(20)
)
begin
insert into @t
select count(*)  ,g.germName 
from germ g 
join test t on t.germId=g.germId group by g.germName
having count(*)=
(select max(sub1.co) from
(select count(*) 'co',g.germName 
from germ g 
join test t on t.germId=g.germId 
group by g.germName) sub1)
return
end
select * from dbo.germMostPrensistent()
--declare @germId int,@medicineId int;--this is cursor for update status
--declare crs cursor
--for select germId,medicineId from test
--open crs
--fetch next from crs
--into @germId,@medicineId
--while @@FETCH_STATUS=0
--	begin
	
--	exec stayingAlive @germId,@medicineId 

--	fetch next from crs
--	into @germId,@medicineId
--	end
--close crs
--deallocate crs

select * from test
create trigger tStayAlive on test for update as
begin

	declare @germId int,@medicineId int
	declare c cursor
	 for select germId,medicineId from test  
	open crs
	fetch next from c into @germId,@medicineId
	
	while @@FETCH_STATUS=0
		begin
		
		exec stayingAlive @germId,@medicineId 
		fetch next from c
		into @germId,@medicineId
		end
	close crs
	deallocate crs
end 

select * from test
declare @germId int,@medicineId int
	declare crs cursor for
	 select germId,medicineId from test  
	open crs
	fetch next from crs into @germId,@medicineId
	
	while @@FETCH_STATUS=0
		begin
		
				exec stayingAlive 102,1000 
				fetch next from crs
				into @germId,@medicineId
		end
	close crs
	deallocate crs
