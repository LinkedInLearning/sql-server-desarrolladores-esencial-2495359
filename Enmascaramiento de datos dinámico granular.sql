-- Creación esquema
CREATE SCHEMA Data;
GO

-- Tabla con columnas enmascaradas
CREATE TABLE Data.Membership(
    MemberID        int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
    FirstName        varchar(100) MASKED WITH (FUNCTION = 'partial(1, "xxxxx", 1)') NULL,
    LastName        varchar(100) NOT NULL,
    Phone            varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
    Email            varchar(100) MASKED WITH (FUNCTION = 'email()') NOT NULL,
    DiscountCode    smallint MASKED WITH (FUNCTION = 'random(1, 100)') NULL
    );

-- Datos de ejemplo
INSERT INTO Data.Membership (FirstName, LastName, Phone, Email, DiscountCode)
VALUES   
('Roberto', 'Tamburello', '555.123.4567', 'RTamburello@contoso.com', 10),  
('Janice', 'Galvin', '555.123.4568', 'JGalvin@contoso.com.co', 5),  
('Shakti', 'Menon', '555.123.4570', 'SMenon@contoso.net', 50),  
('Zheng', 'Mu', '555.123.4569', 'ZMu@contoso.net', 40);  


--Se crea un usuario para probar
CREATE USER MaskingTestUser WITHOUT LOGIN;  

GRANT SELECT ON SCHEMA::Data TO MaskingTestUser;  
  
  -- Se impersona el usuairo
EXECUTE AS USER = 'MaskingTestUser';  

SELECT * FROM Data.Membership;  

REVERT;  



--Se modifica la función de enmascaramiento 
ALTER TABLE Data.Membership  
ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(2,"xxxx",0)');  

--Se verifica el cambio
EXECUTE AS USER = 'MaskingTestUser';  
	SELECT * FROM Data.Membership;  
REVERT; 

--Se cambia de nuevo la función
ALTER TABLE Data.Membership  
ALTER COLUMN LastName varchar(100) MASKED WITH (FUNCTION = 'default()');  

--Se verifica el cambio
EXECUTE AS USER = 'MaskingTestUser';  
	SELECT * FROM Data.Membership;  
REVERT; 


--Otorgar permisos al usuario para que vea sin enmascaramiento
GRANT UNMASK TO MaskingTestUser;  

EXECUTE AS USER = 'MaskingTestUser';  
	SELECT * FROM Data.Membership;  
REVERT;    
  
-- Revoca el permiso
REVOKE UNMASK TO MaskingTestUser;  

--Elimina la máscara
ALTER TABLE Data.Membership   
ALTER COLUMN LastName DROP MASKED;  