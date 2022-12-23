
--  Planes de ejecución en Cache disponibles para SQL Server
select * from sys.dm_exec_cached_plans 

-- Sesiones en Sql Server
select * from sys.dm_exec_sessions 

-- Conexiones a SQL Server
select * from sys.dm_exec_connections 

-- Seeks, scans, lookups por índece
select * from sys.dm_db_index_usage_stats 

-- Estadísticas IO para la base de datos y archivos de Log
SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks2019'), 2);  


-- Estado de las transacciones activas en la instancia
select * from sys.dm_tran_active_transactions 

-- Mostrar el plan de ejecución
SELECT * 
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle);  
GO  

-- Información respecto a los recursos que están en espera
select * from sys.dm_os_wait_stats 

-- Valores de los contadores de rendimiento relacionados a SQL Server
select * from sys.dm_os_performance_counters 