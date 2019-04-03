use master;
go 

if charindex('jflanner', @@ServerName) <> 1
begin; 
    throw 51000, 'You''re an @$$', 1;
    set noexec on; 
end

if db_id('AdventureWorksDW2017') is not null
begin
    alter database AdventureWorksDW2017 set  single_user with rollback immediate;
    drop database AdventureWorksDW2017;
end


-- restore filelistonly from disk = 'c:\SQLData\jwf\backup\AdventureWorksDW2017.bak' 

restore database AdventureWorksDW2017
from disk = 'c:\SQLData\jwf\backup\AdventureWorksDW2017.bak' 
with move 'AdventureWorksDW2017' to 'c:\SQLData\jwf\Data\AdventureWorksDW2017.mdf', 
     move 'AdventureWorksDW2017_log' to 'c:\SQLData\jwf\TransactionLog\AdventureWorksDW2017_log.ldf'; 

