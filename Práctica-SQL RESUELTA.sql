/******************/
/*  Práctica SQL  */
/******************/
/* Ejercicio 1: Código y Razón Social de los Clientes con límite de crédito >= 1000 ordenado por código de Cliente */
Select clie_codigo, clie_razon_social
  From facultad.dbo.Cliente
 Where clie_limite_credito >= 1000
Order by clie_codigo

/* Ejercicio 2: Código y detalle de artículos vendidos en el 2012 ordenados por cantidad vendida */
Select P.prod_codigo, P.prod_detalle
  From facultad.dbo.Producto P, facultad.dbo.Item_Factura I, facultad.dbo.Factura F
 Where I.item_producto = P.prod_codigo
   And F.fact_tipo = I.item_tipo
   And F.fact_sucursal = I.item_sucursal
   And F.fact_numero = I.item_numero
   And YEAR(fact_fecha) = 2012
Group By P.prod_codigo, P.prod_detalle
Order By SUM(I.item_cantidad) desc

/* Ejercicio 3: Código, nombre y stock total del producto ordenados por nombre artículo de menor a mayor */
Select P.prod_codigo, P.prod_detalle, SUM(S.stoc_cantidad)
  From facultad.dbo.Producto P, facultad.dbo.STOCK S
 Where P.prod_codigo = S.stoc_producto
Group By P.prod_Codigo, P.prod_detalle
Order By P.prod_detalle asc

/* Ejercicio 4:
   Código, detalle y cantidad de componentes de cada artículo con stock promedio por depósito > 100 */
Select P.prod_codigo, P.prod_detalle, (Select COUNT(C.comp_componente) From facultad.dbo.Composicion C
                                        Where C.comp_producto = P.prod_codigo)
  From facultad.dbo.Producto P, facultad.dbo.STOCK S
 Where S.stoc_producto = P.prod_codigo
Group By P.prod_codigo, P.prod_detalle
Having AVG(S.stoc_cantidad) > 100

/* Ejercicio 5:
   Código, detalle y cantidad de egresos de stock (Ventas) del 2012 de cada artículo con más egresos que en el 2011 */
Select P.prod_codigo, P.prod_detalle, SUM(I.item_cantidad)
  From facultad.dbo.Producto P, facultad.dbo.Item_Factura I, facultad.dbo.Factura F
 Where P.prod_codigo = I.item_producto
   And F.fact_tipo = I.item_tipo
   And F.fact_numero = I.item_numero
   And F.fact_sucursal = I.item_sucursal
   And YEAR(F.fact_fecha) = 2012
Group By P.prod_codigo, P.prod_detalle
HAVING SUM(I.item_cantidad) > (Select SUM(I2.item_cantidad)
                                  from facultad.dbo.Item_Factura I2, facultad.dbo.Factura F2
                                 Where I2.item_tipo = F2.fact_tipo
                                   And I2.item_numero = F2.fact_numero
                                   And I2.item_sucursal = F2.fact_sucursal
                                   And I2.item_producto = P.prod_codigo
                                   And YEAR(F2.fact_fecha) = 2011)

/* Ejercicio 6:
   Código, detalle, cantidad de artículos y stock total de cada rubro de artículos, considerando sólo aquellos
   artículos con stock mayor al del artículo '00000000' en el depósito '00' */
Select R.rubr_id, R.rubr_detalle, COUNT(P.prod_codigo), SUM(S.stoc_cantidad)
  From facultad.dbo.Rubro R, facultad.dbo.Producto P, facultad.dbo.STOCK S
 Where P.prod_rubro = R.rubr_id
   And S.stoc_producto = P.prod_codigo
Group By R.rubr_id, R.rubr_detalle
Having SUM(S.stoc_cantidad) > (Select sum(S2.stoc_cantidad)
                                 from facultad.dbo.STOCK S2
                                Where S2.stoc_producto = '00000000'
                                  and S2.stoc_deposito = '00')

/* Ejercicio 7:
   Código, Detalle, Mayor Precio, Menor Precio y % de la diferencia de precios de todos los artículos con stock. */
