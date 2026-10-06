USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_MigrarEstadoFacturaTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_MigrarEstadoFacturaTMP;
GO

CREATE PROCEDURE dbo.pr_MigrarEstadoFacturaTMP
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.ESTADOFACTURA (ID_ESTADO, ESTADO, DESCRIPCION_ESTADO)
        SELECT E.ID_ESTADO, E.ESTADO, E.DESCRIPCION_ESTADO
        FROM (VALUES 
            (1, 'BORRADOR', 'Factura en preparación'),
            (2, 'EMITIDA', 'Factura emitida y enviada'),
            (3, 'PAGADA', 'Factura cancelada por el cliente'),
            (4, 'CANCELADA', 'Factura anulada o devuelta')
        ) AS E(ID_ESTADO, ESTADO, DESCRIPCION_ESTADO)
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.ESTADOFACTURA ef WHERE ef.ID_ESTADO = E.ID_ESTADO
        );

        COMMIT TRANSACTION;
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

EXEC dbo.pr_MigrarEstadoFacturaTMP;
PRINT 'Carga de catálogo ESTADOFACTURA completada con éxito.';
GO

IF OBJECT_ID('dbo.pr_MigrarEstadoFacturaTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_MigrarEstadoFacturaTMP;
GO