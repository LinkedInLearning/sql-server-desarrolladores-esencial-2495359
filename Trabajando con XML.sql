USE AdventureWorks2019;
GO

--Uso de sentencia FOR XML
--Consutrye un xml de la consulta sin nodo primario
SELECT DriverID,Name,Department
FROM Driver
FOR XML RAW, ELEMENTS;
GO

--Uso de sentencia FOR XML RAW
--Consutrye un xml de la consulta con nodo primario
;With Childrens1
as
(
	SELECT 'Samael' Name
	UNION ALL
	SELECT 'Odisea' 
)
SELECT DriverID as '@DriverID' --para generar un atributo de un elemento
		,Name as '@Name'
		,Department as '@Deparment'
		,(	SELECT	Name as '@Name'
			From	Childrens1
			FOR XML PATH ('Children'), type
		) AS Childrens
FROM Driver as d
FOR XML PATH('Driver') --Para identificar el elemento a diferencia de la consulta anterior se especia ques es de nombre Driver
	, ELEMENTS XSINIL--Para columnas con valores nulos
	, root('Drivers'); --para agrupar elementos
GO


--Uso de OpenXML para leer un xml y llevarlo a una forma columnar
DECLARE @DocHandle int;
DECLARE @XmlDocument nvarchar(1000);
SET @XmlDocument = N'<Drivers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Driver DriverID="1" Name="John Connor" Deparment="East Blue">
    <Childrens>
      <Children Name="Samael" />
      <Children Name="Odisea" />
    </Childrens>
  </Driver>
  <Driver DriverID="2" Name="Elvis Presley" Deparment="Famous singer">
    <Childrens>
      <Children Name="Samael" />
      <Children Name="Odisea" />
    </Childrens>
  </Driver>
</Drivers>';
-- Create an internal representation of the XML document.
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlDocument;
-- Execute a SELECT statement using OPENXML rowset provider.
SELECT *
FROM OPENXML (@DocHandle, '/Drivers/Driver',1)
      WITH (DriverID  int,
            Name varchar(100));
EXEC sp_xml_removedocument @DocHandle;
