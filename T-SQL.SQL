CREATE TRIGGER ACTUALIZAR_STOCK
ON ITEM_FACTURA FOR UPDATE,INSERT,DELETE
AS
BEGIN
DECLARE @ID_PROD CHAR(8)
DECLARE @STOCK DECIMAL(12,2)

DECLARE ACTUALIZAR_DEL CURSOR
FOR
	SELECT DEL.item_producto,DEL.item_cantidad
	FROM DELETED DEL
OPEN ACTUALIZAR_DEL
FETCH NEXT FROM ACTUALIZAR_DEL INTO @ID_PROD, @STOCK
WHILE @@FETCH_STATUS=0
	BEGIN 
		UPDATE STOCK 
		SET STOC_CANTIDAD = stoc_cantidad + @STOCK
		WHERE stoc_producto = @ID_PROD AND stoc_deposito = '00'
		FETCH NEXT FROM ACTUALIZAR_DEL INTO @ID_PROD, @STOCK
	END
CLOSE ACTUALIZAR_DEL
DEALLOCATE ACTUALIZAR_DEL

DECLARE ACTUALIZAR_INS CURSOR
FOR
	SELECT INS.item_producto,INS.item_cantidad
	FROM INSERTED INS
OPEN ACTUALIZAR_INS
FETCH NEXT FROM ACTUALIZAR_INS INTO @ID_PROD, @STOCK
WHILE @@FETCH_STATUS=0
	BEGIN 

		IF((SELECT S.stoc_cantidad 
			FROM STOCK S
			WHERE S.stoc_producto = @ID_PROD
			AND S.stoc_deposito = '00')-@STOCK < 0 )
				BEGIN
					ROLLBACK TRANSACTION					
					RAISERROR('NO TENE MAS MERCA',1,1)
				END
		ELSE 
				BEGIN
					UPDATE STOCK 
					SET STOC_CANTIDAD = stoc_cantidad - @STOCK
					WHERE stoc_producto = @ID_PROD AND stoc_deposito = '00'
					FETCH NEXT FROM ACTUALIZAR_INS INTO @ID_PROD, @STOCK
				END
	END
CLOSE ACTUALIZAR_INS
DEALLOCATE ACTUALIZAR_INS

END


----------------------------------------

CREATE TABLE EmpleadosEliminados
(
 codigo [numeric](6, 0) NOT NULL,
 nombre [char](50) NULL,
 apellido [char](50) NULL,
 nacimiento [smalldatetime] NULL,
 ingreso [smalldatetime] NULL,
 tareas [char](100) NULL,
 salario [decimal](12, 2) NULL,
 comision [decimal](12, 2) NULL,
 jefe [numeric](6, 0) NULL,
 departamento [numeric](6, 0) NULL,
 fechaOperacion [smalldatetime] NULL
)


CREATE TRIGGER TRIGGER_EMPLEADOS_ELIMINADOS
ON EMPLEADO FOR DELETE
AS 
BEGIN TRANSACTION
	INSERT INTO EmpleadosEliminados
	SELECT *, GETDATE()
	FROM DELETED
COMMIT TRANSACTION

---------------------------------------------------

ALTER TABLE DEPOSITO
ADD DEPO_BAJA BIT NOT NULL 
DEFAULT 0

CREATE TRIGGER 'DAR_DEPOSITO_BAJA'
ON DEPOSITO
INSTEAD OF DELETE
AS
BEGIN TRANSACTION
	UPDATE DEPOSITO SET DEPO_BAJA = 1
	FROM DELETED DEL
	WHERE DEL.depo_codigo = DEPOSITO.depo_codigo
COMMIT TRANSACTION 

--------------------------------------------

CREATE TABLE EmpleadosInsertados
(
 codigo [numeric](6, 0) NOT NULL,
 nombre [char](50) NULL,
 apellido [char](50) NULL,
 nacimiento [smalldatetime] NULL,
 ingreso [smalldatetime] NULL,
 tareas [char](100) NULL,
 salario [decimal](12, 2) NULL,
 comision [decimal](12, 2) NULL,
 jefe [numeric](6, 0) NULL,
 departamento [numeric](6, 0) NULL,
 usuarioQueIngreso [char](50) NULL,
 fechaOperacion [smalldatetime] NULL
)

CREATE TRIGGER TRIGGER_EMPLEADOS_HISTORIAL 
ON EMPLEADO FOR INSERT
AS 
BEGIN TRANSACTION
	INSERT INTO EmpleadosInsertados
	SELECT *, 'ADMIN', GETDATE()
	FROM inserted
COMMIT TRANSACTION
