--Crear base de datos
CREATE DATABASE CustomerData;
            Go 
            USE CustomerData;
            GO
                 
            CREATE TABLE CustomerData.dbo.CustomerInfo
            (CustID        INT PRIMARY KEY, 
             CustName     VARCHAR(30) NOT NULL, 
             BankACCNumber VARCHAR(10) NOT NULL
            );
            GO

--Llenar datos de ejemplo
Insert into CustomerData.dbo.CustomerInfo (CustID,CustName,BankACCNumber)
            Select 1,'Rajendra',11111111 UNION ALL
            Select 2, 'Manoj',22222222 UNION ALL
            Select 3, 'Shyam',33333333 UNION ALL
            Select 4,'Akshita',44444444 UNION ALL
            Select 5, 'Kashish',55555555

--Creación de llave maestra de cifrado
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QR6KJNY)!ZQsVQ$K';

--Creación de certificado para proteger la llave simétrica
USE CustomerData;
GO
CREATE CERTIFICATE Certificate_test WITH SUBJECT = 'Protect my data';
GO

--Verificación de llaves
ALTER TABLE CustomerData.dbo.CustomerInfo
ADD BankACCNumber_encrypt varbinary(MAX)

--Creación de llave de cifrado simétrica
ALTER TABLE CustomerData.dbo.CustomerInfo
ADD BankACCNumber_encrypt varbinary(MAX)

--Verificación llaves del sistema
ALTER TABLE CustomerData.dbo.CustomerInfo
ADD BankACCNumber_encrypt varbinary(MAX)

--Se agrega campo para albergar datos cifrados
ALTER TABLE CustomerData.dbo.CustomerInfo
ADD BankACCNumber_encrypt varbinary(MAX)

--Se abre la llave de cifrado
OPEN SYMMETRIC KEY SymKey_test
        DECRYPTION BY CERTIFICATE Certificate_test;

--Ciframos datos en la columna 
CLOSE SYMMETRIC KEY SymKey_test;
            GO

--Cerrar llave de cifrado
CLOSE SYMMETRIC KEY SymKey_test;
            GO

--Consultar datos
select * from CustomerData.dbo.CustomerInfo


--Eliminar columna con información sin cifrar
ALTER TABLE CustomerData.dbo.CustomerInfo DROP COLUMN BankACCNumber;
GO

--Abrir llave
OPEN SYMMETRIC KEY SymKey_test
        DECRYPTION BY CERTIFICATE Certificate_test;

--Decifrar datos
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
            CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
            FROM CustomerData.dbo.CustomerInfo;

--Crear un usuario de prueba
USE [master]
GO
CREATE LOGIN [TestColEncrypt] WITH PASSWORD=N'CursoSql2022', DEFAULT_DATABASE=[CustomerData], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [CustomerData]
GO
CREATE USER [TestColEncrypt] FOR LOGIN [TestColEncrypt]
GO
USE [CustomerData]
GO
ALTER ROLE [db_datareader] ADD MEMBER [TestColEncrypt]
GO


--Conectarse a SSMS usando el usuario creado para el ejercicio
OPEN SYMMETRIC KEY SymKey_test
DECRYPTION BY CERTIFICATE Certificate_test;
    
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
FROM CustomerData.dbo.CustomerInfo;

--Cambiar a usuario admin
OPEN SYMMETRIC KEY SymKey_test
DECRYPTION BY CERTIFICATE Certificate_test;
    
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
FROM CustomerData.dbo.CustomerInfo;

--Regresar a conexión de prueba
OPEN SYMMETRIC KEY SymKey_test
DECRYPTION BY CERTIFICATE Certificate_test;
    
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
FROM CustomerData.dbo.CustomerInfo;