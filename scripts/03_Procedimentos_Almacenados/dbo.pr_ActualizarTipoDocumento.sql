USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_ActualizarTipoDocumento', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_ActualizarTipoDocumento;
GO
CREATE PROCEDURE dbo.pr_ActualizarTipoDocumento
    @IDTipoDocumento INT,
    @DescripcionTipoDocumento VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM dbo.TIPODOCUMENTO WHERE ID_TIPO_DOCUMENTO = @IDTipoDocumento)
        BEGIN
            THROW 50080, 'El Tipo de Documento especificado no existe', 1;
        END
        IF TRIM(TRIM(@DescripcionTipoDocumento)) = '' OR @DescripcionTipoDocumento IS NULL
        BEGIN
            THROW 50081, 'La descripción del tipo de documento no puede estar vacía.', 1;
        END
        UPDATE dbo.TIPODOCUMENTO
        SET DESCRIPCION_TIPO_DOCUMENTO = TRIM(TRIM(@DescripcionTipoDocumento))
        WHERE ID_TIPO_DOCUMENTO = @IDTipoDocumento;
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50082, 'No se pudo actualizar el Tipo de Documento.', 1;
        END
        COMMIT TRANSACTION;
        SELECT 
            ID_TIPO_DOCUMENTO,
            DESCRIPCION_TIPO_DOCUMENTO
        FROM dbo.TIPODOCUMENTO
        WHERE ID_TIPO_DOCUMENTO = @IDTipoDocumento;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH
END;
GO