Select P.prod_codigo, P.prod_detalle, MAX(I.item_precio), MIN(I.item_precio),
       ( MAX(I.item_precio) - MIN(I.item_precio) ) / MIN(I.item_precio) * 100
  From facultad.dbo.Producto P, facultad.dbo.Item_Factura I, facultad.dbo.STOCK S
 Where P.prod_codigo = I.item_producto and S.stoc_producto = P.prod_codigo
Group By P.prod_codigo, P.prod_detalle
Having SUM(S.stoc_cantidad) > 0

/* Ejercicio 8:
   Nombre del artículo y nombre del depósito con mayor stock sólo de los artículos con stock en todos los depósitos */
Select P.prod_codigo, P.prod_detalle,
      (select TOP 1 d2.depo_detalle from STOCK s2, DEPOSITO d2
        where s2.stoc_deposito = d2.depo_codigo
          and s2.stoc_cantidad = (Select MAX(stoc_cantidad) from STOCK s3 where s3.stoc_producto = P.prod_codigo))
  From facultad.dbo.Producto P, facultad.dbo.DEPOSITO D
  Where D.depo_codigo not in ('04','06','08','09','10','13','19','20','21','50','51','52','53','54','55','56','57','58','59','60','61')
Group By P.prod_codigo, P.prod_detalle
Having COUNT(D.depo_codigo) = (select COUNT(S.stoc_deposito)
                                 from STOCK S
                                Where S.stoc_producto = P.prod_codigo and S.stoc_cantidad > 0)

Select P.prod_codigo, P.prod_detalle, D.depo_codigo
  From facultad.dbo.Producto P, facultad.dbo.DEPOSITO D
  Where depo_codigo not in ('04','06','08','09','10','13','19','20','21','50','51','52','53','54','55','56','57','58','59','60','61')
order by P.prod_codigo, D.depo_codigo
--14 articulos con stock en la mayor cantidad de depositos (12)
--00,02,03,05,07,11,14,15,16,17,18,99
--Depositos sin stock de ningun articulo
select * from DEPOSITO where not exists (select 1 from STOCK where stoc_deposito = depo_codigo and stoc_cantidad > 0)
--'06','08','09','10','13','19','20','21','50','51','52','53','54','55','56','57','58','59','60','61'
--Deposito problematico = 04

/* Ejercicio 9:
   Código del jefe, Código del empleado de ese jefe, nombre del empleado y cantidad de depósitos asignados */
Select J.empl_codigo, E.empl_codigo, E.empl_nombre, COUNT( distinct DJ.depo_codigo) as DepoJefe, COUNT(distinct DE.depo_codigo) as DepoEmpleado
  From facultad.dbo.Empleado E, facultad.dbo.Empleado J, facultad.dbo.DEPOSITO DJ, facultad.dbo.DEPOSITO DE
 Where E.empl_jefe = J.empl_codigo
   And DJ.depo_encargado = J.empl_codigo
   And DE.depo_encargado = E.empl_codigo
Group By J.empl_codigo, E.empl_codigo, E.empl_nombre

/* Ejercicio 10:
   Mostrar los 10 productos más vendidos y los 10 menos vendidos y quién fue el cliente que mayor compras realizó del producto */
Select P.prod_codigo, P.prod_detalle, (Select TOP 1 f.fact_cliente from Item_Factura i, Factura f
                                        where i.item_tipo = f.fact_tipo and i.item_numero = f.fact_numero
                                          and i.item_sucursal = f.fact_sucursal
                                          and i.item_producto = P.prod_codigo
                                        group by f.fact_cliente order by SUM(i.item_cantidad) desc) as Cliente
From facultad.dbo.Producto P
Where P.prod_codigo IN (Select TOP 10 item_producto from Item_Factura group by item_producto Order by SUM(item_cantidad) asc)
   OR P.prod_codigo IN (Select TOP 10 item_producto from Item_Factura group by item_producto Order by SUM(item_cantidad) desc)
--UNION no puede tener Order By en cada consulta, sólo una al final...

