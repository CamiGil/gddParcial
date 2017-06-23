/*
1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea
mayor o igual a $ 1000 ordenado por código de cliente.
*/

select	cli.clie_codigo as Codigo,
		cli.clie_razon_social as Razon_Social
from	Cliente cli
where	cli.clie_limite_credito>=1000
order by cli.clie_codigo

/*
2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados
por cantidad vendida.
*/




/*3. Realizar una consulta que muestre código de producto, nombre de producto y el
stock total, sin importar en que deposito se encuentre, los datos deben ser ordenados
por nombre del artículo de menor a mayor.
*/


/*
4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad
de artículos que lo componen. Mostrar solo aquellos artículos para los cuales el
stock promedio por depósito sea mayor a 100.
*/


select  p.prod_codigo,
		p.prod_detalle,
	    COUNT(c.comp_componente)
	
from	Producto p 
		join STOCK s on s.stoc_producto=p.prod_codigo
		join DEPOSITO d on d.depo_codigo = s.stoc_deposito
		left join Composicion c on c.comp_producto=p.prod_codigo
group by p.prod_codigo,p.prod_detalle
having AVG(s.stoc_cantidad)>100
		
		




/*5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos
de stock que se realizaron para ese artículo en el año 2012 (egresan los productos
que fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el
2011.
*/


select	p.prod_codigo,
		p.prod_detalle,
		COUNT( f12.fact_numero+f12.fact_sucursal+f12.fact_tipo )
from	Producto p
		join	Item_Factura itf on itf.item_producto=p.prod_codigo
		left join	Factura f11 on 
						itf.item_numero=f11.fact_numero
						and itf.item_sucursal = f11.fact_sucursal
						and itf.item_tipo = f11.fact_tipo 
						and YEAR(f11.fact_fecha)=2011
		left join	Factura f12 on 
						itf.item_numero=f12.fact_numero 
						and itf.item_sucursal = f12.fact_sucursal
						and itf.item_tipo = f12.fact_tipo
						and YEAR(f12.fact_fecha)=2012
group by p.prod_codigo,p.prod_detalle
having COUNT(f12.fact_numero+f12.fact_sucursal+f12.fact_tipo )>COUNT(f11.fact_numero+f11.fact_sucursal+f11.fact_tipo ) /* no es la primary concatenar la primary*/






/*6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de
ese rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos
artículos que tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.
*/

/*7. Generar una consulta que muestre para cada articulo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio
= 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que
posean stock.
*/




/*
8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.


15-16-17-18

9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.

*/

select  jef.empl_codigo as Jefe,
		emp.empl_codigo as Empleado,
		emp.empl_nombre as Nombre_Empleado,
		(
		select COUNT(*) from DEPOSITO depo where depo.depo_encargado in (emp.empl_codigo,jef.empl_codigo)
		)
from	Empleado Emp
		--join DEPOSITO depo on depo.depo_encargado=emp.empl_codigo
		left 
		join Empleado jef on emp.empl_jefe=jef.empl_codigo



/*
10. Mostrar los 10 productos mas vendidos en la historia y también los 10 productos
menos vendidos en la historia. Además mostrar de esos productos, quien fue el
cliente que mayor compra realizo.
*/

select * from Item_Factura

select	* 
from	Item_Factura itf 
		join	Factura f on 
						itf.item_numero=f.fact_numero
						and itf.item_sucursal = f.fact_sucursal
						and itf.item_tipo = f.fact_tipo 
		join	Cliente cli on cli.clie_codigo=f.fact_cliente
		join	Producto p on p.prod_codigo=itf.item_producto


