USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CANCELARFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CANCELARFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_CANCELARFACTURA
    @CODIGO_FACTURA INT,
    @ID_ESTADO_CANCELADA INT
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
                THROW 50050, 'La factura especificada no existe.', 1;
            END;

        UPDATE DBO.FACTURA
        SET
            ID_ESTADO = @ID_ESTADO_CANCELADA,
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