/* Ejercicio 11: Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
   productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán ordenar de mayor 
   a menor, por la familia que más productos diferentes vendidos tenga, solo se deberán mostrar las familias
   que tengan una venta superior a 20000 pesos para el año 2012. */
Select F.fami_detalle, COUNT(distinct P.prod_codigo), SUM(I.item_cantidad * I.item_precio)
  From facultad.dbo.Familia F, facultad.dbo.Producto P, facultad.dbo.Item_Factura I
 Where P.prod_familia = F.fami_id
   And I.item_producto = P.prod_codigo
 Group By F.fami_id, F.fami_detalle
Having (Select SUM(I2.item_cantidad * I2.item_precio)
          From facultad.dbo.Item_Factura I2, facultad.dbo.Factura F2, facultad.dbo.Producto P2
         Where F2.fact_numero = I2.item_numero and F2.fact_tipo = I2.item_tipo and F2.fact_sucursal = I2.item_sucursal
           And I2.item_producto = P2.prod_codigo and P2.prod_familia = F.fami_id
           And YEAR(F2.fact_fecha) = 2012) > 20000
 Order by COUNT(distinct P.prod_codigo) DESC

/* Ejercicio 12: Mostrar nombre de producto, cantidad de clientes distintos que lo compraron,
   importe promedio pagado por el producto, cantidad de depósitos en lo cuales hay
   stock del producto y stock actual del producto en todos los depósitos. Se deberán
   mostrar aquellos productos que hayan tenido operaciones en el año 2012 y los datos
   deberán ordenarse de mayor a menor por monto vendido del producto */
select P.prod_detalle,
       COUNT(Distinct C.clie_codigo) as Cant_Clientes,
       AVG(I.item_precio) as Precio_Promedio,
       COUNT(distinct S.stoc_deposito) as Cantidad_Depositos,
       SUM(S.stoc_cantidad) / COUNT(distinct F.fact_tipo + F.fact_numero + F.fact_sucursal)
from facultad.dbo.Producto P, facultad.dbo.Cliente C, facultad.dbo.Item_Factura I, facultad.dbo.Factura F,
     facultad.dbo.STOCK S
where P.prod_codigo = I.item_producto
  and F.fact_tipo = I.item_tipo and F.fact_numero = I.item_numero and F.fact_sucursal = I.item_sucursal
  and F.fact_cliente = C.clie_codigo
  and S.stoc_producto = P.prod_codigo
Group By P.prod_codigo, P.prod_detalle
Having COUNT(CASE YEAR(F.fact_fecha) WHEN 2012 THEN 1 ELSE 0 END) > 0
Order By SUM(I.item_precio * I.item_cantidad) DESC

select P.prod_detalle,
       COUNT(Distinct C.clie_codigo) as Cant_Clientes,
       AVG(I.item_precio) as Precio_Promedio,
       COUNT(distinct S.stoc_deposito) as Cantidad_Depositos,
       SUM(S.stoc_cantidad) / COUNT(distinct F.fact_tipo + F.fact_numero + F.fact_sucursal)
from facultad.dbo.Producto P, facultad.dbo.Cliente C, facultad.dbo.Item_Factura I, facultad.dbo.Factura F,
     facultad.dbo.STOCK S
where P.prod_codigo = I.item_producto
  and F.fact_tipo = I.item_tipo and F.fact_numero = I.item_numero and F.fact_sucursal = I.item_sucursal
  and F.fact_cliente = C.clie_codigo
  and S.stoc_producto = P.prod_codigo and S.stoc_cantidad > 0
  and exists (select 1 from facultad.dbo.Item_Factura I2, facultad.dbo.Factura F2
               where I2.item_producto = P.prod_codigo
                 and I2.item_tipo = F2.fact_tipo and I2.item_numero = F2.fact_numero and I2.item_sucursal = F.fact_sucursal
                 and YEAR(F2.fact_fecha) = 2012)
Group By P.prod_codigo, P.prod_detalle
Order By SUM(I.item_precio * I.item_cantidad) DESC

