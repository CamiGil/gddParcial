--1--

SELECT DISTINCT D.depo_detalle, R.rubr_detalle,
	(CASE WHEN (SELECT COUNT(*)
			FROM PRODUCTO P4
			WHERE P4.prod_codigo IN (SELECT P3.prod_codigo
										FROM PRODUCTO P3
											JOIN Item_Factura ITF2 ON ITF2.item_producto = P3.prod_codigo
										WHERE R.rubr_id = P3.prod_rubro
										GROUP BY P3.prod_codigo
										HAVING SUM(ITF2.ITEM_CANTIDAD) = (SELECT TOP 1 SUM(ITF.ITEM_CANTIDAD)
																			FROM Item_Factura ITF
																				JOIN PRODUCTO P2 ON ITF.item_producto = P2.prod_codigo
																			WHERE R.rubr_id = P2.prod_rubro
																			GROUP BY P2.prod_codigo
																			ORDER BY SUM(ITF.ITEM_CANTIDAD) DESC))) > 1
			THEN 'Mas de un prod exitoso'
			ELSE ISNULL((SELECT P3.prod_codigo
					FROM PRODUCTO P3
						JOIN Item_Factura ITF2 ON ITF2.item_producto = P3.prod_codigo
					WHERE R.rubr_id = P3.prod_rubro
					GROUP BY P3.prod_codigo
					HAVING SUM(ITF2.ITEM_CANTIDAD) = (SELECT TOP 1 SUM(ITF.ITEM_CANTIDAD)
														FROM Item_Factura ITF
															JOIN PRODUCTO P2 ON ITF.item_producto = P2.prod_codigo
														WHERE R.rubr_id = P2.prod_rubro
														GROUP BY P2.prod_codigo
														ORDER BY SUM(ITF.ITEM_CANTIDAD) DESC)),'NINGUNO')
	END) AS 'masExitoso'
FROM DEPOSITO D
	JOIN STOCK S ON S.stoc_deposito = D.depo_codigo
	JOIN PRODUCTO P ON P.prod_codigo = S.stoc_producto
	JOIN RUBRO R ON P.prod_rubro = R.rubr_id
