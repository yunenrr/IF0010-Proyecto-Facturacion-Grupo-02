USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRARTIPODOCUMENTO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRARTIPODOCUMENTO;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRARTIPODOCUMENTO
    @ID_TIPO_DOCUMENTO INT,
    @DESCRIPCION_TIPO_DOCUMENTO VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.TIPO_DOCUMENTO
                WHERE ID_TIPO_DOCUMENTO = @ID_TIPO_DOCUMENTO
            )
            BEGIN
                THROW
                50135,
                'El ID del tipo de documento ya se encuentra registrado.',
                1;
            END;

        IF
            @DESCRIPCION_TIPO_DOCUMENTO IS NULL
            OR TRIM(@DESCRIPCION_TIPO_DOCUMENTO) = ''
            BEGIN
                THROW
                50136,
                'La descripción del tipo de documento no puede estar vacía.',
                1;
            END;

        INSERT INTO DBO.TIPO_DOCUMENTO (
            ID_TIPO_DOCUMENTO,
            DESCRIPCION_TIPO_DOCUMENTO
        )
        VALUES (
            @ID_TIPO_DOCUMENTO,
            TRIM(@DESCRIPCION_TIPO_DOCUMENTO)
        );

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