/* Ejercicio 13: Realizar una consulta que retorne para cada producto que posea composición,
   nombre del producto, precio del producto, precio de la sumatoria de los precios por
   la cantidad de los productos que lo componen. Solo se deberán mostrar los
   productos que estén compuestos por más de 2 productos y deben ser ordenados de
   mayor a menor por cantidad de productos que lo componen */
Select P.prod_detalle, P.prod_precio, SUM(PC.prod_precio * C.comp_cantidad) as Precio_Compuesto
  From facultad.dbo.Producto P, facultad.dbo.Composicion C, facultad.dbo.Producto PC
 Where P.prod_codigo = C.comp_producto and C.comp_componente = PC.prod_codigo
 Group By P.prod_codigo, P.prod_detalle, P.prod_precio
Having COUNT(distinct PC.prod_codigo) > 2
 Order By COUNT(distinct PC.prod_codigo) DESC


 select p.prod_detalle, p.prod_precio, SUM(p.prod_precio * comp.comp_cantidad)
 from Producto as p
join Composicion as comp on comp.comp_producto = p.prod_codigo
group by p.prod_detalle,p.prod_precio
HAVING COUNT(comp.comp_cantidad) > 2
order by comp.comp_cantidad*

/* Ejercicio 14:
   Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que debe retornar son:
   Código del cliente
   Cantidad de veces que compro en el último año
   Promedio por compra en el último año
   Cantidad de productos diferentes que compro en el último año
   Monto de la mayor compra que realizo en el último año
   Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en el último año.
   No se deberán visualizar NULLs en ninguna columna */

   Select clie_codigo,
02
       (select count(*) from factura where fact_cliente = A.clie_codigo and year(fact_fecha) = 2012),
03
       (select avg(fact_total) from factura where fact_cliente = A.clie_codigo and year(fact_fecha) = 2012),
04
       (select count(distinct(item_producto))
05
        from Factura F join
06
             Item_Factura I on (F.fact_tipo = I.item_tipo and
07
                                F.fact_sucursal = I.item_sucursal and
08
                                F.fact_numero = I.item_numero)
09
        where F.fact_cliente = A.clie_codigo and year(F.fact_fecha) = 2012),
10
        (select top 1 fact_total from factura where fact_cliente = A.clie_codigo and year(fact_fecha) = 2012 order by 1 desc)
11
from Cliente A
12
order by 2 desc


   --------------------------------------------------------------------


Select C.clie_codigo,
       COUNT(distinct F.fact_tipo + F.fact_numero + F.fact_sucursal) as Cant_Compras,
       AVG(F.fact_total) as Promedio_Compras,
       COUNT(distinct I.item_producto) as Cant_Productos_Diferentes,
       MAX(F.fact_total)
  From facultad.dbo.Cliente C, facultad.dbo.Factura F, facultad.dbo.Item_Factura I
 Where C.clie_codigo = F.fact_cliente and YEAR(F.fact_fecha) = 2012
   and I.item_tipo = F.fact_tipo and I.item_numero = F.fact_numero and I.item_sucursal = F.fact_sucursal
 Group By C.clie_codigo
 Order By COUNT(distinct F.fact_tipo + F.fact_numero + F.fact_sucursal) ASC
--PROMEDIO = SUMA DE TODOS LOS VALORES DIVIDIDO CANTIDAD DE VALORES

select * from facultad.dbo.Factura F where F.fact_cliente = '03729' and YEAR(F.fact_fecha)=2012
--318.30 = 279.73 (fact 00099579) y 38.57 (fact 00099580)
select SUM(I.item_cantidad * I.item_precio) from facultad.dbo.Factura F, facultad.dbo.Item_Factura I
where F.fact_cliente = '03729' and YEAR(F.fact_fecha)=2012
and I.item_numero = F.fact_numero and I.item_tipo = F.fact_tipo and I.item_sucursal = F.fact_sucursal

