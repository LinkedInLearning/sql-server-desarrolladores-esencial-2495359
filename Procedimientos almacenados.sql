--Tipo de datos tabla para datos del detalle de ventas
CREATE TYPE SalesOrderDetail
AS TABLE (
	CarrierTrackingNumber nvarchar(25), 
	OrderQty smallint, 
	ProductID int, 
	SpecialOfferID int, 
	UnitPrice money, 
	UnitPriceDiscount money 
)
GO

GO
--Procedimiento almacenado para crear órdenes de venta
alter PROCEDURE Sales.uspSaveSalesOrder (
	@RevisionNumber tinyint, 
	@OrderDate datetime, 
	@DueDate datetime, 
	@ShipDate datetime, 
	@Status tinyint, 
	@OnlineOrderFlag bit, 
	@SalesOrderNumber nvarchar(25), 
	@PurchaseOrderNumber nvarchar(25), 
	@AccountNumber nvarchar(15), 
	@CustomerID int, 
	@SalesPersonID int, 
	@TerritoryID int, 
	@BillToAddressID int, 
	@ShipToAddressID int, 
	@ShipMethodID int, 
	@CreditCardID int, 
	@CreditCardApprovalCode varchar(15), 
	@CurrencyRateID int, 
	@SubTotal money, 
	@TaxAmt money, 
	@Freight money, 
	@Comment nvarchar(128), 
	@SalesOrderDetail SalesOrderDetail READONLY,
	@SalesOrderID int output
) AS
BEGIN

	declare @ModifiedDate datetime = GETDATE()

	BEGIN TRAN
		--se inserta el encabezado
		INSERT INTO Sales.SalesOrderHeader
				(RevisionNumber, OrderDate, DueDate, ShipDate, [Status], OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, 
				CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment, rowguid, ModifiedDate)
		VALUES (@RevisionNumber,@OrderDate,@DueDate,@ShipDate,@Status,@OnlineOrderFlag,@PurchaseOrderNumber,@AccountNumber,@CustomerID,@SalesPersonID,@TerritoryID,@BillToAddressID,@ShipToAddressID,@ShipMethodID,@CreditCardID,@CreditCardApprovalCode,@CurrencyRateID,@SubTotal,@TaxAmt,@Freight,@Comment,
				NEWID(), @ModifiedDate)

		--Se obtiene el ID de la venta generado
		SET @SalesOrderID = SCOPE_IDENTITY()
	
		--En la misma operación se agregan los detalles
		INSERT INTO Sales.SalesOrderDetail (SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount,rowguid, ModifiedDate)
		SELECT @SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, NEWID(), @ModifiedDate
		FROM  @SalesOrderDetail
	COMMIT TRAN

END 

go

--LLAMAR EL PROCEDIMIENTO ALMACENADO
--Crear una tabla basada en el tipo de datos tipo tabla
DECLARE @sdTVP SalesOrderDetail

--Simulación de detalles de venta
INSERT INTO @sdTVP (CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount)
SELECT CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount FROM (
VALUES 
('4E0A-4F89', 1, 745, 1, 809.76, 0),
('4E0A-4F89', 1, 743, 1, 714.7043, 0),
('4E0A-4F89', 2, 747, 1, 714.7043, 0),
('4E0A-4F89', 4, 712, 1, 5.1865, 0),
('4E0A-4F89', 4, 715, 1, 28.8404, 0),
('4E0A-4F89', 2, 742, 1, 722.5949, 0),
('4E0A-4F89', 3, 775, 1, 2024.994, 0),
('4E0A-4F89', 2, 778, 1, 2024.994, 0),
('4E0A-4F89', 2, 711, 1, 20.1865, 0),
('4E0A-4F89', 2, 741, 1, 818.7, 0),
('4E0A-4F89', 4, 776, 1, 2024.994, 0),
('4E0A-4F89', 2, 773, 1, 2039.994, 0),
('4E0A-4F89', 2, 716, 1, 28.8404, 0),
('4E0A-4F89', 2, 777, 1, 2024.994, 0),
('4E0A-4F89', 5, 708, 1, 20.1865, 0)
) 
AS Details(CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount);  

--Consultar los detalles de venta
select * from @sdTVP

--Simulación de fechas de Orden, Vencimiento y Envío
Declare @od Datetime = DATEADD(day,0,getdate())
Declare @dd Datetime = DATEADD(day,30,getdate())
Declare @sd Datetime = DATEADD(day,45,getdate())

DECLARE @soID INT 

--Ejecutar procedimiento
exec Sales.uspSaveSalesOrder
	@RevisionNumber = 8,
	@OrderDate = @od,
	@DueDate = @dd,
	@ShipDate = @sd,
	@Status = 5,
	@OnlineOrderFlag = 0,
	@SalesOrderNumber = '',
	@PurchaseOrderNumber = 'PO18473189620',
	@AccountNumber = '10-4020-000442',
	@CustomerID = 29734,
	@SalesPersonID = 282,
	@TerritoryID = 6,
	@BillToAddressID = 517,
	@ShipToAddressID = 517,
	@ShipMethodID = 5,
	@CreditCardID = 1346,
	@CreditCardApprovalCode = '85274Vi6854',
	@CurrencyRateID = 4,
	@SubTotal = 32726.4786,
	@TaxAmt = 3153.7696,
	@Freight = 985.553,
	@Comment = NULL,
	@SalesOrderDetail = @sdTVP,
	@SalesOrderID = @soID OUTPUT;

--Verificar valor de salida
select @soID


--Verificar Resultados
select * from sales.SalesOrderHeader
where SalesOrderID = @soID


select * from sales.SalesOrderDetail
where SalesOrderID = @soID
