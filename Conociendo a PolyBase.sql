--Habilitar PolyBase
exec sp_configure @configname = 'polybase enabled', @configvalue = 1;
RECONFIGURE;

--Create a Master Key si no existe
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'S0me!nfo';
GO

--Crear Credencial SAS
CREATE DATABASE SCOPED CREDENTIAL [polybase]
WITH IDENTITY = 'Shared Access Signature' , SECRET = 'sv=2018-03-28&sr=c&sig=UzY65wtrKfqvg6Qeu6x6jCDGORa7S90AHwV0g9n6TjA%3D&se=2023-10-04T05%3A00%3A00Z&sp=rwdl'
GO

--Formato Externo
CREATE EXTERNAL FILE FORMAT TextFileFormat WITH (
	FORMAT_TYPE = DELIMITEDTEXT,
	FORMAT_OPTIONS (FIELD_TERMINATOR =',',
	USE_TYPE_DEFAULT = TRUE)
	)
go

/*
Limpieza si se requiere

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExternalEmpleado]') AND type in (N'U'))
DROP EXTERNAL TABLE [dbo].[ExternalEmpleado]
GO

DROP EXTERNAL DATA SOURCE [storpolybase]
GO

*/

--Acceso a cuenta ADLS
CREATE EXTERNAL DATA SOURCE [storpolybase] WITH (
  LOCATION = N'adls://storpolybase.dfs.core.windows.net/polybase'
, CREDENTIAL = [polybase])
GO

--Tabla Externa
CREATE EXTERNAL TABLE [dbo].[ExternalEmpleado]
(
	EmpleadoID int NOT NULL,
	Nombre varchar(100) NOT NULL,
	FechaNacimiento date NOT NULL,
	Genero char(1) NOT NULL
)
WITH (DATA_SOURCE = [storpolybase],LOCATION = N'Test',FILE_FORMAT = [TextFileFormat],REJECT_TYPE = VALUE,REJECT_VALUE = 0)
GO

--Prueba Tabla Externa
select  * from [dbo].[ExternalEmpleado]
