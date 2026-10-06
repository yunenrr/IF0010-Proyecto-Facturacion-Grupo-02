USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ELIMINARESTADOFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ELIMINARESTADOFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_ELIMINARESTADOFACTURA
    @ID_ESTADO INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.ESTADOFACTURA
                WHERE ID_ESTADO = @ID_ESTADO
            )
            BEGIN
                THROW 50022, 'El estado de factura especificado no existe.', 1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.FACTURA
                WHERE ID_ESTADO = @ID_ESTADO
            )
            BEGIN
                THROW
                50023,
                'No se puede eliminar: el estado está asociado a facturas.',
                1;
            END;

        DELETE FROM DBO.ESTADOFACTURA
        WHERE
            ID_ESTADO = @ID_ESTADO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        THROW;
    END CATCH;
END;
GO