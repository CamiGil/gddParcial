-- TEORIA: NOTA 9
-- EJERCICIO 1 --
-- a) Huffman no es eficiente para compilar un texto escrito en castellano

FALSO. Huffman es eficiente para compilar un texto en español porque le asignará menos bytes a los char que mas se repiten.

-- b) Una FK siempre conviene que este asociada a una tabla Hash

Verdadero. De esta forma la búsqueda será mas rápido aunque hay que tener en cuenta que no
se deben producir colisiones al ejecutar la funcion de hashing

-- Ejercicio 2 --
-- Concepto de load factor en arbol B?

El load factor en el arbol B se utiliza para minimizar la cantidad de splits en el proceso de creacion inicial del arbol.
Representa el porcentaje de llenado de un nodo, puede variar dependiendo del caso:
Conviene que esté mas cerca del 100% si es para tablas con pocas actualizaciones y 
entre 75 y 85% si es para tablas que reciben updates y deletes ademas de selects.

-- EJERCICIO 3 -- NOTA: 8 Estee lo hice yo :D
/*La empresa necesita recuperar las ventas perdidas. Con el fin de lanzar una nueva campaña comercial, se pide
una consulta SQL que retorne aquellos clientes cuyas ventas (considerar elñ fact_total) del año 2012 fueron
inferiores al 25% del promedio de ventas de los productos vendidos entre los años 2011 y 2010.
En base a lo solicitado, se requiere un listado con la siguiente informacion:
1- Razon social cliente
2- Mostrar la leyenda "Cliente recurrente" si dicho cliente rrealizo mas de una compra en el 2012. En caso de 
que haya realizado solo 1 compra, entonces mostrar la leyenda "Una vez".
3- Cantidad de productos totales vendidas en el 2012 para ese cliente.
4- Codigo de producto mayot vendido en el 2012 (en caso de existir mas de 1, mostrar solamente
el de menor codigo) para ese cliente.*/

USE [GD2015C1]
GO
SELECT c.clie_razon_social,
	CASE WHEN (SELECT ISNULL(COUNT(*),0) FROM Factura f2	
					WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = c.clie_codigo  ) > 1 
				THEN 'Cliente recurrente'
		WHEN (SELECT ISNULL(COUNT(*),0) FROM Factura f2	
					WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = c.clie_codigo) = 1
				THEN 'Unica vez'
	END AS 'leyenda',
	(SELECT ISNULL(COUNT(distinct itf3.item_producto),0) FROM Factura f3
		INNER JOIN Item_Factura itf3 ON itf3.item_numero = f3.fact_numero and itf3.item_tipo = f3.fact_tipo and itf3.item_sucursal = f3.fact_sucursal
		WHERE YEAR(f3.fact_fecha) = 2012 AND f3.fact_cliente = c.clie_codigo
		GROUP BY YEAR(f3.fact_fecha))
		as 'cantProdVendidos',
	(SELECT TOP 1 p4.prod_codigo FROM Factura f4
		INNER JOIN Item_Factura i4 ON i4.item_numero = f4.fact_numero AND i4.item_tipo = f4.fact_tipo AND i4.item_sucursal = f4.fact_sucursal
		INNER JOIN Producto p4 ON p4.prod_codigo = i4.item_producto
		WHERE YEAR(f4.fact_fecha) = 2012 AND f4.fact_cliente = c.clie_codigo
		GROUP BY p4.prod_codigo
		ORDER BY SUM(f4.fact_total) DESC ) as 'prod con comp mas vendido'
	FROM Factura f
	INNER JOIN Cliente c ON c.clie_codigo = f.fact_cliente
	GROUP BY c.clie_codigo, c.clie_razon_social
	HAVING (SELECT SUM(f5.fact_total) FROM Factura f5 
				WHERE YEAR(f5.fact_fecha) = 2012 
					AND f5.fact_cliente = c.clie_codigo) < 
			(0.25 * (SELECT SUM(f6.fact_total + f7.fact_total) / (COUNT(f6.fact_numero + f7.fact_numero))
				FROM Factura f6
				INNER JOIN Factura f7 ON f6.fact_numero = f7.fact_numero AND f6.fact_tipo = f7.fact_tipo AND f6.fact_sucursal = f7.fact_sucursal
				WHERE YEAR(f6.fact_fecha) = 2010 AND YEAR(f7.fact_fecha) = 2011))

