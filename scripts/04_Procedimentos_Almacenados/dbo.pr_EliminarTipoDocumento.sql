USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ELIMINARTIPODOCUMENTO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ELIMINARTIPODOCUMENTO;
    END;
GO

CREATE PROCEDURE DBO.PR_ELIMINARTIPODOCUMENTO
    @ID_TIPO_DOCUMENTO INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.TIPO_DOCUMENTO
                WHERE ID_TIPO_DOCUMENTO = @ID_TIPO_DOCUMENTO
            )
            BEGIN
                THROW
                50110,
                'El tipo de documento especificado no existe.',
                1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.FACTURA
                WHERE ID_TIPO_DOCUMENTO = @ID_TIPO_DOCUMENTO
            )
            BEGIN
                THROW
                50111,
                'No se puede eliminar: el tipo de documento tiene facturas.',
                1;
            END;

        DELETE FROM DBO.TIPO_DOCUMENTO
        WHERE
            ID_TIPO_DOCUMENTO = @ID_TIPO_DOCUMENTO;

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
