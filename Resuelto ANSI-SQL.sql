--TODAS las resoluciones son sin usar subquerys en el From - Restagno las prohibe
-- No asi los otros profesores. Con subquerys, se facilita la cosa

--1.	Mostrar el código, razón social de todos los clientes (entidades donde el tipo_entidad.c_entidad = ‘CLIENTE’) 
--cuyo límite de crédito sea mayor o igual a $ 1000 ordenado por código de cliente.

select 
E.c_entidad, E.nombre
from ENTIDAD E
INNER JOIN TIPO_ENTIDAD TE on E.id_tipo_entidad = TE.id_tipo_entidad
where TE.d_entidad = 'CLIENTE' and E.limite_credito >= 1000
order by E.c_entidad asc


-- 2.	Mostrar el código, detalle de todos los productos vendidos en el año 2009 ordenados por cantidad vendida.

select
E.c_elemento, E.d_elemento, Vendidos = SUM(RD.Cantidad) 
from PRODUCTO P
INNER JOIN ELEMENTO E on P.id_elemento = E.id_elemento
inner join RENGLON_DOCUMENTO RD on E.id_elemento = RD.id_elemento
INNER JOIN DOCUMENTO D on RD.id_documento = D.id_documento
INNER JOIN TIPO_DOCUMENTO TD on D.id_tipo_documento = TD.id_tipo_documento
--Se comieron el tipo factura, asique no va a devolver nada
where TD.d_tipo_documento = 'Factura' and D.fecha >= '2009-01-01' and D.fecha < '2010-01-01'
--No hay nada de 2009... :facepalm:
group by E.id_elemento, E.c_elemento, E.d_elemento

--3.	Realizar una consulta que muestre código de producto, nombre de producto y el stock total, 
--sin importar en que deposito se encuentre, los datos deben ser ordenados por nombre del artículo de menor a mayor.

--El modelo tiene mas de una linea de stock por producto por iddeposito (wtf? modelo muy incoherente)

--select s.id_elemento 
--from STOCK s inner join DEPOSITO d on d.id_deposito = s.id_deposito
--group by s.id_elemento, s.id_deposito
--having count(*) > 1

--El profesor Restagno, en mi caso, dijo que tomemos que hay una linea de stock nomas por producto por deposito.
--Tener en cuenta esto para las siguientes consultas
--En ese caso, la consulta resulta asi

Select			
E.c_elemento, E.d_elemento, 
		--Es cantidad hijo de puta !!!!
stock = ISNULL(Sum(S.canitdad), 0) --Siendo estrictos, ISNULL es T-SQl; deberia usarse COALESCE que es ANSI
FROM PRODUCTO P
INNER JOIN ELEMENTO E on E.id_elemento = P.id_elemento
LEFT JOIN STOCK S on E.id_elemento = S.id_elemento
group by E.id_elemento, E.c_elemento, E.d_elemento
order by E.d_elemento asc

--4.	Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de artículos que lo componen. 
--	Mostrar solo aquellos artículos para los cuales el stock promedio por depósito sea mayor a 100.

SELECT 
E.id_elemento, E.c_elemento, E.d_elemento, COUNT(distinct C.id_elemento_composicion)	--Tomamos Cantidad distinta de elementos, y no cantidad total de elemenos
FROM PRODUCTO P															--En ese caso, hacer sum(c.cantidad)
INNER JOIN ELEMENTO E ON P.id_elemento = E.id_elemento
INNER JOIN COMPOSICION C on P.id_elemento = C.id_elemento_composicion
INNER JOIN STOCK S on P.id_elemento = S.id_elemento
GROUP BY E.id_elemento, E.c_elemento, E.d_elemento
HAVING SUM(S.CANITDAD) > (Select AVG(S1.canitdad) FROM PRODUCTO P1
							INNER JOIN STOCK S1 on P1.id_elemento = S1.id_elemento and P1.id_elemento = E.id_elemento)
							
