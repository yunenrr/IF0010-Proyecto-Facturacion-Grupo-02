USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARTIPODOCUMENTO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARTIPODOCUMENTO;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARTIPODOCUMENTO
    @IDTIPODOCUMENTO INT,
    @DESCRIPCIONTIPODOCUMENTO VARCHAR(50)
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
                WHERE ID_TIPO_DOCUMENTO = @IDTIPODOCUMENTO
            )
            BEGIN
                THROW 50080, 'El Tipo de Documento especificado no existe', 1;
            END;

        IF
            @DESCRIPCIONTIPODOCUMENTO IS NULL
            OR TRIM(@DESCRIPCIONTIPODOCUMENTO) = ''
            BEGIN
                THROW
                50081,
                'La descripción del tipo de documento no puede estar vacía.',
                1;
            END;

        UPDATE DBO.TIPO_DOCUMENTO
        SET
            DESCRIPCION_TIPO_DOCUMENTO = TRIM(@DESCRIPCIONTIPODOCUMENTO)
        WHERE
            ID_TIPO_DOCUMENTO = @IDTIPODOCUMENTO;

        IF @@ROWCOUNT = 0
            BEGIN
                THROW
                50082,
                'No se pudo actualizar el Tipo de Documento.',
                1;
            END;

        COMMIT TRANSACTION;

        SELECT
            TD.ID_TIPO_DOCUMENTO,
            TD.DESCRIPCION_TIPO_DOCUMENTO
        FROM DBO.TIPO_DOCUMENTO AS TD
        WHERE
            TD.ID_TIPO_DOCUMENTO = @IDTIPODOCUMENTO;
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
