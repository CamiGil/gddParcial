--6--
SELECT R.rubr_detalle, R.rubr_id,
	(COUNT(P.prod_codigo)) AS 'CANT PRODUCTOS',
	(SUM(S.stoc_cantidad)) AS 'STOCK'
FROM RUBRO R 
JOIN PRODUCTO P ON P.prod_rubro = R.rubr_id
JOIN STOCK S ON S.stoc_producto = P.prod_codigo
GROUP BY R.rubr_detalle,R.rubr_id
HAVING SUM(S.stoc_cantidad) > (SELECT SUM(S2.stoc_cantidad)
								FROM STOCK S2
								WHERE S2.stoc_producto = '00000000'
									AND S2.stoc_deposito = '00')
ORDER BY R.rubr_detalle

--7--
SELECT DISTINCT ITF.item_producto, P.prod_detalle,
	MAX(ITF.item_precio) AS 'MAYOR',
	MIN(ITF.item_precio) AS 'MENOR',
	((MAX(ITF.item_precio)*100/	MIN(ITF.item_precio))-100) AS 'DIF'
FROM Item_Factura ITF
JOIN PRODUCTO P ON P.prod_codigo = ITF.item_producto
JOIN STOCK S ON S.stoc_producto = ITF.item_producto
GROUP BY ITF.item_producto, P.prod_detalle
HAVING SUM(S.stoc_cantidad)>0
ORDER BY ITF.item_producto

--8--
SELECT P.prod_detalle, S.stoc_deposito, S.stoc_cantidad,
	(SELECT MAX(S2.stoc_cantidad)
	FROM STOCK S2 
	WHERE P.prod_codigo = S2.stoc_producto
	)AS 'MAX'
FROM PRODUCTO P
	JOIN STOCK S ON S.stoc_producto = P.prod_codigo
GROUP BY P.prod_detalle, S.stoc_deposito,S.stoc_cantidad,P.prod_codigo
HAVING (SELECT COUNT(S3.stoc_deposito)
		FROM STOCK S3
		WHERE P.PROD_CODIGO = S3.stoc_producto) = (SELECT COUNT(DISTINCT S.stoc_deposito)
													FROM STOCK S)
ORDER BY P.prod_detalle

--9--

SELECT E.empl_codigo AS 'JEFE', 
	E2.empl_codigo AS 'ESCLAVO', 
	E.empl_apellido+E.empl_nombre AS 'NOMBRE',
	(SELECT COUNT(*)
	FROM DEPARTAMENTO D
	JOIN DEPOSITO DP ON D.depa_zona = DP.depo_zona
	WHERE D.depa_codigo = E.EMPL_DEPARTAMENTO
		OR D.depa_codigo = E2.EMPL_DEPARTAMENTO) AS 'DEPOSITOS'
FROM Empleado E, EMPLEADO E2
WHERE E2.empl_jefe = E.empl_codigo
ORDER BY E.empl_codigo

--10--

SELECT P.PROD_DETALLE, (SELECT TOP 1 F.fact_cliente
						FROM FACTURA F
							JOIN Item_Factura ITF ON F.fact_numero = ITF.item_numero
								AND F.fact_sucursal = ITF.item_sucursal
								AND F.fact_tipo =ITF.item_tipo
						GROUP BY F.fact_cliente
						ORDER BY SUM(ITF.item_cantidad)DESC) AS 'CLIENTE'
FROM PRODUCTO P
WHERE P.prod_codigo IN (SELECT TOP 10 ITF2.item_producto
						FROM ITEM_FACTURA ITF2
						GROUP BY ITF2.item_producto
						ORDER BY SUM(ITF2.item_cantidad) DESC)
					OR P.prod_codigo IN (SELECT TOP 10 ITF3.item_producto
										FROM ITEM_FACTURA ITF3
										GROUP BY ITF3.item_producto
										ORDER BY SUM(ITF3.item_cantidad) ASC)

--11--

SELECT F.fami_detalle, 
	ISNULL(COUNT(DISTINCT ITF.item_producto),0) AS 'PROD VENDIDOS',
	ISNULL(SUM(ITF.item_cantidad*ITF.item_precio),0) AS 'FACTURADO'
FROM FAMILIA F
	JOIN PRODUCTO P ON P.prod_familia = F.fami_id
	JOIN Item_Factura ITF ON P.prod_codigo = ITF.item_producto
	JOIN FACTURA FC ON FC.fact_numero = ITF.item_numero
		AND FC.fact_sucursal = ITF.item_sucursal
		AND FC.fact_tipo =ITF.item_tipo
GROUP BY F.fami_detalle, F.fami_id
HAVING (SELECT SUM(ITF.item_cantidad*ITF.item_precio)
		FROM Item_Factura ITF
			JOIN PRODUCTO P ON P.prod_codigo = ITF.item_producto
			JOIN FACTURA FC ON FC.fact_numero = ITF.item_numero
							AND FC.fact_sucursal = ITF.item_sucursal
							AND FC.fact_tipo =ITF.item_tipo 
		WHERE P.prod_familia = F.fami_id
			AND YEAR(FC.fact_fecha)='2012'
		GROUP BY YEAR(FC.fact_fecha)) > 20000
ORDER BY ISNULL(COUNT(DISTINCT ITF.item_producto),0) DESC

--12--

SELECT P.prod_detalle, AVG(ITF.item_precio) AS 'PROM $',
	COUNT(DISTINCT F.fact_cliente) AS 'CANT CLIENTES',
	COUNT(DISTINCT S.stoc_deposito) AS 'DEPOSITOS',
	SUM(S.stoc_cantidad) AS 'STOCK'
FROM PRODUCTO P
	JOIN Item_Factura ITF ON ITF.item_producto = P.prod_codigo
		JOIN FACTURA F ON F.fact_numero = ITF.item_numero
		AND F.fact_sucursal = ITF.item_sucursal
		AND F.fact_tipo =ITF.item_tipO
	JOIN STOCK S ON S.stoc_producto = P.prod_codigo
WHERE EXISTS(SELECT 1 
			FROM Item_Factura ITF2 
				JOIN FACTURA F2 ON F2.fact_numero = ITF2.item_numero
					AND F2.fact_sucursal = ITF2.item_sucursal
					AND F2.fact_tipo =ITF2.item_tipO
			WHERE YEAR(F2.fact_fecha) = 2012)
GROUP BY P.prod_detallE
ORDER BY SUM(ITF.item_cantidad*ITF.item_precio) DESC
