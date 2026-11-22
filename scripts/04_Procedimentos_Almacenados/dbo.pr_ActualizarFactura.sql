USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARFACTURA
    @CODIGO_FACTURA INT,
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
                FROM DBO.FACTURA
                WHERE CODIGO_FACTURA = @CODIGO_FACTURA
            )
            BEGIN
                THROW 50051, 'La factura especificada no existe.', 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.ESTADO_FACTURA
                WHERE ID_ESTADO = @ID_ESTADO
            )
            BEGIN
                THROW 50052, 'El estado especificado no existe.', 1;
            END;

        UPDATE DBO.FACTURA
        SET
            ID_ESTADO = @ID_ESTADO,
            UPDATED_AT = SYSDATETIME()
        WHERE
            CODIGO_FACTURA = @CODIGO_FACTURA;

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
