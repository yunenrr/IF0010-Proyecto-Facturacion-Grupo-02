USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_EliminarProducto' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_EliminarProducto;
END
GO

CREATE PROCEDURE dbo.pr_EliminarProducto
    @CODIGO_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTO WHERE CODIGO_ID = @CODIGO_ID)
            THROW 50101, 'El producto especificado no existe.', 1;

        IF EXISTS (SELECT 1 FROM dbo.DETALLEFACTURA WHERE CODIGO_PRODUCTO = @CODIGO_ID)
            THROW 50102, 'No se puede eliminar: el producto tiene detalles de factura asociados.', 1;

        DELETE FROM dbo.PRODUCTO
        WHERE CODIGO_ID = @CODIGO_ID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
