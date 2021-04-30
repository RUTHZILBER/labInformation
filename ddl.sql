

create database Laboratory
go
create table germ
(
germId int identity(100,1)primary key,
germName nvarchar(20) not null unique,
shortDesc nvarchar(20),
dateId date not null,
medicineId int not null foreign key references medicine(medicineId),
medicineDate date not null         
)

create table medicine
(
medicineId int identity(1000,1) primary key,
medicineName nvarchar(20) not null unique

)

create table test
(

germId int foreign key references Germ(germId),
medicineId int foreign key references Medicine(medicineId),
testDate date,
reactionType nvarchar(10) check (reactionType in ('dying','dead','alive'))
primary key(germId,medicineId)--if there are two primary key
)

create table archive
(
germName nvarchar(20),
germId numeric(3),
testDate date,
medicineName nvarchar(20),
reactionType nvarchar(10),

)

create table exceptoin
(
mesage nvarchar(300),
mesageDate dateTime 
)