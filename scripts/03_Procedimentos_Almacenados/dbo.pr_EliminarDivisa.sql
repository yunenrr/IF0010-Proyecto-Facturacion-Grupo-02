USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ELIMINARDIVISA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ELIMINARDIVISA;
    END;
GO

CREATE PROCEDURE DBO.PR_ELIMINARDIVISA
    @CODIGO_DIVISA CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIVISA
                WHERE CODIGO_DIVISA = @CODIGO_DIVISA
            )
            BEGIN
                THROW 
                50100, 
                'La divisa especificada no existe.', 
                1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.FACTURA
                WHERE CODIGO_DIVISA = @CODIGO_DIVISA
            )
            BEGIN
                THROW
                50101,
                'No se puede eliminar: la divisa está asociada a facturas.',
                1;
            END;

        DELETE FROM DBO.DIVISA
        WHERE
            CODIGO_DIVISA = @CODIGO_DIVISA;

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