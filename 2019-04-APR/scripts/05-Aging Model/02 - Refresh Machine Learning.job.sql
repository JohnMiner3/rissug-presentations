use msdb;
go


if  exists (select job_id from msdb.dbo.sysjobs_view where name = 'Refresh Machine Learning')
    exec sp_delete_job @job_name='Refresh Machine Learning', @delete_unused_schedule=1;
go


if not exists (select name from syscategories where name='MachineLearning' and category_class=1)
    exec sp_add_category @class='JOB', @type='LOCAL', @name='MachineLearning';
go

begin transaction;

begin try

    exec sp_add_job 
        @job_name='Refresh Machine Learning', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description='No description available.', 
		@category_name='MachineLearning', 
		@owner_login_name='sa';

    exec sp_add_jobstep 
        @job_name='Refresh Machine Learning', 
        @step_name='Customer Bike', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
        @subsystem='TSQL', 
		@command='MachineLearning.uspPublishCustomerBike', 
		@server='jflanner\jwf', 
		@database_name='AdventureWorksDW2017', 
		@flags=0;

    exec sp_add_jobstep 
        @job_name='Refresh Machine Learning', 
        @step_name='Customer Revenue', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
        @subsystem='TSQL', 
		@command='MachineLearning.uspPublishCustomerRevenue', 
		@server='jflanner\jwf', 
		@database_name='AdventureWorksDW2017', 
		@flags=0;


    exec sp_update_job 
        @job_name='Refresh Machine Learning', 
        @start_step_id = 1; 


    exec sp_add_jobserver 
        @job_name='Refresh Machine Learning',
        @server_name = '(local)';


    commit transaction;

end try

begin catch

    rollback transaction;

    throw;

end catch