/*Select clie_codigo,
02
       (select count(*) from factura where fact_cliente = A.clie_codigo and year(fact_fecha) = 2012),
03
       (select avg(fact_total) from factura where fact_cliente = A.clie_codigo and year(fact_fecha) = 2012),
04
       (select count(distinct(item_producto))
05
        from Factura F join
06
             Item_Factura I on (F.fact_tipo = I.item_tipo and
07
                                F.fact_sucursal = I.item_sucursal and
08
                                F.fact_numero = I.item_numero)
09
        where F.fact_cliente = A.clie_codigo and year(F.fact_fecha) = 2012),
10
        (select top 1 fact_total from factura where fact_cliente = A.clie_codigo and year(fact_fecha) = 2012 order by 1 desc)
11
from Cliente A
12
order by 2 desc
*/

/* Ejercicio 15: Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
   (en la misma factura) más de 500 veces. El resultado debe mostrar el código y descripción de cada uno
   de los productos y la cantidad de veces que fueron vendidos juntos.
   El resultado debe estar ordenado por la cantidad de veces que se vendieron juntos dichos productos.
   Los distintos pares no deben retornarse más de una vez.
   Ejemplo de lo que retornaría la consulta:
   PROD1 DETALLE1          PROD2 DETALLE2              VECES
   1731  MARLBORO KS       1718  PHILIPS MORRIS KS       507
   1718  PHILIPS MORRIS KS 1705  PHILIPS MORRIS BOX 10   562 */

   select I1.item_producto, P1.prod_detalle, I2.item_producto, P2.prod_detalle, count(*)
02
from Item_Factura I1                                             join
03
     Item_Factura I2 on (I1.item_numero   = I2.item_numero   AND
04
                         I1.item_sucursal = I2.item_sucursal AND
05
                         I1.item_tipo     = I2.item_tipo)        join
06
     Producto P1 on (P1.prod_codigo = I1.item_producto)          join
07
     Producto P2 on (P2.prod_codigo = I2.item_producto)
08
where (I1.item_producto < I2.item_producto) --and count(*) > 500
09
group by I1.item_producto, P1.prod_detalle, I2.item_producto, P2.prod_detalle
10
order by 1, 2



--HECHO EN CLASE

/* Ejercicio 16: Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran en la empresa,
   se pide una consulta SQL que retorne aquellos clientes cuyas ventas son inferiores a 1/3 del promedio de ventas 
   del/los producto/s que más se vendieron en el 2012.
   Además mostrar
   1. Nombre del Cliente
   2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
   3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
      mostrar solamente el de menor código) para ese cliente.
   Aclaraciones:
   La composición es de 2 niveles, es decir, un producto compuesto solo se compone
   de productos no compuestos.
   Los clientes deben ser ordenados por código de provincia ascendente */

--HECHO EN CLASE

select C.clie_codigo                                                as 'Cliente',
02
       C.clie_razon_social                                          as 'Razón Social',
03
       isnull((select sum(IF1.item_cantidad)
04
        from Item_Factura IF1 join
05
             Factura F1 on IF1.item_sucursal = F1.fact_sucursal and
06
                           IF1.item_tipo     = F1.fact_tipo     and
07
                           IF1.item_numero   = F1.fact_numero
08
        where F1.fact_cliente = C.clie_codigo and
09
              year(F1.fact_fecha) = 2012),0)                        as 'U Vendidas 2012',
10
       isnull((select top 1 IF2.item_producto
11
        from Item_Factura IF2 join
12
              Factura F2 on IF2.item_sucursal = F2.fact_sucursal and
13
                            IF2.item_tipo     = F2.fact_tipo     and
14
                            IF2.item_numero   = F2.fact_numero
15
        where F2.fact_cliente = C.clie_codigo and
16
              year(F2.fact_fecha) = 2012
17
        group by IF2.item_producto
18
        order by sum(IF2.item_cantidad*IF2.item_precio) desc, IF2.item_producto),0) as 'P Mayor Venta 2012'
19
from  Cliente C
20
where (select sum(F3.fact_total)
21
       from Factura F3
22
       where F3.fact_cliente = C.clie_codigo)
23
       <
