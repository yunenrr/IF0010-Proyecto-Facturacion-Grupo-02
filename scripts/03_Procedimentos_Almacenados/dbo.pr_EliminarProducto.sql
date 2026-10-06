USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ELIMINARPRODUCTO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ELIMINARPRODUCTO;
    END;
GO

CREATE PROCEDURE DBO.PR_ELIMINARPRODUCTO
    @CODIGO_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.PRODUCTO
                WHERE
                    CODIGO_ID = @CODIGO_ID
            )
            BEGIN
                THROW 50101, 'El producto especificado no existe.', 1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.DETALLEFACTURA
                WHERE
                    CODIGO_PRODUCTO = @CODIGO_ID
            )
            BEGIN
                THROW
                50102,
                'No se puede eliminar: el producto tiene detalles '
                + 'de factura asociados.',
                1;
            END;

        DELETE FROM DBO.PRODUCTO
        WHERE
            CODIGO_ID = @CODIGO_ID;

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
