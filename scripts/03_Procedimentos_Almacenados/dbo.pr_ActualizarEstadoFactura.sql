USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_ActualizarEstadoFactura' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_ActualizarEstadoFactura;
END
GO

CREATE PROCEDURE dbo.pr_ActualizarEstadoFactura
    @ID_ESTADO INT,
    @ESTADO VARCHAR(20),
    @DESCRIPCION_ESTADO VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOFACTURA WHERE ID_ESTADO = @ID_ESTADO)
            THROW 50120, 'El estado de factura especificado no existe.', 1;

        IF EXISTS (
            SELECT 1 FROM dbo.ESTADOFACTURA
            WHERE ESTADO = @ESTADO AND ID_ESTADO <> @ID_ESTADO
        )
            THROW 50121, 'Ya existe otro estado con ese nombre.', 1;

        UPDATE dbo.ESTADOFACTURA
        SET ESTADO = @ESTADO,
            DESCRIPCION_ESTADO = @DESCRIPCION_ESTADO
        WHERE ID_ESTADO = @ID_ESTADO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
