
/*1. Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es menor
al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el % de
ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.*/
/*2. Realizar una función que dado un artículo y una fecha, retorne el stock que existía a
esa fecha*/
/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado en
caso que sea necesario. Se sabe que debería existir un único gerente general (debería
ser el único empleado sin jefe). Si detecta que hay más de un empleado sin jefe
deberá elegir entre ellos el gerente general, el cual será seleccionado por mayor
salario. Si hay más de uno se seleccionara el de mayor antigüedad en la empresa.
Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla de un único
empleado sin jefe (el gerente general) y deberá retornar la cantidad de empleados
que había sin jefe antes de la ejecución.*/
/*4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese empleado
a lo largo del último año. Se deberá retornar el código del vendedor que más vendió
(en monto) a lo largo del último año.*/
/*5. Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
Create table Fact_table
( anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2)
)
Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)*/


/*6. Realizar un procedimiento que si en alguna factura se facturaron componentes que
conforman un combo determinado (o sea que juntos componen otro producto de
mayor nivel), en cuyo caso deberá reemplazar las filas correspondientes a dichos
productos por una sola fila con el producto que componen con la cantidad de dicho
producto que corresponda.*/

select	* 
from	factura f
		join Item_Factura itf on itf.item_tipo=f.fact_tipo
							and fact_sucursal=item_sucursal
							and fact_numero=item_numero


select * from Composicion

select c.* ,p.*
from	Producto p
		join Composicion c on c.comp_producto=prod_codigo
order by comp_componente
/* el componente es el que compone es al reves */

/** recorro por factura **/
--en base a la factura llamo a compuesto que devuelve un compuesto y busco los productos de ese compuesto y la cantidad para reemplazar*/

/* devolver el codigo de un compuesto */

alter FUNCTION  Compuesto ( /* todos los unicos de factura */
    @idfactura int
)
returns char(8)
    BEGIN 
       return( select	MAX(c.comp_componente) 
				from	factura f
				join	Item_Factura itf on itf.item_tipo=f.fact_tipo
							and fact_sucursal=item_sucursal
							and fact_numero=item_numero
				join Producto p on itf.item_producto=p.prod_codigo
				join Composicion c on c.comp_producto=prod_codigo
				/* validar los unicos de parametro*/
				)
    END





/*7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. Debe
insertar una línea por cada artículo con los movimientos de stock realizados entre
esas fechas. La tabla se encuentra creada y vacía.
VENTAS
Código Detalle Cant. Mov. Precio de
Venta
Renglón Ganancia
Código
del
articulo
Detalle
del
articul
o
Cantidad de
movimientos de
ventas (Item
factura)
Precio
promedi
o de
venta
Nro. de línea de
la tabla
Precio de Venta
– Cantidad *
Costo Actual*/



/*8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por cantidad
de sus componentes, se aclara que un producto que compone a otro, también puede
estar compuesto por otros y así sucesivamente, la tabla se debe crear y está formada
por las siguientes columnas: ver pdf
*/
SELECT * FROM Item_Factura

create table DIFERENCIAS
(
Codigo char(8) null,
Detalle char(50) null,
Cantidad decimal(12,2) ,
Precio_Generado decimal(12,2) ,
Precio_Facturado decimal(12,2)
)
EXEC DiferenciasPrecio

CREATE PROCEDURE DiferenciasPrecio
   
AS 
BEGIN


insert into DIFERENCIAS
(codigo,Detalle,Cantidad,PRecio_Generado,Precio_Facturado)
SELECT P.prod_codigo,
		P.prod_detalle,
		DBO.CantidadProducto(P.PROD_CODIGO),
		DBO.Precio_Compuesto(p.prod_codigo),
		(itf.item_cantidad*item_precio)
FROM	Item_Factura ITF
		JOIN Producto P ON ITF.item_producto=P.prod_codigo
		JOIN Composicion C ON C.comp_producto=P.prod_codigo
where (itf.item_cantidad*item_precio)<>
		DBO.Precio_Compuesto(p.prod_codigo)



END
    
GO



drop table DIFERENCIAS

/*9. Hacer un trigger que ante alguna modificación de un ítem de factura de un artículo
con composición realice el movimiento de sus correspondientes componentes.*/

/* para trigger recursive_trigger */
--nettest trigger cantidad de veces que un trigger llama a otro  

sp_configure



drop trigger ActualizoStock
create trigger ActualizoStock
on Item_Factura after  delete, insert,update
as
begin

declare @id_prod char(8) 
declare @stockFactura decimal(12,2)
declare @cantidadProd decimal (12,2)
declare  ProductosAActualizar cursor 
for			select	p.prod_codigo,itf.item_cantidad,c.comp_cantidad
			from	factura f
				join	deleted itf on itf.item_tipo=f.fact_tipo
							and fact_sucursal=item_sucursal
							and fact_numero=item_numero
				join Producto p on itf.item_producto=p.prod_codigo
				join Composicion c on c.comp_producto=prod_codigo
				--join Stock s on s.stoc_producto=p.prod_codigo
