/* 1
Realizar una consulta que muestre año, el producto con composicion mas vendido en el año,
cantidad de productos que componen al mismo, cantidad de facturas en las cuales aparece ese producto,
el cod del cliente que mas compro ese producto, el porcentaje que representa la venta de ese producto 
respecto del total de venta del año.
El resultado debera ser ordenado por el total vendido por año en forma descendente */

SELECT YEAR(f.fact_fecha) as 'año', 
	(SELECT TOP 1 p2.prod_codigo FROM Factura f2
		INNER JOIN Item_Factura i2 ON i2.item_numero = f2.fact_numero AND i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
		INNER JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
		INNER JOIN Composicion c2 ON c2.comp_producto = p2.prod_codigo
		WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
		GROUP BY p2.prod_codigo
		ORDER BY SUM(f2.fact_total) DESC ) as 'prod con comp mas vendido',
	(SELECT COUNT(c3.comp_componente) FROM Composicion c3
		WHERE c3.comp_producto = (SELECT TOP 1 p2.prod_codigo FROM Factura f2
								INNER JOIN Item_Factura i2 ON i2.item_numero = f2.fact_numero AND i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
								INNER JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
								INNER JOIN Composicion c2 ON c2.comp_producto = p2.prod_codigo
								WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
								GROUP BY p2.prod_codigo
								ORDER BY SUM(f2.fact_total) DESC )) AS 'cant componentes',
	(SELECT COUNT(*) FROM Factura f3 
		INNER JOIN Item_Factura i3 ON i3.item_numero = f3.fact_numero AND i3.item_tipo = f3.fact_tipo AND i3.item_sucursal = f3.fact_sucursal
		WHERE YEAR(f3.fact_fecha) = YEAR(f.fact_fecha)  
			AND i3.item_producto = (SELECT TOP 1 p2.prod_codigo FROM Factura f2
								INNER JOIN Item_Factura i2 ON i2.item_numero = f2.fact_numero AND i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
								INNER JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
								INNER JOIN Composicion c2 ON c2.comp_producto = p2.prod_codigo
								WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
								GROUP BY p2.prod_codigo
								ORDER BY SUM(f2.fact_total) DESC )) AS 'cant facturas',
	(SELECT TOP 1 f4.fact_cliente FROM Factura f4
		INNER JOIN Item_Factura i4  ON i4.item_numero = f4.fact_numero AND i4.item_tipo = f4.fact_tipo AND i4.item_sucursal = f4.fact_sucursal
		WHERE YEAR(f4.fact_fecha) = YEAR(f.fact_fecha)  
			AND i4.item_producto = (SELECT TOP 1 p2.prod_codigo FROM Factura f2
								INNER JOIN Item_Factura i2 ON i2.item_numero = f2.fact_numero AND i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
								INNER JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
								INNER JOIN Composicion c2 ON c2.comp_producto = p2.prod_codigo
								WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
								GROUP BY p2.prod_codigo
								ORDER BY SUM(f2.fact_total) DESC )
		GROUP BY f4.fact_cliente
		ORDER BY SUM(f4.fact_total) DESC) AS 'cliente q mas compro esto',
	(SELECT SUM(f5.fact_total) * 100 / (SELECT SUM(f6.fact_total) FROM Factura f6
										WHERE YEAR(f6.fact_fecha) = YEAR(f.fact_fecha)
										GROUP BY YEAR(f6.fact_fecha))
		FROM Factura f5
		INNER JOIN Item_Factura i5 ON i5.item_numero = f5.fact_numero and i5.item_tipo = f5.fact_tipo and i5.item_sucursal = f5.fact_sucursal
		WHERE YEAR(f5.fact_fecha) = YEAR(f.fact_fecha)
			AND i5.item_producto = (SELECT TOP 1 p2.prod_codigo FROM Factura f2
									INNER JOIN Item_Factura i2 ON i2.item_numero = f2.fact_numero AND i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
									INNER JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
									INNER JOIN Composicion c2 ON c2.comp_producto = p2.prod_codigo
									WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
									GROUP BY p2.prod_codigo
									ORDER BY SUM(f2.fact_total) DESC ) 
		GROUP BY  i5.item_producto) AS 'porcentaje'
		FROM Factura f 
		GROUP BY YEAR(f.fact_fecha)
		
/* 2
Completar la tabla
Considerar que los datos deben insertarse en orden de mayor a menor,
o sea, el cliente que mas compro en plata primero y el que menos compro
en plata ultimo, numrando en la columna posicion el orden que ocupa detro del
ranking posicion cod_clie  num_clie  cantidad pre_pro combo nom_prod
orden del cod num cant de precio "Si" - "No" nomb del prod ranking 
facturas compr promedio en func de q mas comprado por este en el año corriente
haya comprobado cliente en el año prod con comp o no corriente
*/
CREATE TABLE Ranking
(
dife_posicion integer,
dife_cliente char(6),
dife_cantidad integer,
dife_precio_promedio decimal(12,2),
dife_combo char(3),
dife_prod_detalle char(50)
)

CREATE FUNCTION compro_combo(@codCliente as char(6))
RETURNS varchar(3)
AS
BEGIN
DECLARE @resultado as varchar(3)
	IF EXISTS(SELECT * FROM Factura f
		INNER JOIN Item_Factura i ON f.fact_numero = i.item_numero AND f.fact_tipo = i.item_tipo AND i.item_sucursal = f.fact_sucursal
		INNER JOIN Composicion c ON c.comp_producto = i.item_producto
		WHERE f.fact_cliente = @codCliente)
			SET @resultado = 'SI'
	ELSE
		SET  @resultado = 'NO'
RETURN @resultado
END


CREATE PROCEDURE generarRanking
AS
BEGIN
INSERT INTO Ranking(dife_posicion, dife_cliente, dife_cantidad, dife_precio_promedio, dife_combo, dife_prod_detalle)
	SELECT	ROW_NUMBER() OVER (ORDER BY SUM(f.fact_total) DESC) AS 'posicion',
	c.clie_codigo AS 'cliente',
	COUNT(f.fact_numero) as 'cantidad facturas',
	SUM(f.fact_total) / COUNT(f.fact_numero) as 'promedio',
	dbo.compro_combo(c.clie_codigo) as 'compro combo',
	(SELECT TOP 1 p.prod_detalle FROM Factura f2
		INNER JOIN Item_Factura i2 ON f2.fact_numero = i2.item_numero AND f2.fact_tipo = i2.item_tipo AND i2.item_sucursal = f2.fact_sucursal
		INNER JOIN Producto p ON p.prod_codigo = i2.item_producto
		WHERE f2.fact_cliente = c.clie_codigo
		GROUP BY p.prod_detalle
		ORDER BY SUM(f2.fact_total) DESC) as 'prod mas comprado'
	FROM Cliente c
	INNER JOIN	Factura f ON f.fact_cliente = c.clie_codigo
	GROUP BY c.clie_codigo
END
