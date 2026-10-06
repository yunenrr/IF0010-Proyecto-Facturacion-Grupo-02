USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_EliminarDireccion' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_EliminarDireccion;
END
GO

CREATE PROCEDURE dbo.pr_EliminarDireccion
    @ID_DIRECCION INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.DIRECCION WHERE ID_DIRECCION = @ID_DIRECCION)
            THROW 50031, 'La direccion especificada no existe.', 1;

        IF EXISTS (SELECT 1 FROM dbo.CLIENTE WHERE ID_DIRECCION = @ID_DIRECCION)
            THROW 50032, 'No se puede eliminar: hay clientes usando esta direccion.', 1;

        IF EXISTS (SELECT 1 FROM dbo.EMPRESAEMISORA WHERE ID_DIRECCION = @ID_DIRECCION)
            THROW 50033, 'No se puede eliminar: hay empresas usando esta direccion.', 1;

        DELETE FROM dbo.DIRECCION
        WHERE ID_DIRECCION = @ID_DIRECCION;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