-- EJERCICIO 4 -- NOTA: 4 (tambien lo hcie yo. a los triggers el 90% de los casos hay que meterles un cursor para aprobar)
/* Implmente el/los objetos necesdarios para obtener en una nueva tabla (Facturacion por mes) los datos correspondientes
a los montos totales de ventas, actualizados a cada momento.
La tabla debe contener: mes, año, cantidad de facturas emitidas, monto total de ventas(incluir los impuestos) y cliente
que mas compro para ese mes y año*/
-- Creo la tabla --
CREATE TABLE Facturacion_Mes
(mes integer, anio char(6), cantFactEmitidas integer, total decimal(12,2), cliente char(6))

-- Este procedure carga la tabla la primera vez --
CREATE PROCEDURE SP_Facturacion
AS
BEGIN
INSERT INTO Facturacion_Mes(mes , anio , cantFactEmitidas , total , cliente)
	SELECT MONTH(f.fact_fecha) AS 'mes',
	YEAR(f.fact_fecha) as 'anio',
	(SELECT ISNULL(COUNT(*),0) FROM Factura f2
		WHERE MONTH(f2.fact_fecha) = MONTH(f.fact_fecha) AND YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)) as 'cantFactEmitidas',
	(SELECT SUM(f3.fact_total + f3.fact_total_impuestos) From Factura f3
		WHERE MONTH(f3.fact_fecha) = MONTH(f.fact_fecha) AND YEAR(f3.fact_fecha) = YEAR(f.fact_fecha)) as 'total',
	(SELECT TOP 1 c.clie_codigo FROM Factura f4
		INNER JOIN Cliente c ON c.clie_codigo = f4.fact_cliente
		WHERE  MONTH(f4.fact_fecha) = MONTH(f.fact_fecha) AND YEAR(f4.fact_fecha) = YEAR(f.fact_fecha)
		GROUP BY c.clie_codigo
		ORDER BY SUM(f4.fact_total) DESC) as 'cliente'
	
	FROM Factura f
END


-- Con el trigger mantengo actualizada la tabla --
CREATE TRIGGER T_Facturacion ON Factura
FOR INSERT, UPDATE
AS
	BEGIN TRANSACTION
	declare @fact_tipo as char(1)
	declare @fact_sucursal as char(4)
	declare @fact_numero as char(8)
	declare @fact_fecha smalldatetime
	declare @fact_total decimal(12,2)
	declare @fact_total_impuestos decimal(12,2)
	declare @fact_cliente as char(6)
	-- Recorro las facturas nuevas o updetedas y recargo la tabla Facturacion_Mes 
	DECLARE  cFact CURSOR FOR 
	SELECT fact_numero, fact_tipo, fact_sucursal, fact_fecha, fact_total, fact_total_impuestos, fact_cliente FROM INSERTED;
	OPEN fFact
	FETCH NEXT FROM cFact
	INTO  @fact_numero, @fact_tipo, @fact_sucursal, @fact_fecha, @fact_total, @fact_total_impuestos, @fact_cliente
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		UPDATE Facturacion_Mes 
			SET cantFactEmitidas = cantFactEmitidas + (SELECT ISNULL(COUNT(*),0) FROM Factura f WHERE f.fact_numero = @fact_numero ANd f.fact_tipo = @fact_tipo and f.fact_sucursal = @fact_sucursal)
			SET total = total + (SELECT SUM(f.fact_total + f.fact_total_impuestos) From Factura f WHERE f.fact_numero = @fact_numero ANd f.fact_tipo = @fact_tipo and f.fact_sucursal = @fact_sucursal)
			SET cliente = (SELECT TOP 1 c.clie_codigo FROM Factura f 
								INNER JOIN Cliente c ON c.clie_codigo = f.fact_cliente
									WHERE f.fact_numero = @fact_numero ANd f.fact_tipo = @fact_tipo and f.fact_sucursal = @fact_sucursal)
			WHERE anio = YEAR(@fact_fecha) AND mes = MONTH(@fact_fecha) 
	FETCH NEXT FROM cFact INTO @fact_numero, @fact_tipo, @fact_sucursal, @fact_fecha, @fact_total, @fact_total_impuestos, @fact_cliente
	END
CLOSE cFact;
DEALLOCATE cFact;	
COMMIT TRANSACTION
