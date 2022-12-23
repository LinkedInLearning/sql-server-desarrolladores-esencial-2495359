--Uso de sentencia FOR XML
--Consutrye un xml de la consulta sin nodo primario
SELECT DriverID,Name,Department 
FROM Driver
FOR JSON AUTO;
GO

--Consutrye un xml de la consulta sin nodo primario
SELECT DriverID,Name
		,Department as 'Department.Name' -- con la clausula path crea un objeto Department interno con un atributo Name
FROM Driver
FOR JSON PATH;
GO

--Uso de sentencia FOR JSON AITO
--Construye un objeto json 
;With Childrens1
as
(
	SELECT DriverID = 1,'Samael' Name,'M' Gender, 'Miami' City
	UNION ALL
	SELECT 2,'Odisea','F', 'Toronto'
)
SELECT DriverID 
		,Name 
		,Department 
		,(	SELECT	Name as 'Name', Gender, City as 'Location.City'
			From	Childrens1 as c
			Where	c.DriverID = d.DriverID
			FOR JSON PATH
		) AS Childrens
FROM Driver as d
FOR JSON AUTO 
	, INCLUDE_NULL_VALUES    --Para columnas con valores nulos	
	, root('Drivers'); --para agrupar elementos en un objeto padre
GO


DECLARE @json NVARCHAR(MAX)

SET @json='{"name":"John","surname":"Doe","age":45,"skills":["SQL","C#","MVC"]}';

SELECT *
FROM OPENJSON(@json);