USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1 FROM SYS.OBJECTS
        WHERE NAME = 'pr_EliminarCliente' AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ELIMINARCLIENTE;
    END
GO

CREATE PROCEDURE DBO.PR_ELIMINARCLIENTE
    @ID_CLIENTE INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1 FROM DBO.CLIENTE
                WHERE ID_CLIENTE = @ID_CLIENTE
            )
            THROW 50018, 'El cliente especificado no existe.', 1;

        IF
            EXISTS (
                SELECT 1 FROM DBO.FACTURA
                WHERE ID_CLIENTE = @ID_CLIENTE
            )
            THROW 50019,
                'No se puede eliminar: el cliente tiene facturas asociadas.',
                1;

        DELETE FROM DBO.CLIENTE
        WHERE ID_CLIENTE = @ID_CLIENTE;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
