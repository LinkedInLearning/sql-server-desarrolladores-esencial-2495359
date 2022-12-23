use AdventureWorks2019
GO

--funciones de agregacion
Select	Suma = Sum(Valor),Promedio = AVG(Valor),Minimo = MIN(Valor),Maximo = MAX(Valor)
		,NumeroRegistros = Count(*)
From	(
			Select Valor = convert(int,Value)
			From	openjson('[3,5,2,6,8,2,3,65,78,32,2,4,6,7,2,1,4,6,7,3,32,3,5,4,2,1]')
		) as data

-- funciones de metadatos (datos de los datos)
Select	Tabla = OBJECT_NAME(object_id),Indice = name,Tipo = type_desc
		,[Base de Datos] = Db_Name()
From	sys.indexes

--funciones de cadena
Select	Texto = CONCAT('El usuario ',REPLACE(value,',',' tiene '),' años.')
		,COALESCE(
			'Sigo despues de ' 
			+ 
			LAG(
				substring(value,0,CHARINDEX(',',value))
				,
				1
			) OVER(ORDER BY (SELECT NULL)),'Soy el primero'
		) as OrdenFila
		
From	String_Split('PEDRO,35;SARA,43;MARIA,7;JUAN,14',';')