USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_EliminarCliente' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_EliminarCliente;
END
GO

CREATE PROCEDURE dbo.pr_EliminarCliente
    @ID_CLIENTE INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTE WHERE ID_CLIENTE = @ID_CLIENTE)
            THROW 50018, 'El cliente especificado no existe.', 1;

        IF EXISTS (SELECT 1 FROM dbo.FACTURA WHERE ID_CLIENTE = @ID_CLIENTE)
            THROW 50019, 'No se puede eliminar: el cliente tiene facturas asociadas.', 1;

        DELETE FROM dbo.CLIENTE
        WHERE ID_CLIENTE = @ID_CLIENTE;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