24
       (0.33 * (select avg(IF2.item_precio * IF2.item_cantidad)
25
                from Item_Factura IF2 join
26
                     Factura F2 on (IF2.item_numero   = F2.fact_numero   AND
27
                                    IF2.item_sucursal = F2.fact_sucursal AND
28
                                    IF2.item_tipo     = F2.fact_tipo)
29
                where year(F2.fact_fecha) = 2012))
30
group by C.clie_codigo, C.clie_razon_social
31
order by 1


/* Ejercicio 17: Escriba una consulta que retorne una estadística de ventas por año y mes para cada producto.
   La consulta debe retornar:
   PERIODO: Año y mes de la estadística con el formato YYYYMM
   PROD: Código de producto
   DETALLE: Detalle del producto
   CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
   VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo pero del año anterior
   CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el periodo
   La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada por periodo y código de producto. */
Select YEAR(F.fact_fecha) * 100 + MONTH(F.fact_fecha) as Periodo, P.prod_codigo, P.prod_detalle,
       SUM(I.item_cantidad) as Cantidad_Vendida,
       SUM(ISNULL(I2.item_cantidad,0)) as Ventas_Año_Ant,
       COUNT(distinct F.fact_numero + F.fact_sucursal + F.fact_tipo) as Cantidad_Facturas
From facultad.dbo.Factura F, facultad.dbo.Producto P, facultad.dbo.Item_Factura I
LEFT OUTER JOIN facultad.dbo.Item_Factura I2
                ON I2.item_producto = I.item_producto
                and (Select YEAR(F2.fact_fecha) * 100 + MONTH(F2.fact_fecha)
                       From facultad.dbo.Factura F2
                      Where F2.fact_tipo = I2.item_tipo
                        and F2.fact_numero = I2.item_numero
                        and F2.fact_sucursal = I2.item_sucursal)
                  = (Select YEAR(F3.fact_fecha) * 100 + MONTH(F3.fact_fecha)
                       From facultad.dbo.Factura F3 Where F3.fact_numero = I.item_numero
                                                      and F3.fact_sucursal = I.item_sucursal
                                                      and F3.fact_tipo = I.item_tipo) - 100
Where P.prod_codigo = I.item_producto and P.prod_codigo = '00010200'
  and I.item_numero = F.fact_numero and I.item_tipo = F.fact_tipo and I.item_sucursal = F.fact_sucursal
Group By YEAR(F.fact_fecha) * 100 + MONTH(F.fact_fecha), P.prod_codigo, P.prod_detalle
Order By YEAR(F.fact_fecha) * 100 + MONTH(F.fact_fecha), P.prod_codigo
--producto 00010200 PERIODO 201207

select SUM(I.item_cantidad) from facultad.dbo.Item_Factura I , facultad.dbo.Factura F
where item_producto = '00010200' and YEAR(F.fact_fecha) = 2012 and MONTH(F.fact_fecha)=7
and I.item_numero = F.fact_numero and I.item_tipo = F.fact_tipo and I.item_sucursal = F.fact_sucursal--90
select SUM(I.item_cantidad) from facultad.dbo.Item_Factura I , facultad.dbo.Factura F
where item_producto = '00010200' and YEAR(F.fact_fecha) = 2011 and MONTH(F.fact_fecha)=7
and I.item_numero = F.fact_numero and I.item_tipo = F.fact_tipo and I.item_sucursal = F.fact_sucursal--1

select SUM(isnull(item_cantidad,0)) from facultad.dbo.Item_Factura where 1=2














-----------------------------
select isnull(year(F1.fact_fecha)*100+(month(F1.fact_fecha)),'999999')            as Periodo,
02
       P.prod_codigo                                                              as Producto,
03
       P.prod_detalle                                                             as Detalle,     
04
       isnull(sum(IF1.item_cantidad * IF1.item_precio),0)                         as Cantidad_Vendida,
