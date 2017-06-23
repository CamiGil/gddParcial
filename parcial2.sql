-- PARCIAL MODELO EDGARDO 2c 2016 --
/*

1.a) Las funciones de HASH Modulo K siendo K un numero primo no generan demasiadas colisiones

F. El numero primo debe ser menor que los valores que yo voy a tener.
	Es falso porque si uso K = 2 para valores grandes me genera demasiadas colisiones.
	
1.b) Si 2 transacciones tienen isolation level read commited, cuando una va a modificar un dato que fue leido
por la otra, esta debera esperar a que el otro proceso termine.

F. Como la transaccion ya leyo el dato, el update no genera problema en este caso.

2) Explique las ventajas y las desventajas de la utilizacion del algoritmo de Siklossy con respecto a la 
utilizacion de una lista doblemente enlazada.

Desventaja: Aumenta la complejidad computacional, hay más uso del cpu.
Ventaja: Disminuye la complejidad espacial, ocupa menos espacio.

Este algoritmo disminuye la complejidad espacial, ya que en estos casos, emplea un unico puntero para cada
nodo manteniendo la posibilidad de atravesar la lista en ambos sentidos. Utilizando como operandos
los contenidos de los campos puntero de dos nodos, uno puede conocer la direccion de otro a traves 
de una operacion de or exclusivo.


/* Ej 3
Mostrar año, cantidad total de prod distintos vendidos para ese año, monto total facturado para ese año,
cliente que mas compro ese año.
solo mostrar los años donde su facturacion fue > al año anterior */


SELECT YEAR(f.fact_fecha) AS anio,
-- cantidad total de productos vendidos para ese año 
	(SELECT COUNT(distinct itf2.item_producto) FROM Factura f2 
		INNER JOIN Item_Factura itf2 ON itf2.item_numero = f2.fact_numero and itf2.item_tipo = f2.fact_tipo and itf2.item_sucursal = f2.fact_sucursal
		WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
		GROUP BY YEAR(f2.fact_fecha))
		as 'cantProdVendidos',
-- monto total por año
	SUM(f.fact_total) AS 'montoTotal',
-- cliente que mas compro ese año
	(SELECT TOP 1 (c.clie_codigo) FROM Factura f4
		INNER JOIN Cliente c ON c.clie_codigo = f4.fact_cliente
		WHERE YEAR(f4.fact_fecha) = YEAR(f.fact_fecha)
		GROUP BY c.clie_codigo
		ORDER BY sum(f4.fact_total) desc) as 'clienteQueMasCompro'
	FROM Factura f
	GROUP BY YEAR(f.fact_fecha)
-- verifico que su montoTotal sea > al del año anterior
	HAVING SUM(f.fact_total) >
		(SELECT SUM(f6.fact_total) FROM Factura f6 
			WHERE YEAR(f.fact_fecha) = YEAR(DATEADD(YEAR,+1,f6.fact_fecha)) 
			GROUP BY YEAR(f6.fact_fecha))
			
/* 4
Implementar los objetos necesarios para que no se pueda realizar una factura si el precio de venta de
algun articulo (item_precio) es distinto al precio que se encuentra en la tabla producto (prod_precio)*/

CREATE TRIGGER VERIF_PRECIO ON Item_Factura 
INSTEAD OF INSERTED 
AS 
BEGIN TRANSACTION
	INSERT INTO Item_Factura(item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
		SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio 
			FROM INSERTED 
			WHERE EXISTS(SELECT 1 FROM Producto WHERE pro_codigo = item_producto AND prod_precio = item_precio)

	UPDATE Factura SET fact_total = (SELECT SUM(item_precio * item_cantidad) FROM Item_Facura 
										WHERE item_numero = fac_numero and item_sucursal = fact_sucursal and item_tipo = fact_tipo)
		WHERE EXISTS(SELECT 1 FROM INSERTED WHERE item_numero = fac_numero and item_sucursal = fact_sucursal and item_tipo = fact_tipo)
END
