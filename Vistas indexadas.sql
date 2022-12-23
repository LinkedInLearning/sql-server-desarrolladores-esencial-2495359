--Tablas Base
SELECT * FROM [Production].[Product]
  
SELECT * FROM [Production].[ProductSubcategory]
go

--Creación de vista de prueba
create or alter view Production.vProductSubCategory
as
SELECT p.ProductID, sc.Name AS ProductSubCategory, p.Name AS Product, p.ProductNumber, p.ListPrice, p.Weight
FROM Production.ProductSubcategory AS sc 
INNER JOIN Production.Product AS p 
	ON sc.ProductSubcategoryID = p.ProductSubcategoryID
go


--Se intenta actualizar, genera error al intentar actualizar dos tablas
update Production.vProductSubCategory
	set ProductSubCategory = 'prueba'
	,Product = 'ProductoPrueba'
	where ProductID = 706

--Permite actualizar datos de una tabla a la vez
update Production.vProductSubCategory
	set Product = 'ProductoPrueba'
	where ProductID = 706

--Se verifica la actualización 
select * from Production.vProductSubCategory
	where ProductID = 706

--Igual para inserts
--No se pueden actualizar columnas derivadas


--Usandola opción WITH CHECK
create or alter view Production.vProductSubCategoryHelmets
as
SELECT p.ProductID, sc.Name AS ProductSubCategory, p.Name AS Product, p.ProductNumber, p.ListPrice, p.Weight
FROM Production.ProductSubcategory AS sc 
INNER JOIN Production.Product AS p 
	ON sc.ProductSubcategoryID = p.ProductSubcategoryID
	where sc.Name = 'Helmets'
go

--Comprobando vista
select * from Production.vProductSubCategoryHelmets

--Ejecutando Update
update Production.vProductSubCategoryHelmets
set ProductSubCategory = 'PruebaCambio'
where ProductID = 707


--Comprobando vista: no se ven resultados pq se actualizó la tabla
select * from Production.vProductSubCategoryHelmets

--Verificar tabla subyacente
select * from Production.ProductSubcategory
where name  = 'PruebaCambio'

--Reversando cambio
UPDATE       Production.ProductSubcategory
SET                Name = N'Helmets'
WHERE        (Name = 'PruebaCambio')

--Se agrega la opción with check 
create or alter view Production.vProductSubCategoryHelmets
as
SELECT p.ProductID, sc.Name AS ProductSubCategory, p.Name AS Product, p.ProductNumber, p.ListPrice, p.Weight
FROM Production.ProductSubcategory AS sc 
INNER JOIN Production.Product AS p 
	ON sc.ProductSubcategoryID = p.ProductSubcategoryID
	where sc.Name = 'Helmets'
WITH CHECK OPTION
go

--Ejecutando Update: se genera error por la opción with check
update Production.vProductSubCategoryHelmets
set ProductSubCategory = 'PruebaCambio'
where ProductID = 707
