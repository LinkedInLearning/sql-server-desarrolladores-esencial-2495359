DROP TABLE IF EXISTS dbo.Empleado
GO

CREATE TABLE dbo.Empleado
	(
	EmpleadoID int NOT NULL IDENTITY (1, 1),
	Nombre varchar(100) NOT NULL,
	FechaNacimiento date NOT NULL,
	Genero char(1) NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Empleado ADD CONSTRAINT
	PK_Empleado PRIMARY KEY CLUSTERED 
	(
	EmpleadoID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO


declare @FechaNacimiento datetime = getdate() 
declare @cantidadFilas int = 1000000

SET IDENTITY_INSERT dbo.Empleado on;

;with GenerarFilas as (
	select top (@cantidadFilas) ROW_NUMBER() over (order by (select null)) as ID, @FechaNacimiento as FechaNacimiento, ' ' as Genero 
	from sys.all_columns c1
	cross join sys.all_columns c2
	cross join sys.all_columns c3
)
Insert Into dbo.Empleado(EmpleadoID,Nombre,FechaNacimiento,Genero)
select ID as EmpleadoID, concat('Empleado_' , id) as Nombre, dateadd(YEAR, (ID % 30)*-1, FechaNacimiento) as FechaNacimiento, Genero  
from GenerarFilas


SET IDENTITY_INSERT dbo.Empleado OFF;

exec sp_spaceused 'Empleado'




--Create clustered
DROP TABLE IF EXISTS dbo.EmpleadoClustered
GO

CREATE TABLE dbo.EmpleadoClustered
	(
	EmpleadoID int NOT NULL,
	Nombre varchar(100) NOT NULL,
	FechaNacimiento date NOT NULL,
	Genero char(1) NOT NULL
	)  
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_EmpleadoClustered ON dbo.EmpleadoClustered;  
GO  


INSERT INTO dbo.EmpleadoClustered (EmpleadoID,Nombre,FechaNacimiento,Genero)
select EmpleadoID,Nombre,FechaNacimiento,Genero from dbo.Empleado

exec sp_spaceused 'Empleado'
exec sp_spaceused 'EmpleadoClustered'



--RowStore Index sobre una tabla ColumnStore
CREATE UNIQUE NONCLUSTERED INDEX [NCI_EmpleadoClustred_EmpleadoID] ON [dbo].[EmpleadoClustered]
(
	[EmpleadoID] ASC
)

--ver plan de ejecución
--Uso CCI
select count(*) from [dbo].[EmpleadoClustered] 
where FechaNacimiento > = dateadd(YEAR, -26, getdate())


--Uso NCI
select * from [dbo].[EmpleadoClustered] 
where EmpleadoID = 491296


--Nuevo NCCI sobre tabla row Store
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_Empleado_FechaNacimiento] ON [dbo].[Empleado]
(
	[FechaNacimiento]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)


select count(*) from [dbo].[Empleado]
where FechaNacimiento > = dateadd(YEAR, -26, getdate())