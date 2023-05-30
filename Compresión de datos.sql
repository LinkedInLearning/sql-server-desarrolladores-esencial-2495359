USE [AdventureWorks2019]
ALTER TABLE [dbo].[Empleado] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = ROW
)

exec sp_spaceused 'Empleado'


ALTER TABLE [dbo].[Empleado] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = PAGE
)

exec sp_spaceused 'Empleado'

ALTER TABLE [dbo].[Empleado] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = NONE
)

exec sp_spaceused 'Empleado'