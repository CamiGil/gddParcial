-- PARCIAL FEDE --

-----------------PUNTO 1----------------------

select 	top 3 e.empl_codigo as legajo, 
		e.empl_apellido as apellido,	
		year(e.empl_ingreso) as anioDeIngreso,
		case	when ((select count(*) from Factura where fact_vendedor = e.empl_codigo and year(fact_fecha) = 2011) >= 50) 
					then	(
							select		count(*)
							from		Factura
							where		fact_total > 100 and fact_vendedor = e.empl_codigo and YEAR(fact_fecha) = 2011
							group by	fact_vendedor
							)
				when ((select count(*) from Factura where fact_vendedor = e.empl_codigo and year(fact_fecha) = 2011) < 10)
					then	(
							select count(*)
							from Factura join Empleado on (fact_vendedor = empl_codigo)
							where empl_jefe = e.empl_codigo and year(fact_fecha) = 2011
							group by empl_jefe
							) * 0.5
		end as puntaje2011,
		case	when ((select count(*) from Factura where fact_vendedor = e.empl_codigo and year(fact_fecha) = 2012) >= 50) 
					then	(
							select		count(*)
							from		Factura
							where		fact_total > 100 and fact_vendedor = e.empl_codigo and YEAR(fact_fecha) = 2012
							group by	fact_vendedor
							)
				when ((select count(*) from Factura where fact_vendedor = e.empl_codigo and year(fact_fecha) = 2012) < 10)
					then	(
							select count(*)
							from Factura join Empleado on (fact_vendedor = empl_codigo)
							where empl_jefe = e.empl_codigo and year(fact_fecha) = 2012
							group by empl_jefe
							) * 0.5
		end as puntaje2012

		
from Empleado e join Factura f on (e.empl_codigo = f.fact_vendedor)
group by e.empl_codigo, e.empl_apellido, year(e.empl_ingreso)


-----------------PUNTO 2----------------------

create trigger PUNTO_2
on Factura
instead of insert
as
begin
	declare @totalDeImporteFacturadoXMes decimal(12,2);
	declare @clienteQueCompro char(6);
	declare @limiteCreditoXMesCliente decimal(12,2);
	declare @ultimaFactura char(13);
	set @clienteQueCompro = (select top 1 fact_cliente from inserted order by fact_fecha desc)
	set @ultimaFactura = (select top 1 concat(fact_tipo,fact_sucursal,fact_numero) from inserted order by fact_fecha desc)
	set @limiteCreditoXMesCliente = (select clie_limite_credito from Cliente where clie_codigo = @clienteQueCompro)
	set @totalDeImporteFacturadoXMes = (
											select	sum(fact_total) 
											from	Factura 
											where	fact_cliente = @clienteQueCompro and 
													year(fact_fecha) = year(GETDATE()) and 
													month(fact_fecha) = month(GETDATE())
											)
	if(@limiteCreditoXMesCliente < @totalDeImporteFacturadoXMes) 
		begin
			delete from Factura where concat(fact_tipo,fact_sucursal,fact_numero) = @ultimaFactura
			raiserror ('SE SUPERO EL LIMITE DE CREDITO MENSUAL. NO SE PUEDE FACTURAR',1,1)
		end
end

-----------------PUNTO 3----------------------
/*
	* 3.0 
		
		a) Verdadero.
		b) Falso.
	
	* 3.1
	a) Los niveles de aislamiento son:
	
	Read uncommited: es el menor nivel de aislamiento, puede ver insert/update/delete que fueron y que NO fueron
					 commiteados, y además, un SELECT no bloquea la tabla de la que tomo los datos.
					 NO: Lecturas Repetidas
					 SI: Datos Fantasma, Datos Sucios
					 
	Read commited: asegura que no haya lecturas sucias, cuando hay insert en T1, el próximo
				   select en T2 se bloquea y espera a que se commitee el T1 y recién ahí hace el select.
				   NO: Lecturas Repetidas, Datos Sucios, Datos Fantasma
	
	Repeatble read: Cuando en T1 hay un update de un registro que estaba antes, y en T2 se 
					hace un select, el mismo se bloquea hasta que se commitee lo del update. 
					NO: Datos Sucios, Datos Fantasm
					SI: Lecturas Repetidas
					
	Serializable: es el nivel de aislamiento más alto. Se bloquea todo, incluidos inserts hasta que se commitee la transacción.
				NO: Datos Sucios, Datos Fantasma. 
				SI: Lecturas repetidas

b) Fact table:  es la tabla primaria en cada modelo dimensional, tiene relación muchos a muchos y contiene
				un conjunto de dos o más FK que hace referencias a las Dimension Table.
				EJ: Cubo

   Dimension Table: restringe los criterios de selección de los datos de la Fact Table. Cada dimensión tiene su clave primaria que sirve como base para la integridad referencial de la Fact Table, la cual hace join. Puede estar normalizada o no.
*/