select prod_detalle,
	(select *
	from Cliente
	join Factura f on clie_domicilio
	
from	Producto
where prod_codigo in (
select	top 10  p.prod_codigo
from	Item_Factura itf
		join Producto p on itf.item_producto=p.prod_codigo
group by p.prod_codigo
order by SUM(item_cantidad) desc
)
or
prod_codigo in (


select	top 10 SUM(item_cantidad), p.prod_detalle 
from	Item_Factura itf
		join Producto p on itf.item_producto=p.prod_codigo
group by p.prod_detalle
order by SUM(item_cantidad) asc
)

/*
Linterna con pilas                                
TANG NARANJA X 35g.                               
PHILIPS MORRIS BOX 10                             
MARLBORO KS                                       
MARLBORO BOX                                      
TANG NARANJA MANGO X 35g.                         
TANG MANZANA X 35g.                               
RHODESIA X 22g. unidad                            
PILAS E 91 u.                                     
Linterna chica con pilas                          




11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos
tenga, solo se deberán mostrar las familias que tengan una venta superior a 20000
pesos para el año 2012.

12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron
importe promedio pagado por el producto, cantidad de depósitos en lo cuales hay
stock del producto y stock actual del producto en todos los depósitos. Se deberán
mostrar aquellos productos que hayan tenido operaciones en el año 2012 y los datos
deberán ordenarse de mayor a menor por monto vendido del producto.

*/


--hacer 10 y 15

-- 13 14 15 16
/*13
Realizar una consulta que retorne para cada producto que posea composición
nombre del producto, precio del producto, precio de la sumatoria de los precios por
la cantidad de los productos que lo componen. Solo se deberán mostrar los
productos que estén compuestos por más de 2 productos y deben ser ordenados de
mayor a menor por cantidad de productos que lo componen.  */

select	pOrig.prod_detalle, 
		pOrig.prod_precio, 
		SUM(pcomp.prod_precio*comp.comp_cantidad)
    
from	Composicion comp
		join Producto pOrig on comp.comp_producto=pOrig.prod_codigo
		join Producto pcomp on comp.comp_componente=pcomp.prod_codigo
group by pOrig.prod_detalle,pOrig.prod_precio
having sum(comp.comp_cantidad)>2
order by SUM(comp.comp_cantidad) desc


/* relacion a preguntar de producto y compuesto */
select	pOrig.prod_detalle, 
		pOrig.prod_precio, 
		pcomp.prod_detalle,
		comp.*
    
from	Composicion comp
		join Producto pOrig on comp.comp_producto=pOrig.prod_codigo
		join Producto pcomp on comp.comp_componente=pcomp.prod_codigo




/*14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos
que debe retornar son:
Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que
compro en el último año.
No se deberán visualizar NULLs en ninguna columna   */


select	cli.clie_codigo,
		isnull(COUNT(distinct f.fact_tipo+f.fact_sucursal+fact_numero),0) as cantidad_Facturas,
		isnull(AVG(f.fact_total+f.fact_total_impuestos),0) as Promedio,
		isnull(MAX(f.fact_total+f.fact_total_impuestos),0) as monto_maximo_factura
		
from	Cliente cli
		left join Factura f on f.fact_cliente=cli.clie_codigo 
							and f.fact_fecha between DATEADD(YEAR,-1,GETDATE()) and GETDATE()
group by cli.clie_codigo
order by isnull(COUNT(distinct f.fact_tipo+f.fact_sucursal+fact_numero),0)


select f.fact_total_impuestos+f.fact_total, * from Factura f where fact_cliente='03342'
and  f.fact_fecha between DATEADD(YEAR,-4,GETDATE()) and GETDATE()

--03342 	103	264.273883	847.04

--select * from Factura


/*15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos
juntos (en la misma factura) más de 500 veces. El resultado debe mostrar el código
y descripción de cada uno de los productos y la cantidad de veces que fueron
vendidos juntos. El resultado debe estar ordenado por la cantidad de veces que se
vendieron juntos dichos productos. Los distintos pares no deben retornarse más de
una vez.
Ejemplo de lo que retornaría la consulta:
PROD1 DETALLE1 PROD2 DETALLE2 VECES
1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2*/

select  itf.item_producto, p1.prod_detalle, itf2.item_producto,p2.prod_detalle,itf.item_cantidad+itf2.item_cantidad
from	Item_Factura itf
		join Producto p1 on p1.prod_codigo=itf.item_producto
		join Item_Factura itf2 on itf2.item_tipo=itf.item_tipo
								and itf2.item_sucursal=itf.item_sucursal
								and itf2.item_numero=itf.item_numero
		join Producto p2 on p2.prod_codigo=itf2.item_producto
where itf.item_cantidad>500 and itf2.item_cantidad>500	
and p1.prod_codigo>p2.prod_codigo	 
--group by itf.item_tipo,itf.item_sucursal,itf.item_numero,itf.item_producto
--having SUM(itf.item_cantidad)>500 and SUM(itf2.item_cantidad)>500 


--select  p1.prod_codigo, p1.prod_detalle, p2.prod_codigo,p2.prod_detalle,sum(itf.item_cantidad)
--from	Item_Factura itf
--		join Producto p1 on p1.prod_codigo=itf.item_producto
--		join Producto p2 on p2.prod_codigo=itf.item_producto

--group by itf.item_tipo,itf.item_sucursal,itf.item_numero,p1.prod_codigo, p1.prod_detalle, p2.prod_codigo,p2.prod_detalle
--having SUM(itf.item_cantidad)>500


select * from Item_Factura where item_numero ='00099418' and item_sucursal='0003' and item_tipo='A'
and item_producto='00010258'

/*
00010395	504.00	A	0003	00092536
00010258	1092.00	A	0003	00099418
00010266	1138.00	A	0003	00099418
*/




/*16. Con el fin de lanzar una nueva campaña comercial para los clientes que menos
compran en la empresa, se pide una consulta SQL que retorne aquellos clientes
cuyas ventas son inferiores a 1/3 del promedio de ventas del/los producto/s que más
se vendieron en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
mostrar solamente el de menor código) para ese cliente.
Aclaraciones:
La composición es de 2 niveles, es decir, un producto compuesto solo se compone
de productos no compuestos.
Los clientes deben ser ordenados por código de provincia ascendente.  */


select cli.clie_razon_social,
		(select MAX()
from	Cliente cli
		join Factura f on f.fact_cliente=cli.clie_codigo 
		join item_factura itf on itf.item_tipo=f.fact_tipo
							and item_sucursal=f.fact_sucursal
							and item_numero=f.fact_numero
		join Producto pOrig on pOrig.prod_codigo=itf.item_producto
		left join Composicion comp on comp.comp_producto=pOrig.prod_codigo
		left join Producto pcomp on comp.comp_componente=pcomp.prod_codigo
--where	cli.



select	* 
from	Cliente cli
		join Factura f on f.fact_cliente=cli.clie_codigo 
where	year(f.fact_fecha)=2012
/*17. Escriba una consulta que retorne una estadística de ventas por año y mes para cada
producto.
La consulta debe retornar:
PERIODO: Año y mes de la estadística con el formato YYYYMM
PROD: Código de producto
DETALLE: Detalle del producto
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del
periodo pero del año anterior
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
periodo
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar
ordenada por periodo y código de producto. */


select  cast(year(f.fact_fecha) as varchar)+  right ('00'+cast(month(f.fact_fecha)as varchar),2) as Periodo,
		p.prod_codigo as Codigo_Producto,
		
		p.prod_detalle as Detalle_producto, 
		SUM(itf.item_cantidad) as Cantidad_Vendida,
		isnull((
			select SUM(ite.item_cantidad)
			from	Item_Factura ite 
					left join Factura ff on 
							ite.item_tipo=ff.fact_tipo
							and ff.fact_sucursal = ite.item_sucursal
							and ff.fact_numero= ite.item_numero
			where cast(year(f.fact_fecha) as varchar)+  right ('00'+cast(month(f.fact_fecha)as varchar),2) 
						= cast(year(ff.fact_fecha)+1 as varchar)+  right ('00'+cast(month(ff.fact_fecha)as varchar),2) 
					and ite.item_producto=p.prod_codigo 
			group by ite.item_producto,
			cast(year(ff.fact_fecha) as varchar)+  right ('00'+cast(month(ff.fact_fecha)as varchar),2)
			),0) as Ventas_Anio_Ant,
			COUNT(distinct f.fact_tipo+f.fact_sucursal+f.fact_numero) as Cantidad_facturas_del_peridodo
from	Producto p
		
		join item_factura itf on itf.item_producto=p.prod_codigo
		
		join Factura f on itf.item_tipo=f.fact_tipo
					and f.fact_sucursal = itf.item_sucursal
					and f.fact_numero= itf.item_numero

group by cast(year(f.fact_fecha) as varchar)+  right ('00'+cast(month(f.fact_fecha)as varchar),2) ,
		p.prod_codigo ,
		p.prod_detalle 
order by 1 , 2





'00001718'

/* 18. Escriba una consulta que retorne una estadística de ventas para todos los rubro */
