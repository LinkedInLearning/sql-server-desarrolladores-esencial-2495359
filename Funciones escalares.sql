Use AdventureWorks2019
GO
----funcion escalar
DROP FUNCTION IF EXISTS dbo.ufn_DiadelaSemana
GO
CREATE FUNCTION dbo.ufn_DiadelaSemana (@Fecha datetime)
RETURNS varchar(20)
WITH EXECUTE AS CALLER
AS
BEGIN
    return DATENAME(WEEKDAY,@Fecha)
    
END;
GO
--Prueba
SELECT dbo.ufn_DiadelaSemana(CONVERT(DATETIME,'2022-09-29',101)) AS 'Resultado';
GO


DROP FUNCTION IF EXISTS dbo.Multiplica2Numeros
GO
CREATE FUNCTION dbo.ufn_Multiplica2Numeros (@a int , @b int)
RETURNS varchar(20)
WITH EXECUTE AS CALLER
AS
BEGIN
    return (@a*@b)
    
END;
GO
--Prueba
SELECT dbo.ufn_Multiplica2Numeros(5,7) AS 'Resultado';
GO

--Ejemplo de funciones escalares del sistema
Select	Getdate() as FechaActual,
		TodoEnMayus = UPPER('MicrosOft sql'),
		TodoEnMinus = UPPER('MiCROSOFT Sql')
		
