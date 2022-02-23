use AdventureWorksDW2017;
go 

create table MachineLearning.Model 
(
    ModelId                            int not null,
    ModelName                          varchar (50) not null,
    Version                            int not null,
    CreatedDate                        datetime not null,
    LastProcessedDate                  datetime not null,
    RCode                              varchar(max),
    Model                              varbinary(max)
    constraint PK_Model primary key clustered (ModelId asc)
);