--5.	Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de stock que se realizaron 
-- para ese artículo en el año 2009 (egresan los productos que fueron vendidos). 
-- Mostrar solo aquellos que hayan tenido más egresos que en el 2008.


SELECT
E.c_elemento, E.d_elemento, Egresos  = SUM(RD.Cantidad)
FROM PRODUCTO P
INNER JOIN ELEMENTO E on P.id_elemento = E.id_elemento
INNER JOIN RENGLON_DOCUMENTO RD on E.id_elemento = RD.id_elemento
INNER JOIN DOCUMENTO D on RD.id_documento = D.id_documento
INNER JOIN TIPO_DOCUMENTO TD on D.id_tipo_documento = TD.id_tipo_documento AND TD.d_tipo_documento = 'Factura' --Recordar lo de la factura
WHERE D.fecha >= '2009-01-01' and D.fecha < '2010-01-01'
group by E.id_elemento, E.c_elemento, E.d_elemento
HAVING SUM(RD.Cantidad) > (
							Select  SUM(RD2.cantidad) from PRODUCTO P1 
									INNER JOIN RENGLON_DOCUMENTO RD2 on P1.id_elemento = RD2.id_elemento and P1.id_elemento = E.id_elemento
									INNER JOIN DOCUMENTO D2 on RD2.id_documento = D2.id_documento 
									INNER JOIN TIPO_DOCUMENTO TD2 on D2.id_tipo_documento = TD2.id_tipo_documento and TD2.d_tipo_documento = 'CI Chubut' 
									where D2.fecha >= '2008-01-01' and D2.fecha < '2009-01-01'
									group by P1.id_elemento
						   ) --De nuevo, no ventas de 2009, menos de 2008
						   
						   
						   
						   
-- 6.	Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese rubro y stock total 
-- de ese rubro de artículos. 
-- Solo tener en cuenta aquellos artículos que tengan un stock mayor al del artículo 1 en el depósito 1.

--Dice mayor, si no tiene articulos no va a salir, incluso aunque el articulo no tenga stock, porque 0 = 0
-- asique usamos joins
select 
R.c_rubro, R.d_rubro, CantidadArticulos = COUNT(distinct E.Id_Elemento),StockTotal = SUM(S.Canitdad)
from RUBRO R
INNER JOIN SUBRUBRO Sub on R.id_rubro = Sub.id_rubro
INNER JOIN ELEMENTO E on E.id_subrubro = Sub.id_subrubro 
						and E.id_elemento in(
											select E1.id_elemento from ELEMENTO E1 inner join STOCK S1 on E1.id_elemento = S1.id_elemento
											group by E1.id_elemento having SUM(s1.Canitdad) > (Select SUM(canitdad) from STOCK where id_deposito = 1 and id_elemento = 1)
											)
INNER JOIN STOCK S on E.id_elemento = S.id_elemento
group by R.id_rubro, R.c_rubro, R.d_rubro


--7.	Generar una consulta que muestre para cada productos código, detalle, mayor precio, menor precio y % de la diferencia de precios 
--(respecto del menor Ej.: menor precio = 10, mayor precio =12   => mostrar 20 %). Mostrar solo aquellos artículos que posean stock.

--No aclara que precio es, lo unico que podemos suponer es que es.. el de venta
-- Consideraremos el precio_unitario_sin_impuestos para todos los comprobantes


select 
E.c_elemento, E.d_elemento, 
MayorPrecio = MAX(Rd.precio_unitario_sin_impuestos),
MenorPrecio = MIN(Rd.precio_unitario_sin_impuestos),
porcentaje = ROund((MAX(Rd.precio_unitario_sin_impuestos) - MIN(Rd.precio_unitario_sin_impuestos)) * 100 / MAX(Rd.precio_unitario_sin_impuestos), 2) 
from PRODUCTO P 
inner join ELEMENTO E on P.id_elemento = E.id_elemento
inner join RENGLON_DOCUMENTO RD on E.id_elemento = RD.id_elemento
where P.id_elemento in (	
						select P1.id_elemento from  PRODUCTO P1 inner join STOCK S on P1.id_elemento = S.id_elemento
						group by P1.id_elemento having ISNULL(Sum(S.canitdad), 0) > 0
						)
