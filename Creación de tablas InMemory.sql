ALTER DATABASE AdventureWorks2019
    SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
GO  
  
USE AdventureWorks2019  
GO  
  
-- Cree una tabla optimizada para memoria duradera (los datos se conservarán)
-- dos de las columnas están indexadas.

CREATE TABLE dbo.CarritoCompra (   
    CarritoCompraId INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,  
    UsuarioId INT NOT NULL INDEX ix_UsuarioId NONCLUSTERED
        HASH WITH (BUCKET_COUNT=1000000), -- Cantidad estimada de registros en la tabla, considere el crecimiento para establecer este valor
    FechaCreacion DATETIME2 NOT NULL,   
    PrecioTotal MONEY  
    ) WITH (MEMORY_OPTIMIZED=ON)   
GO  

-- Crea una tabla no duradera. Los datos no se conservarán,
-- pérdida de datos si el servidor se apaga inesperadamente.

CREATE TABLE dbo.UsuarioSesion (   
   SesionId INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED
        HASH WITH (BUCKET_COUNT=400000), -- Cantidad estimada de registros en la tabla, considere el crecimiento para establecer este valor


   UsuarioId int NOT NULL,   
   FechaCreacion DATETIME2 NOT NULL,  
   CarritoCompraId INT,  
   INDEX ix_UsuarioId NONCLUSTERED
        HASH (UsuarioId) WITH (BUCKET_COUNT=400000)   
    )   
    WITH (MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_ONLY)
GO  
  
-- insertar datos en las tablas 
INSERT dbo.UsuarioSesion VALUES (342, SYSDATETIME(), 4);
INSERT dbo.UsuarioSesion VALUES (65, SYSDATETIME(), NULL)   
INSERT dbo.UsuarioSesion VALUES (8798, SYSDATETIME(), 1)   
INSERT dbo.UsuarioSesion VALUES (80, SYSDATETIME(), NULL)   
INSERT dbo.UsuarioSesion VALUES (4321, SYSDATETIME(), NULL)   
INSERT dbo.UsuarioSesion VALUES (8578, SYSDATETIME(), NULL)   
  
INSERT dbo.CarritoCompra VALUES (8798, SYSDATETIME(), NULL)   
INSERT dbo.CarritoCompra VALUES (23, SYSDATETIME(), 45.4)   
INSERT dbo.CarritoCompra VALUES (80, SYSDATETIME(), NULL)   
INSERT dbo.CarritoCompra VALUES (342, SYSDATETIME(), 65.4)   
GO  
  
-- Verificar el contenido de la tabla.

SELECT * FROM dbo.UsuarioSesion;
SELECT * FROM dbo.CarritoCompra;
GO  
  
-- Actualizar estadísticas en tablas optimizadas para memoria;

UPDATE STATISTICS dbo.UsuarioSesion  WITH FULLSCAN, NORECOMPUTE;
UPDATE STATISTICS dbo.CarritoCompra WITH FULLSCAN, NORECOMPUTE;
GO  
  
-- en una transacción explícita, asigne un carrito a una sesión
-- y actualizar el precio total.

BEGIN TRAN;
   UPDATE dbo.UsuarioSesion SET CarritoCompraId=3 WHERE SesionId=4;
   UPDATE dbo.CarritoCompra SET PrecioTotal=65.84 WHERE CarritoCompraId=3;
COMMIT;
GO   
  
-- consultamos los datos.

SELECT *   
    FROM dbo.UsuarioSesion u
        JOIN dbo.CarritoCompra s on u.CarritoCompraId=s.CarritoCompraId
    WHERE u.SesionId=4;
 GO  
  
-- Procedimiento almacenado compilado de forma nativa para la asignación
-- un carrito de compras a una sesión.

CREATE PROCEDURE dbo.usp_AsignarCarrito @SesionId int
    WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC
    WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT,
        LANGUAGE = N'us_english');
  
  DECLARE @UsuarioId INT,  
          @CarritoCompraId INT;
  
  SELECT @UsuarioId=UsuarioId, @CarritoCompraId=CarritoCompraId
  FROM dbo.UsuarioSesion WHERE SesionId=@SesionId;
  
  IF @UsuarioId IS NULL   
    THROW 51000, N'La sesión o carrito de compra no existe.', 1;
  
  UPDATE dbo.UsuarioSesion
    SET CarritoCompraId=@CarritoCompraId WHERE SesionId=@SesionId;
 END   
 GO  
  
 EXEC usp_AsignarCarrito 1;
 GO  
  
