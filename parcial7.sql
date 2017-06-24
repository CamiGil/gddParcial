-- TEORIA NOTA 4.
-- EJERCICIO 1 -- 
/*
1)
a)El nivel de aisalmiento read commited nunca genera bloqueo 

Falso. Depende de si el Snapshot está activado o no.

b)Quicksort es mas eficiente que heapsort

Verdadero. Porque es más fácil de implementar y consume menos recursos.

2) Desarrolle cuales son los beneficion de una transaccion en un 
Sistema de bases de datos

Al poseer las propiedades de Atomicidad, Consistencia, Aislamiento (Isolation) y Durabilidad (ACID) las transacciones aseguran:
-que las mismas se realizan de manera completa o no se ejecutan. Se ejectan todas las operaciones o ninguna (Atomicidad).
-que las msimas no rompen la integridad de la base de datos (Consistencia).
-que las mismas no se afectan entre sí cuando se ejecutan de manera concurrente (Aislamiento). 
-que si ya fueron aceptadas, no se pueda deshacer aunque se produzcan fallas en el sistema (Persistencia - Durabilidad).
*/

-- Ejercicio 3 -- 
/* Se requiere un analisis profundo respecto a las ventas del 2015,
para lo cual el area de Marketing ha solicitad un reporte cierta
informacion para la toma de decisiones. Dicho reporte deberia 
incluir para los 3 productos mas vendidos y 3 productos menso vendidos 
el nombre del producto, indicar si es simple/compuesto (segun si
el producto consiste en una compisicion) y una leyenda que 
indique "producto exitoso", si corresopnde a los 3 mas vendidos o
"producto a evaluar", si corresopnde a los 3 menos vendidos. 
Mostrar solo aquellos productos que hayan tenido mas de 5 ventas en el 2010 */

USE [GD2015C1]
GO
SELECT P.prod_detalle,
	(CASE WHEN EXISTS(SELECT 1 FROM Composicion c WHERE c.comp_producto = p.prod_codigo)
		THEN 'COMPUESTO'
		ELSE 'SIMPLE'
		END) AS 'comoEs',
	(CASE WHEN P.prod_codigo IN (SELECT TOP 3 P2.prod_codigo
									FROM PRODUCTO P2
									JOIN Item_Factura ITF ON ITF.item_producto = P2.prod_codigo
									JOIN FACTURA F ON F.fact_numero = ITF.item_numero
										AND F.fact_tipo = ITF.item_tipo
										AND F.fact_sucursal = ITF.item_sucursal
									WHERE YEAR(F.fact_fecha) = 2010
									GROUP BY P2.prod_codigo
									HAVING SUM(ITF.item_cantidad) > 5 
									ORDER BY SUM(ITF.item_cantidad) DESC)
	THEN 'EXITOSO'
	ELSE 'REVISAR'
	END) AS 'leyenda'
FROM PRODUCTO P
WHERE (P.prod_codigo IN (SELECT TOP 3 P2.prod_codigo
						FROM PRODUCTO P2
						JOIN Item_Factura ITF ON ITF.item_producto = P2.prod_codigo
						JOIN FACTURA F ON F.fact_numero = ITF.item_numero
							AND F.fact_tipo = ITF.item_tipo
							AND F.fact_sucursal = ITF.item_sucursal
						WHERE YEAR(F.fact_fecha) = 2010
						GROUP BY P2.prod_codigo
						HAVING SUM(ITF.item_cantidad) > 5 
						ORDER BY SUM(ITF.item_cantidad) DESC)
	OR P.prod_codigo IN (SELECT TOP 3 P2.prod_codigo
						FROM PRODUCTO P2
						JOIN Item_Factura ITF ON ITF.item_producto = P2.prod_codigo
						JOIN FACTURA F ON F.fact_numero = ITF.item_numero
							AND F.fact_tipo = ITF.item_tipo
							AND F.fact_sucursal = ITF.item_sucursal
						WHERE YEAR(F.fact_fecha) = 2010
						GROUP BY P2.prod_codigo
						HAVING SUM(ITF.item_cantidad) > 5 
						ORDER BY SUM(ITF.item_cantidad) ASC))
GROUP BY P.prod_CODIGO,P.prod_detalle

-- Ejercicio 4 -- NOTA: 10 (para el FOR)
/*Implementar los objetos necesarios para que cada vez que se 
decida incrementar la comision de un empleado no se permita incrementar
mas de un 5% la comision de aquellos empleados responsables de menos
de 4 depositos*/

-- Usando FOR -- NOTA: 10
USE [GD2015C1]
GO
CREATE TRIGGER tcontrolarcargacomision ON Empleado
	FOR INSERT, UPDATE
AS
BEGIN TRANSACTION
	UPDATE empleado SET empl_comision = 5
		WHERE EXISTS(SELECT 1 FROM Inserted 
						WHERE empl_codigo = empleado.empl_codigo
							and (SELECT COUNT(*) FROM DEPOSITO WHERE depo_encargado = empl_codigo) < 4
							and Empleado.empl_comision > 5)
COMMIT TRANSACTION


-- Usando Instead OF -- SIN NOTA
USE [GD2015C1]
GO
CREATE TRIGGER VERIF_AUMENTOa_COMISION ON Empleado
INSTEAD OF UPDATE
AS 
BEGIN TRANSACTION
declare @empl_codigo as numeric(6)
declare @comisionNueva as decimal(12,2)
declare @comisionVieja as decimal(12,2)
declare @aumento as decimal(12,2)
DECLARE  cEmpl CURSOR FOR 
	SELECT empl_codigo, empl_comision FROM INSERTED;
	OPEN cEmpl
	FETCH NEXT FROM cEmpl
	INTO @empl_codigo, @comisionNueva
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT empl_comision = @comisionVieja FROM Empleado WHERE empl_codigo = @empl_codigo
		SET @aumento = (@comisionNueva - @comisionVieja);
		IF (SELECT COUNT(1) FROM Deposito WHERE depo_encargado = @empl_codigo) < 4
			IF  @aumento < (0.05 * @comisionVieja)
				UPDATE Empleado	SET empl_comision = @comisionNueva
			-- a los que no cumplen no les hago update 
		ELSE  -- Aca entra por los que tienen mas de 4 depositos					
			UPDATE Empleado SET empl_comision = @comisionNueva 
	FETCH NEXT FROM cEmpl INTO @empl_codigo, @comisionNueva
	END
CLOSE cEmpl;
DEALLOCATE cEmpl;	
COMMIT TRANSACTION