and precio_unitario_sin_impuestos > 0 -- Precio 0  - da error sino
group by E.Id_Elemento, E.c_elemento, E.d_elemento



--8.	Mostrar para el o los productos que tengan stock en todos los depósitos, 
--nombre del artículo, stock del depósito que más stock tiene.

Select E1.c_elemento, E1.d_elemento, 
(		SELECT top 1 SUM(Stock.Canitdad) from STOCK inner join DEPOSITO on STOCK.id_deposito = DEPOSITO.id_deposito where STOCK.id_elemento = E1.id_elemento 
			group by STOCK.id_deposito order by SUM(Stock.Canitdad) desc
)  as StockDelDepositoQueMasTiene
from PRODUCTO P1 
INNER JOIN ELEMENTO E1 ON P1.id_elemento = E1.id_elemento and P1.id_elemento in
				(select --Por los datos, ningun producto esta en mas de 1 deposito, y son 10.. 
				P.id_elemento
				FROM
				DEPOSITO D
				LEFT JOIN STOCK S on D.id_deposito = S.id_deposito
				LEFT JOIN PRODUCTO P on P.id_elemento = S.id_elemento
				group by P.id_elemento
				having COUNT(distinct D.id_deposito) =  (select COUNT(*) from DEPOSITO))
INNER JOIN STOCK S1 on S1.id_elemento = P1.id_elemento
group by E1.id_elemento, E1.c_elemento, E1.d_elemento


--9.	Mostrar los 10 productos mas vendidos en la historia y 
--también los 10 productos menos vendidos en la historia. 
--Además mostrar de esos productos, quien fue el cliente que mayor compra realizo.

--Los 10 mas vendidos
--Recordar que no existe factura como tipo de documento
Select
E.c_elemento, E.d_elemento, 
Cliente =   (
				Select  top 1 En.id_entidad from PRODUCTO P1 inner join RENGLON_DOCUMENTO RD1 on P1.id_elemento = RD1.id_elemento
				inner join DOCUMENTO D1 on D1.id_documento = RD1.id_documento 
				inner join TIPO_DOCUMENTO TD1 on D1.id_tipo_documento = TD1.id_tipo_documento and TD1.c_tipo_documento = 'Factura'
				inner join ENTIDAD En on D1.id_entidad = En.id_entidad
				inner join TIPO_ENTIDAD Ten on Ten.id_tipo_entidad = En.id_tipo_entidad and Ten.d_entidad = 'CLIENTE'
				where P1.id_elemento = E.id_elemento
				group by P1.id_elemento, En.id_entidad, En.nombre
				order by count(distinct D1.id_documento) desc
			)
from
Producto P 
INNER JOIN ELEMENTO E on P.id_elemento = E.id_elemento
INNER JOIN RENGLON_DOCUMENTO RD on E.id_elemento = RD.id_elemento
INNER JOIN DOCUMENTO D ON RD.id_documento = D.id_documento
where P.id_elemento in
					
					(Select top 10 P2.id_elemento 
					from producto P2
					inner join RENGLON_DOCUMENTO RD2 on P2.id_elemento = RD2.id_elemento
					INNER JOIN DOCUMENTO D2 on RD2.id_documento = D2.id_documento
					INNER JOIN TIPO_DOCUMENTO TD2 on TD2.id_tipo_documento = D2.id_tipo_documento
					where TD2.c_tipo_documento = 'Factura'
					group by P2.id_elemento
					order by SUM(RD2.Cantidad) desc)
