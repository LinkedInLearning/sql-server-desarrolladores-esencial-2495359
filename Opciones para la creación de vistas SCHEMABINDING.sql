CREATE VIEW [HumanResources].[vEmployee]
WITH SCHEMABINDING 
AS
SELECT        e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName, p.LastName, p.Suffix, e.JobTitle, pp.PhoneNumber, pnt.Name AS PhoneNumberType, ea.EmailAddress, p.EmailPromotion, a.AddressLine1, a.AddressLine2, a.City, 
                         sp.Name AS StateProvinceName, a.PostalCode, cr.Name AS CountryRegionName, p.AdditionalContactInfo
FROM            HumanResources.Employee AS e INNER JOIN
                         Person.Person AS p ON p.BusinessEntityID = e.BusinessEntityID INNER JOIN
                         Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = e.BusinessEntityID INNER JOIN
                         Person.Address AS a ON a.AddressID = bea.AddressID INNER JOIN
                         Person.StateProvince AS sp ON sp.StateProvinceID = a.StateProvinceID INNER JOIN
                         Person.CountryRegion AS cr ON cr.CountryRegionCode = sp.CountryRegionCode LEFT OUTER JOIN
                         Person.PersonPhone AS pp ON pp.BusinessEntityID = p.BusinessEntityID LEFT OUTER JOIN
                         Person.PhoneNumberType AS pnt ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID LEFT OUTER JOIN
                         Person.EmailAddress AS ea ON p.BusinessEntityID = ea.BusinessEntityID
GO