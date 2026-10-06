USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('DBO.PR_ACTUALIZARTIPODOCUMENTO', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_ACTUALIZARTIPODOCUMENTO;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARTIPODOCUMENTO
    @IDTIPODOCUMENTO INT,
    @DESCRIPCIONTIPODOCUMENTO VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.TIPODOCUMENTO
                WHERE ID_TIPO_DOCUMENTO = @IDTIPODOCUMENTO
            )
            BEGIN
                THROW 50080, 'El Tipo de Documento especificado no existe', 1;
            END;

        IF
            TRIM(TRIM(@DESCRIPCIONTIPODOCUMENTO)) = ''
            OR @DESCRIPCIONTIPODOCUMENTO IS NULL
            BEGIN
                THROW
                50081,
                'La descripción del tipo de documento no puede estar vacía.',
                1;
            END;

        UPDATE DBO.TIPODOCUMENTO
        SET
            DESCRIPCION_TIPO_DOCUMENTO = TRIM(
                TRIM(@DESCRIPCIONTIPODOCUMENTO)
            )
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
            ID_TIPO_DOCUMENTO,
            DESCRIPCION_TIPO_DOCUMENTO
        FROM DBO.TIPODOCUMENTO
        WHERE
            ID_TIPO_DOCUMENTO = @IDTIPODOCUMENTO;
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