group by E.id_elemento, E.c_elemento, E.d_elemento
--Los 10 menos vendidos
UNION ALL
Select
E.c_elemento, E.d_elemento, 
Cliente =   (
				Select top 1   En.id_entidad from PRODUCTO P1 inner join RENGLON_DOCUMENTO RD1 on P1.id_elemento = RD1.id_elemento
				inner join DOCUMENTO D1 on D1.id_documento = RD1.id_documento 
				inner join TIPO_DOCUMENTO TD1 on D1.id_tipo_documento = TD1.id_tipo_documento and TD1.c_tipo_documento = 'Factura'
				inner join ENTIDAD En on D1.id_entidad = En.id_entidad
				inner join TIPO_ENTIDAD Ten on Ten.id_tipo_entidad = En.id_tipo_entidad and Ten.d_entidad = 'CLIENTE'
				where P1.id_elemento = E.id_elemento
				group by P1.id_elemento, En.id_entidad, En.nombre
				order by count(distinct D1.id_documento) desc
			)
from
Producto P 
INNER JOIN ELEMENTO E on P.id_elemento = E.id_elemento
INNER JOIN RENGLON_DOCUMENTO RD on E.id_elemento = RD.id_elemento
INNER JOIN DOCUMENTO D ON RD.id_documento = D.id_documento
where P.id_elemento in
					
					(Select top 10 P2.id_elemento 
					from producto P2
					inner join RENGLON_DOCUMENTO RD2 on P2.id_elemento = RD2.id_elemento
					INNER JOIN DOCUMENTO D2 on RD2.id_documento = D2.id_documento
					INNER JOIN TIPO_DOCUMENTO TD2 on TD2.id_tipo_documento = D2.id_tipo_documento
					where TD2.c_tipo_documento = 'Factura'
					group by P2.id_elemento
					order by SUM(RD2.Cantidad) asc)
group by E.id_elemento, E.c_elemento, E.d_elemento


--10.	Realizar una consulta que retorne el detalle del rubro, sub-rubro, 
--la cantidad diferentes de productos vendidos y el monto de dichas ventas sin impuestos.  
--Los datos se deberán ordenar de mayor a menor, por el rubro que más productos diferentes vendidos tenga, 
-- solo se deberán mostrar los rubros que tengan una venta superior a 20000 pesos para el año 2009.

--Rubros con ventas > 20.000 --> si viene 0 no lo muestro --> no necesidad de leftjoin

SELECT 
R.d_rubro, Sub.d_subrubro,
CantidadProductosDistintosVendidos = count(distinct rd.id_elemento),
Ventas = sum(RD.cantidad)
FROM RUBRO R
INNER JOIN SUBRUBRO Sub on R.id_rubro = Sub.id_rubro
INNER JOIN ELEMENTO E on E.id_subrubro = Sub.id_subrubro
INNER JOIN PRODUCTO P on P.id_elemento = E.id_elemento
INNER JOIN RENGLON_DOCUMENTO RD on RD.id_elemento = P.id_elemento
INNER JOIN DOCUMENTO D on D.id_documento = RD.id_documento
INNER JOIN TIPO_DOCUMENTO TD on TD.id_tipo_documento = D.id_tipo_documento
WHERE	TD.d_tipo_documento = 'Factura' --Trae 0 porque no existe el tipo Factura
		AND D.fecha >= '2009-01-01' and D.fecha < '2010-01-01' --Y no hay facturas del 2009
group by R.id_rubro, R.d_rubro, Sub.id_subrubro, Sub.d_subrubro
having sum(RD.cantidad) > 20000


--11.	Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe promedio pagado por el producto, 
--		cantidad de depósitos en lo cuales hay stock del producto y stock actual del producto en todos los depósitos.  
--		Se deberán mostrar aquellos productos que hayan tenido operaciones en el año 2009 y los datos deberán ordenarse 
--		de mayor a menor por monto vendido del producto.


