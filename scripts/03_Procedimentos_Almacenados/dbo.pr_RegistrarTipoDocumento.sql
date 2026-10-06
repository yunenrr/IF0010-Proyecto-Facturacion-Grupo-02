USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarTipoDocumento', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarTipoDocumento;
GO

CREATE PROCEDURE dbo.pr_RegistrarTipoDocumento
    @IdTipoDocumento INT,
    @DescripcionTipoDocumento VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM dbo.TIPODOCUMENTO
            WHERE ID_TIPO_DOCUMENTO = @IdTipoDocumento
        )
        BEGIN
            THROW 50015, 'El ID del tipo de documento ya se encuentra registrado.', 1;
        END;

        INSERT INTO dbo.TIPODOCUMENTO (
            ID_TIPO_DOCUMENTO,
            DESCRIPCION_TIPO_DOCUMENTO
        )
        VALUES (
            @IdTipoDocumento,
            @DescripcionTipoDocumento
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO