Use AdventureWorks2019
GO

--funcion inline table value
DROP FUNCTION IF EXISTS dbo.ufn_ConductorPorNombre
GO
CREATE FUNCTION dbo.ufn_ConductorPorNombre (@filtro varchar(50))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM	dbo.Driver 
    WHERE	Name like '%' + @filtro + '%'
);
GO

Select DriverID,Name,Department,AnnualSalary,Incremento,c.ValidFrom,c.ValidTo
From dbo.ufn_ConductorPorNombre('user') as c
cross apply (select c.AnnualSalary * 1.13 as Incremento) as incremento_salario
GO

--funcion multi-statement table-valued
DROP FUNCTION IF EXISTS dbo.ufn_HallarCalculos
GO
CREATE FUNCTION dbo.ufn_HallarCalculos (@NumeroA int, @NumeroB int)
RETURNS @calculos TABLE
(
    NumeroA int NOT NULL,
	NumeroB int NOT NULL,
    Suma	int NOT NULL,
	Resta	int NOT NULL,
	Mult	int NOT NULL,
	Div		int NOT NULL
)
AS
BEGIN
	--realizamos validaciones
	if @NumeroA < @NumeroB or @NumeroA <= 0 or @NumeroB <= 0
		return
	
    INSERT	@calculos
    SELECT	@NumeroA,@NumeroB,@NumeroA+@NumeroB
			,@NumeroA-@NumeroB
			,@NumeroA*@NumeroB
			,@NumeroA/@NumeroB
    RETURN
END;
GO
-- Prueba
SELECT *
FROM dbo.ufn_HallarCalculos(12,3);

GO