-- procedimiento almacenado compilado de forma nativa para insertar
-- un gran número de filas esto demuestra la rendimiento de procesos nativos
CREATE PROCEDURE dbo.usp_InsertarEjemploCompras @InsertCount int
    WITH NATIVE_COMPILATION, SCHEMABINDING   
AS
BEGIN ATOMIC   
    WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT,
        LANGUAGE = N'us_english');
  
  DECLARE @i int = 0;
  
  WHILE @i < @InsertCount   
  BEGIN   
    INSERT INTO dbo.CarritoCompra VALUES (1, SYSDATETIME() , NULL)
    SET @i += 1   
  END  
  
END   
GO  
  
-- insertamos 1,000,000 de filas
 EXEC usp_InsertarEjemploCompras 1000000   
 GO  
  
-- verificar que las filas se hayan insertado
 SELECT COUNT(*) FROM dbo.CarritoCompra   
 GO  
  
-- Ejemplo de tablas optimizadas para memoria para
-- pedidos de venta y detalles de pedidos de venta.
CREATE TABLE dbo.OrdenVenta   
(  
   ov_id INT NOT NULL PRIMARY KEY NONCLUSTERED,  
   cliente_id INT NOT NULL,  
   ov_date DATE NOT NULL INDEX ix_date NONCLUSTERED,  
   ov_total MONEY NOT NULL,  
   INDEX ix_fecha_total NONCLUSTERED
        (ov_date DESC, ov_total DESC)  
) WITH (MEMORY_OPTIMIZED=ON);
GO  
  
CREATE TABLE dbo.OrdenVentaDetalle  
(  
   ov_id INT NOT NULL,  
   itemlinea_id INT NOT NULL,  
   producto_id INT NOT NULL,  
   preciounitario MONEY NOT NULL,  
  
   CONSTRAINT PK_OVD PRIMARY KEY NONCLUSTERED
        (ov_id,itemlinea_id)
) WITH (MEMORY_OPTIMIZED=ON)  
GO  

-- Tipo de tabla optimizada para memoria para recopilar
-- detalles de la orden de venta.

CREATE TYPE dbo.OrdenVentaDetalleTipo AS TABLE  
(  
   ov_id INT NOT NULL,  
   itemlinea_id INT NOT NULL,  
   producto_id INT NOT NULL,  
   preciounitario MONEY NOT NULL,  
  
   PRIMARY KEY NONCLUSTERED (ov_id,itemlinea_id)  
) WITH (MEMORY_OPTIMIZED=ON)  
GO  
  
-- procedimiento almacenado que inserta una orden de venta,
-- junto con sus detalles.

CREATE PROCEDURE dbo.InsertarOrdenVenta
    @ov_id INT, @cliente_id INT,
    @items dbo.OrdenVentaDetalleTipo READONLY  
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS BEGIN ATOMIC WITH   
(  
   TRANSACTION ISOLATION LEVEL = SNAPSHOT,  
   LANGUAGE = N'us_english'  
)  
   DECLARE @total MONEY  
   SELECT @total = SUM(preciounitario) FROM @items  

   INSERT dbo.OrdenVenta
        VALUES (@ov_id, @cliente_id, getdate(), @total)

   INSERT dbo.OrdenVentaDetalle
        SELECT ov_id, itemlinea_id, producto_id, preciounitario
        FROM @items  
END  
GO  
  
-- Insertar un pedido de venta de muestra.
DECLARE @ov_id INT = 18,  
       @cliente_id INT = 8,  
       @items dbo.OrdenVentaDetalleTipo;

INSERT @items  VALUES   
       (@ov_id, 1, 4, 43),   
       (@ov_id, 2, 3, 3),   
       (@ov_id, 3, 8, 453),   
       (@ov_id, 4, 5, 76),   
       (@ov_id, 5, 4, 43);

EXEC dbo.InsertarOrdenVenta @ov_id, @cliente_id, @items;
GO  
  
-- verificar el contenido de las tablas
SELECT   
       so.ov_id,  
       so.ov_date,  
       sod.itemlinea_id,  
       sod.producto_id,  
       sod.preciounitario  
FROM dbo.OrdenVenta so
    JOIN dbo.OrdenVentaDetalle sod on so.ov_id=sod.ov_id  
ORDER BY so.ov_id, sod.itemlinea_id