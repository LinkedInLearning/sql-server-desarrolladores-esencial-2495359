Use AdventureWorks2019
GO

GO
CREATE TABLE dbo.ClienteDireccion
	(
	ClienteID int NOT NULL,
	DireccionID int NOT NULL,
	FechaAsignacion datetime NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.ClienteDireccion ADD CONSTRAINT
	DF_ClienteDireccion_FechaAsignacion DEFAULT getdate() FOR FechaAsignacion
GO
ALTER TABLE dbo.ClienteDireccion ADD CONSTRAINT
	PK_ClienteDireccion PRIMARY KEY CLUSTERED 
	(
	ClienteID,
	DireccionID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.ClienteDireccion ADD CONSTRAINT
	FK_ClienteDireccion_Cliente FOREIGN KEY
	(
	ClienteID
	) REFERENCES dbo.Cliente
	(
	ClienteID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.ClienteDireccion ADD CONSTRAINT
	FK_ClienteDireccion_Direccion FOREIGN KEY
	(
	DireccionID
	) REFERENCES dbo.Direccion
	(
	DireccionID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
