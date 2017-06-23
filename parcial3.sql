-- PARCIAL 2C MIERCOLES 2016

/* Ejercicio 1.a
En los arboles binarios, siempre la cantidad de saltos para encontrar un dato es menos o iguala log2 N,
siendo N la cantidad de nodos del arbol.

FALSO --> Si y solo sí está perfectamente balanceado
*/
/* Ejercicio 1.b 
Si 2 transacciones tienne isolation level read committed, y ambas intentan modifican un dato, al mismo
tiempo, siempre uno debera esperar a que la otra termine.

FALSO --> 
*/
/* Ejercicio 2
Ventajas datawarehouse

	Los datawarehouse son muy útiles para hacer una consolidación de información que proviene de distintos
	tipos de fuentes. Ya sea base de datos, archivos de texto, aplicaciones soft, ERP, CRM etc.
	Por ejemplo un gerente puede necesitar a final de la semana un reporte en donde visualice información 
	del sector de ventas ( cuantas ventas se hicieron , en que fechas, etc ), además, en un mismo 
	registro, quizás se necesita saber la cantidad de horas dedicadas por los trabajadores, y así
	todo tipo de información requerida.
	Esto se logra mediante los llamados ETL ( Extracción - Transformación - Carga ) que extraen la información
	necesaria de las distintas fuentes, hacen una depuración y la organizan para visualizarla según los
	requerimientos.
	Por lo tanto, una gran ventaja es el acceso a los datos que nos brinda.
	Además es temático, por lo explicado anteriormente, los datos se organizan por temas, por necesidades
	específicas.
	Otra ventaja es que es histórico, se pueden realizan análisis de tendencias, hacer comparaciones a lo 
	largo del tiempo.[( Facturacion + horas trabajadas + sueldos pagados ) el mes anterior] VS 
	[( Facturacion + horas trabajadas + sueldos pagados ) el último mes].
	Por esto mismo, termina además siendo una herramienta útil para la toma de decisiones en cualquier 
	área funcional. Nos permite aprender de datos pasados para predecir situaciones futuras.
*/

/* Ejercicio 3 - OK */
/* Realizar una consutla que retorne todos los años en donde en mas de
10 facturas se vendieron juntos los productos 1 y 3 . Tambien 
informar para ese año, el monto total facturado */
USE [GD2015C1]
GO
SELECT YEAR(f.fact_fecha) as 'anio', SUM(f.fact_total) as 'total'
	FROM Factura f
	INNER JOIN Item_Factura i1 ON i1.item_numero = f.fact_numero and i1.item_tipo = f.fact_tipo and i1.item_sucursal = f.fact_sucursal
	INNER JOIN Item_Factura i2 ON i2.item_numero = f.fact_numero and i2.item_tipo = f.fact_tipo and i2.item_sucursal = f.fact_sucursal
	WHERE i1.item_producto = '1' and i2.item_producto = '3'
	GROUP BY YEAR(f.fact_fecha)
	HAVING COUNT(distinct f.fact_numero + f.fact_tipo + f.fact_sucursal) > 10

/* Ejercicio 4 - OK */
/* Implementar los objetos necesarios para que mediante la 
instruccion update se pueda cambiar el codigo de un cliente.
Ademas no debera permitir al usuario que haga updates de codigos
que afecten a mas de una fila. */

-- NOTA: 4
CREATE TRIGGER CAMBIAR_CODIGO_CLIENTE 
ON CLIENTE
INSTEAD OF UPDATE
AS
DECLARE @CANTIDAD_UPDATES INT
BEGIN 
	DECLARE @COD_ANTERIOR CHAR(6)
	DECLARE @COD_NUEVO CHAR(6)
	-- VERIFICAR SI UPDATEARON A MUCHOS
	SELECT @CANTIDAD_UPDATES = COUNT(1) FROM DELETED
	IF ( @CANTIDAD_UPDATES = 1)
	BEGIN
		SELECT @COD_ANTERIOR = CLIE_CODIGO FROM DELETED
		SELECT @COD_NUEVO = CLIE_CODIGO FROM INSERTED
		--SELECT @COD_ANTERIOR, @COD_NUEVO
		--EXEC dbo.PROCEDURE_CODIGO_NUEVO_OK (@COD_ANTERIOR, @COD_NUEVO)
		
		/* INSERTO EL NUEVO CLIENTE IGUAL AL ANTERIOR CON EL CODIGO NUEVO */
		INSERT INTO cliente 
		SELECT @COD_NUEVO, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor
		FROM cliente
		WHERE clie_codigo = @COD_ANTERIOR

		/* UPDATEO LA TABLA FACTURA (CLIENTE NUEVO POR EL VIEJO)*/
		UPDATE FACTURA SET FACT_CLIENTE = @COD_NUEVO WHERE FACT_CLIENTE = @COD_ANTERIOR

		/* ELIMINO CLIENTE VIEJO EN CLIENTE */
		DELETE FROM CLIENTE WHERE CLIE_CODIGO = @COD_ANTERIOR
	END
	ELSE
	BEGIN
		SELECT 'NO PODES UPDATEAR DE A MAS DE UN REGISTRO POR VEZ'
	END
END

-- ASI LO HICE YO, no se si esta bien
CREATE TRIGGER Ej4 ON Cliente
INSTEAD OF UPDATE
AS 
	BEGIN TRANSACTION
	declare @codigoNuevo as char(6)
	declare @codigoViejo as char(6)
	declare @cantidadDeUpdates as integer
	
	SET @cantidadDeUpdates = (SELECT COUNT(1) FROM inserted)
	
	if @cantidadDeUpdates = 1
		begin
			select clie_codigo = @codigoNuevo from INSERTED
			select clie_codigo = @codigoViejo from DELETED
			UPDATE Cliente SET clie_codigo = @codigoNuevo
			UPDATE Factura SET fact_cliente = @codigoNuevo WHERE fact_cliente = @codigoViejo
		end
	else
		raiserror('no se puede updtear mas de uno a la vez', 1, 1)
		RETURN 
	COMMIT TRANSACTION