05
       isnull((select sum(IF2.item_cantidad * IF2.item_precio)
06
               from Factura F2 join
07
                    Item_Factura IF2 on (IF2.item_numero   = F2.fact_numero   and
08
                                         IF2.item_sucursal = F2.fact_sucursal and
09
                                         IF2.item_tipo     = F2.fact_tipo)
10
                where year(F2.fact_fecha)  = year(F1.fact_fecha)-1 and
11
                      month(F2.fact_fecha) = month(F1.fact_fecha)  and
12
                      IF2.item_producto    = P.prod_codigo),0)                     as Ventas_Año_Anterior,
13
       count(IF1.item_producto)                                                    as Cant_Facturas
14
from Producto     P                                                left join
15
     Item_Factura IF1 on (P.prod_codigo = IF1.item_producto)       left join
16
     Factura      F1  on (IF1.item_numero  = F1.fact_numero    and
17
                          IF1.item_sucursal = F1.fact_sucursal and
18
                          IF1.item_tipo     = F1.fact_tipo       )
19
group by year(F1.fact_fecha), month(F1.fact_fecha), P.prod_codigo, P.prod_detalle
20
order by Periodo, P.prod_codigo





/* Ejercicio 18: Escriba una consulta que retorne una estadística de ventas para todos los rubros.
   La consulta debe retornar:
   DETALLE_RUBRO: Detalle del rubro
   VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
   PROD1: Código del producto más vendido de dicho rubro
   PROD2: Código del segundo producto más vendido de dicho rubro
   CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30 días
   La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada por
   cantidad de productos diferentes vendidos del rubro. */
Select R.rubr_detalle, SUM(I.item_cantidad * I.item_precio) as Ventas,
       isnull(P_TOP.prod_codigo,'No hay producto') as Producto_TOP_1,
       isnull(P_TOP2.prod_codigo,'No hay producto') as Producto_TOP_2,
       isnull(C.clie_codigo,'No hay Cliente') as Cliente_TOP
From facultad.dbo.Rubro R, facultad.dbo.Item_Factura I, facultad.dbo.Producto P, facultad.dbo.Producto P_TOP
     LEFT OUTER JOIN facultad.dbo.Cliente C
                  ON C.clie_codigo in (select TOP 1 F1.fact_cliente
                                         From facultad.dbo.Factura F1, facultad.dbo.Item_Factura I1,
                                              facultad.dbo.Producto P1, facultad.dbo.Rubro R1
                                        Where I1.item_producto = P1.prod_codigo
                                          and P1.prod_rubro = R1.rubr_id
                                          and F1.fact_numero = I1.item_numero
                                          and F1.fact_tipo = I1.item_tipo
                                          and F1.fact_sucursal = I1.item_sucursal
                                          and F1.fact_fecha BETWEEN DATEADD(DAY,-30,CONVERT(date,GETDATE()))
                                                                AND CONVERT(date,GETDATE())
                                          and R1.rubr_id = P_TOP.prod_rubro
                                     Group By F1.fact_cliente
                                     Order by SUM(I1.item_cantidad))
     LEFT OUTER JOIN facultad.dbo.Producto P_TOP2
                  ON P_TOP2.prod_codigo in (Select TOP 1 P3.prod_codigo
                                             From facultad.dbo.Producto P3, facultad.dbo.Item_Factura I
                                            Where I.item_producto = P3.prod_codigo and P3.prod_rubro = P_TOP.prod_rubro
                                              And P3.prod_codigo <> P_TOP.prod_codigo
                                            Group By P3.prod_codigo
                                            Order By SUM(I.item_Cantidad))
Where I.item_producto = P.prod_codigo and P.prod_rubro = R.rubr_id
  And P_TOP.prod_codigo in (Select TOP 1 P4.prod_codigo
                              From facultad.dbo.Producto P4, facultad.dbo.Item_Factura I
                             Where I.item_producto = P4.prod_codigo and P4.prod_rubro = R.rubr_id
                          Group By P4.prod_codigo
                          Order By SUM(I.item_Cantidad))
Group By R.rubr_id, R.rubr_detalle, isnull(P_TOP.prod_codigo,'No hay producto'),
         isnull(P_TOP2.prod_codigo,'No hay producto'), isnull(C.clie_codigo,'No hay Cliente')
--Observación: Sólo se listan los rubros con al menos una venta.