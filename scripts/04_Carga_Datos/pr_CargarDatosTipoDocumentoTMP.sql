USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARDATOSTIPODOCUMENTOTMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARDATOSTIPODOCUMENTOTMP;
    END;
GO

CREATE PROCEDURE DBO.PR_CARGARDATOSTIPODOCUMENTOTMP
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO DBO.TIPODOCUMENTO (
            ID_TIPO_DOCUMENTO,
            DESCRIPCION_TIPO_DOCUMENTO
        )
        SELECT
            T.ID_TIPO_DOCUMENTO,
            T.DESCRIPCION_TIPO_DOCUMENTO
        FROM (
            VALUES
            (1, 'Factura Electrónica'),
            (2, 'Tiquete Electrónico'),
            (3, 'Nota de Débito'),
            (4, 'Nota de Crédito')
        ) AS T(ID_TIPO_DOCUMENTO, DESCRIPCION_TIPO_DOCUMENTO)
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.TIPODOCUMENTO AS TD
                WHERE
                    TD.ID_TIPO_DOCUMENTO = T.ID_TIPO_DOCUMENTO
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

EXEC DBO.PR_CARGARDATOSTIPODOCUMENTOTMP;
PRINT 'Carga de catálogo TIPODOCUMENTO completada con éxito.';
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARDATOSTIPODOCUMENTOTMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARDATOSTIPODOCUMENTOTMP;
    END;
GO
