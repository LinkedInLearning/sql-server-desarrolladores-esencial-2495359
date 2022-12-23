use AdventureWorks2019
GO

-- Creacion de tablas Nodo
CREATE TABLE Persona (
  ID INTEGER PRIMARY KEY,
  nombre VARCHAR(100)
) AS NODE;

CREATE TABLE Ciudad (
  ID INTEGER PRIMARY KEY,
  nombre VARCHAR(100),
  departamento VARCHAR(100)
) AS NODE;

-- Creacion tablas de borde.
CREATE TABLE amigoDe AS EDGE;
CREATE TABLE viveEn AS EDGE;

-- Ingresando datos en las tablas nodo
INSERT INTO Persona (ID, nombre)
	VALUES (1, 'Pedro')
		 , (2, 'Julia')
		 , (3, 'Maria')
		 , (4, 'Enrique')
		 , (5, 'Sofia');


INSERT INTO Ciudad (ID, nombre, departamento)
	VALUES (1,'Bogota','Cundinamarca')
		 , (2,'Medellin','Antioquia')
		 , (3,'Barranquilla','Atlantico');

-- Ingresando datos en las tablas de borde,
/* Asociamos en que ciudad vive cada Personaa*/
INSERT INTO viveEn
	VALUES ((SELECT $node_id FROM Persona WHERE ID = 1), (SELECT $node_id FROM Ciudad WHERE ID = 1))
		 , ((SELECT $node_id FROM Persona WHERE ID = 2), (SELECT $node_id FROM Ciudad WHERE ID = 2))
		 , ((SELECT $node_id FROM Persona WHERE ID = 3), (SELECT $node_id FROM Ciudad WHERE ID = 3))
		 , ((SELECT $node_id FROM Persona WHERE ID = 4), (SELECT $node_id FROM Ciudad WHERE ID = 3))
		 , ((SELECT $node_id FROM Persona WHERE ID = 5), (SELECT $node_id FROM Ciudad WHERE ID = 1));


/* Asociamos quienes son amigos en la tabla de borde */
INSERT INTO amigoDe
	VALUES ((SELECT $NODE_ID FROM Persona WHERE ID = 1), (SELECT $NODE_ID FROM Persona WHERE ID = 2))
		 , ((SELECT $NODE_ID FROM Persona WHERE ID = 2), (SELECT $NODE_ID FROM Persona WHERE ID = 3))
		 , ((SELECT $NODE_ID FROM Persona WHERE ID = 3), (SELECT $NODE_ID FROM Persona WHERE ID = 1))
		 , ((SELECT $NODE_ID FROM Persona WHERE ID = 4), (SELECT $NODE_ID FROM Persona WHERE ID = 2))
		 , ((SELECT $NODE_ID FROM Persona WHERE ID = 5), (SELECT $NODE_ID FROM Persona WHERE ID = 4));


-- Find people who like a restaurant in the same city they live in
SELECT Persona.nombre
FROM Persona, viveEn, Ciudad
WHERE MATCH (Persona-(viveEn)->Ciudad)
AND Ciudad.nombre = 'Barranquilla';

-- Buscamos amigos de los amigos "loops back".
SELECT CONCAT(Persona.nombre, '->', Persona2.nombre, '->', Persona3.nombre, '->', Persona4.nombre)
FROM Persona, amigoDe, Persona as Persona2, amigoDe as amigoDeamigo, Persona as Persona3, amigoDe as amigoDeamigoDeamigo, Persona as Persona4
WHERE MATCH (Persona-(amigoDe)->Persona2-(amigoDeamigo)->Persona3-(amigoDeamigoDeamigo)->Persona4)
AND Persona2.nombre != Persona.nombre
AND Persona3.nombre != Persona2.nombre
AND Persona4.nombre != Persona3.nombre
AND Persona.nombre != Persona4.nombre;