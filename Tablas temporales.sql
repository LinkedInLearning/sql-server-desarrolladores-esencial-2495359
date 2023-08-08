drop table if exists dbo.Driver
go
--ALTER TABLE dbo.Driver SET (SYSTEM_VERSIONING = OFF);

/*Limpieza

ALTER TABLE [dbo].[Driver] SET ( SYSTEM_VERSIONING = OFF  )
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Driver]') AND type in (N'U'))
DROP TABLE [dbo].[Driver]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DriverHistory]') AND type in (N'U'))
DROP TABLE [dbo].[DriverHistory]
GO

*/


CREATE TABLE dbo.Driver
(
  [DriverID] int NOT NULL PRIMARY KEY CLUSTERED
  , [Name] nvarchar(100) NOT NULL
  , [Department] varchar(100) NOT NULL  
  , [AnnualSalary] decimal (10,2) NOT NULL
  , [ValidFrom] datetime2 GENERATED ALWAYS AS ROW START
  , [ValidTo] datetime2 GENERATED ALWAYS AS ROW END
  , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
 )
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DriverHistory));
GO

Insert Into dbo.Driver ([DriverID]   , [Name]   , [Department]   , [AnnualSalary])
Values(1,'User 1','East Blue',56000),(2,'Singer 1','Famous singer',1200000)

--Consultamos Conductores
Select * from dbo.Driver

--Actualziamos registro
update dbo.Driver set AnnualSalary = 456000 where DriverID = 1

--Consultamos regustro historico
--Mover fecha segun la ejecucion para ver mas o menos registros
SELECT * FROM dbo.Driver
  FOR SYSTEM_TIME
    BETWEEN '2022-01-01 00:00:00.0000000' AND '2023-01-01 00:00:00.0000000'
      ORDER BY ValidFrom;