open ProductosAActualizar
fetch next  ProductosAActualizar into @id_prod ,@stockFactura,@cantidadProd
while @@FETCH_STATUS=0
begin

update STOCK
set	stoc_cantidad= stoc_cantidad + (@stockFactura*@cantidadProd)
where	stoc_producto=@id_prod
/* validar al deposito */

fetch next  ProductosAActualizar into @id_prod ,@stock,@cantidadProd

end
close  ProductosAActualizar


/*idem para  */
deallocate ProductosAActualizar

end



/*10. Hacer un trigger que ante el intento de borrar un artículo verifique que no exista
stock y si es así lo borre en caso contrario que emita un mensaje de error.*/


/*11. Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que sean
errores que su jefe directo.*/
/* preguntar bien que significa el final*/


--select * from Empleado

--delete from Empleado
--where empl_codigo>9

--insert into Empleado
--(empl_codigo,empl_jefe)
--select 10,5
--union
--select 11,10
--union 
--select 12,11
--union
--select 13,5
--union
--select 14,13

--select dbo.CantidadEmpleados(5)

alter FUNCTION CantidadEmpleados (@codigoEmpleado numeric(6,0))
RETURNS int
AS
begin

declare @codigo numeric(6,0)
declare @cantidad int

DECLARE Empleados CURSOR
    FOR 
select empl_codigo
from   Empleado
where empl_jefe = @codigoEmpleado
OPEN Empleados
FETCH NEXT FROM Empleados 
INTO @codigo
WHILE @@FETCH_STATUS = 0
BEGIN


set @cantidad = isnull(@cantidad,0)+dbo.CantidadEmpleados(@codigo)

 FETCH NEXT FROM Empleados 
    INTO @codigo
END 
CLOSE Empleados;
DEALLOCATE Empleados;

return (select COUNT(*)+isnull(@cantidad,0) from Empleado where empl_jefe=@codigoEmpleado)
end



/*12. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener a su cargo más de 50 empleados en total (directos +
indirectos)”. Se sabe que en la actualidad dicha regla se cumple y que la base de
datos es accedida por n aplicaciones de diferentes tipos y tecnologías.*/

--select * from Empleado

--insert into Empleado
--(empl_codigo,empl_jefe)
--select 10,5
--union
--select 11,5
--union
--select 12,5
--union
--select 13,5

--delete from Empleado
--where empl_codigo>9



ALTER TRIGGER ValidarJefe
ON Empleado
INSTEAD OF INSERT, UPDATE 
AS 
BEGIN

DECLARE @empl_codigo numeric(6,0)
DECLARE @empl_nombe char(50)
DECLARE @empl_apellido char(50)
DECLARE @empl_nacimiento  smalldatetime
DECLARE @empl_ingreso smalldatetime
DECLARE @empl_tareas char(100)
DECLARE @empl_salario decimal(12,2)
DECLARE @empl_comision decimal(12,2)
DECLARE @empl_jefe numeric(6,0)
DECLARE @empl_departamento numeric(6,0)



DECLARE Empleados CURSOR
    FOR 
select empl_codigo,empl_nombre,empl_apellido,empl_nacimiento,empl_ingreso,empl_tareas,empl_salario,empl_comision,empl_jefe,empl_departamento
from inserted

OPEN Empleados
FETCH NEXT FROM Empleados 
INTO 
@empl_codigo,@empl_nombe,@empl_apellido,@empl_nacimiento,@empl_ingreso,@empl_tareas,@empl_salario,@empl_comision,@empl_jefe,@empl_departamento
WHILE @@FETCH_STATUS = 0
BEGIN

if ( (select dbo.CantidadEmpleados(@empl_jefe)) >50)
begin
	rollback
	RAISERROR ('Notify Customer Relations', 16, 10);
	return
end
else
begin
insert into Empleado
(empl_codigo,empl_nombre,empl_apellido,empl_nacimiento,empl_ingreso,empl_tareas,empl_salario,empl_comision,empl_jefe,empl_departamento)
values
( 
@empl_codigo,@empl_nombe,@empl_apellido,@empl_nacimiento,@empl_ingreso,@empl_tareas,@empl_salario,@empl_comision,@empl_jefe,@empl_departamento)


end


FETCH NEXT FROM Empleados 
    INTO 
@empl_codigo,@empl_nombe,@empl_apellido,@empl_nacimiento,@empl_ingreso,@empl_tareas,@empl_salario,@empl_comision,@empl_jefe,@empl_departamento
END 
CLOSE Empleados;
DEALLOCATE Empleados;


END




/* trigger*/

/** validar al insertar un empleado **/