SELECT 
E.c_elemento, 
ClientesDistintosQueLoCompraron = COUNT(distinct D.id_entidad),
ImportePromedio = AVG(RD.precio_unitario_sin_impuestos),
CantidadDeDepositosConStock = 	ISNULL((Select 
										COUNT(D1.id_deposito)
										from 	STOCK S1 
										LEFT JOIN DEPOSITO D1 on D1.id_deposito = S1.id_deposito
										where S1.id_elemento = E.id_elemento),0), --Asume que hay una linea de stock por deposito por producto, sino utilizar distinct
StockTotal =	isnull((select 
					SUM(s2.canitdad) 
					from STOCK S2
					where S2.id_elemento = E.id_elemento), 0) --Idem anterior respecto del stock
FROM PRODUCTO P
INNER JOIN ELEMENTO E on E.id_elemento = P.id_elemento
INNER JOIN RENGLON_DOCUMENTO RD on RD.id_elemento = E.id_elemento
INNER JOIN DOCUMENTO D on D.id_documento = RD.id_documento
INNER JOIN TIPO_DOCUMENTO TD ON D.id_tipo_documento = TD.id_tipo_documento
WHERE TD.d_tipo_documento = 'Factura' and D.fecha >= '2009-01-01' and D.fecha < '2010-01-01'
group by E.id_elemento, E.c_elemento
order by SUM(RD.precio_unitario_sin_impuestos) desc



--12.	Realizar una consulta que retorne para cada producto propio (no materia prima) que posea composición, 
--		nombre del producto, precio del producto, precio de la sumatoria de los precios por la cantidad de los productos que lo componen.  
--		Solo se deberán mostrar los productos que estén compuestos por más de 2 productos y deben ser ordenados de mayor a menor 
--		por cantidad de productos que lo componen.

Select 
nombre = E.c_elemento,
Precio = P.precio_unitario,
PrecioSumatoriaPorCantidad =	isnull((select
					SUM(P2.precio_unitario * C2.cantidad)
					FROM 
					COMPOSICION C2
					INNER JOIN PRODUCTO P2 on C2.id_elemento_componente = P2.id_elemento
					WHERE C2.id_elemento_composicion = E.id_elemento), 0)
from ELEMENTO E 
INNER JOIN PRODUCTO P on E.id_elemento = P.id_elemento
INNER JOIN COMPOSICION C on P.id_elemento = C.id_elemento_composicion
WHERE E.id_elemento in(SELECT
						C1.id_elemento_composicion
						FROM PRODUCTO P1
						INNER JOIN COMPOSICION C1 on P1.id_elemento = C1.id_elemento_composicion
						GROUP BY C1.id_elemento_composicion
						having COUNT(*) >= 2)
group by E.id_elemento, E.c_elemento, P.precio_unitario
order by COUNT(*) desc


--13.	Realizar la misma consulta sql para controlar en esta ocasión las tablas de stock, renglón_documento y movimientos 
--		suponiendo que el stock inicial es de 1000 unidades por cada producto. Se desea mostrar aquellos productos donde el stock 
--		informado no sea consistente con los movimientos registrados.

SELECT 
E.c_elemento, E.d_elemento
FROM PRODUCTO P
INNER JOIN ELEMENTO E on P.id_elemento = E.id_elemento
LEFT JOIN RENGLON_DOCUMENTO RD on RD.id_elemento = P.id_elemento --Habla de movimientos, no importa el tipo de documento
group by P.id_elemento, E.c_elemento, E.d_elemento
having SUM(RD.cantidad) + 1000 !=
		(Select 
		isnull(SUM(S1.canitdad), 0)
		FROM PRODUCTO P1
		LEFT JOIN STOCK S1 on P1.id_elemento = S1.id_elemento
		where P1.id_elemento = P.id_elemento)
		
		
		