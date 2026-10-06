USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_CargarDatosTipoDocumentoTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_CargarDatosDocumentoTMP;
GO

CREATE PROCEDURE dbo.pr_CargarDatosTipoDocumentoTMP
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.TIPODOCUMENTO (ID_TIPO_DOCUMENTO, DESCRIPCION_TIPO_DOCUMENTO)
        SELECT T.ID_TIPO_DOCUMENTO, T.DESCRIPCION_TIPO_DOCUMENTO
        FROM (VALUES 
            (1, 'Factura Electrónica'),
            (2, 'Tiquete Electrónico'),
            (3, 'Nota de Débito'),
            (4, 'Nota de Crédito')
        ) AS T(ID_TIPO_DOCUMENTO, DESCRIPCION_TIPO_DOCUMENTO)
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.TIPODOCUMENTO td WHERE td.ID_TIPO_DOCUMENTO = T.ID_TIPO_DOCUMENTO
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

EXEC dbo.pr_CargarDatosTipoDocumentoTMP;
PRINT 'Carga de catálogo TIPODOCUMENTO completada con éxito.';
GO

IF OBJECT_ID('dbo.pr_CargarDatosTipoDocumentoTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_CargarDatosTipoDocumentoTMP;
GO