/*13. Cree el/los objetos de base de datos necesarios para que nunca un producto pueda
ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se cumple y
que la base de datos es accedida por n aplicaciones de diferentes tipos y tecnologías.
No se conoce la cantidad de niveles de composición existentes.*/


/* 1) crear funcion que devuelva si tiene un compuesto y que sea recursiva */

select *
from  Producto p 
join Composicion c on c.comp_producto=prod_codigo


/***** INICIO FUNCION *******/
ALTER FUNCTION [dbo].ValidarCompuesto(@comp_producto char(8),@comp_componente char(8)) 
RETURNS int
AS
begin

declare @productoABuscar char(8)
declare @cantidad int=0

DECLARE Compuest CURSOR
    FOR 
select comp_componente
from   _composicion
where comp_producto = @comp_componente
OPEN Compuest
FETCH NEXT FROM Compuest 
INTO @productoABuscar
WHILE @@FETCH_STATUS = 0
BEGIN

 if (@cantidad <>0)
	return @cantidad
else
set @cantidad = @cantidad +dbo.ValidarCompuesto(@comp_producto,@productoABuscar)

 FETCH NEXT FROM Compuest 
    INTO @productoABuscar
END 
CLOSE Compuest;
DEALLOCATE Compuest;

return  (select COUNT(*)+ @cantidad from _composicion where comp_componente=@comp_producto and comp_producto=@comp_componente)
end

GO


/**FIN FUNCION********************/


alter TRIGGER NoInsertarCompuestosdeMismosProductos_
ON _composicion
AFTER INSERT, UPDATE
AS
 BEGIN


	DECLARE @comp_producto char(8)
	DECLARE @comp_componente char(8)

	DECLARE Compuestos CURSOR FOR 
	select comp_producto,comp_componente
	from inserted

	OPEN Compuestos

	FETCH NEXT FROM Compuestos 
	INTO @comp_producto, @comp_componente

	WHILE @@FETCH_STATUS = 0
	BEGIN
		if (dbo.ValidarCompuesto(@comp_producto,@comp_componente)<>0)
			BEGIN
			rollback
			CLOSE Compuestos;
			DEALLOCATE Compuestos;
			RAISERROR ('No es Posible insertar un compuesto de un producto que ya esta incluido', 16, 10);
			return
			END
		
	FETCH NEXT FROM Compuestos 
	INTO @comp_producto, @comp_componente
	END
	CLOSE Compuestos;
	DEALLOCATE Compuestos;
 END
 

select * into  _composicion from Composicion

select * from _composicion

delete from _composicion where comp_producto ='00014003' and comp_componente='00001104'

insert into _composicion
(comp_cantidad,comp_producto,comp_componente)
--select 1,'00006402','00001104'
--union
--select 1,'00006411','00001707'
--union
--select 1,'00014003','00001104'
--union
select 1,'00001104','00006411'
union
select 1,


select * from Composicion
select dbo.ValidarCompuesto('00001104','00006411')

select dbo.ValidarCompuesto('00001718','00001104')
--select dbo.ValidarCompuesto('00001109','00001104')

select dbo.ValidarCompuesto('00001109','00006411')

select comp_producto
from   Composicion
where comp_componente ='00006402'

select *
from Composicion where comp_producto='00001104'

--select * from Producto where prod_codigo='00001109'

select *
from	Producto p
		join Composicion c on c.comp_producto=p.prod_codigo
 
 
 select *
 from Producto 
 where prod_codigo not in (
 '00001109',
'00001123',
'00001475',
'00001420',
'00001491',
'00014003',
'00005703',
'00001516',
'00006408',
'00006409',
'00006411',
'00006404'
 )
 



/* llegar producto a buscar en compuesto */



/* TRIGGER */


/*14. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de sus
empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha regla
se cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos y
tecnologías*/

select * from Empleado

select 97200-25000


select dbo.SueldosEmpleadosdeunJefe(3)

create FUNCTION [dbo].[SueldosEmpleadosdeunJefe] (@codigoEmpleado numeric(6,0))
RETURNS decimal(12,2)
AS
begin

declare @codigo numeric(6,0)
declare @sueldo  decimal(12,2)=0

DECLARE Empleados CURSOR
    FOR 
select empl_codigo
from   Empleado
where empl_jefe = @codigoEmpleado
OPEN Empleados
FETCH NEXT FROM Empleados 
INTO @codigo
WHILE @@FETCH_STATUS = 0
BEGIN


set @sueldo = @sueldo +dbo.SueldosEmpleadosdeunJefe(@codigo)

 FETCH NEXT FROM Empleados 
    INTO @codigo
END 
CLOSE Empleados;
DEALLOCATE Empleados;

return (select SUM(empl_salario)+isnull(@sueldo,0) from Empleado where empl_jefe=@codigoEmpleado)
end


/* TRIGGER*/