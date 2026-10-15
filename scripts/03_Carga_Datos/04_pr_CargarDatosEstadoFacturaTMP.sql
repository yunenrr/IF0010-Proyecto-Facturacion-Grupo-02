USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('DBO.PR_MIGRARESTADOFACTURATMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_MIGRARESTADOFACTURATMP;
GO

CREATE PROCEDURE DBO.PR_MIGRARESTADOFACTURATMP
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO DBO.ESTADOFACTURA (
            ID_ESTADO,
            ESTADO,
            DESCRIPCION_ESTADO
        )
        SELECT
            ESTADOS.ID_ESTADO,
            ESTADOS.ESTADO,
            ESTADOS.DESCRIPCION_ESTADO
        FROM
            (
                VALUES
                (1, 'BORRADOR', 'Factura en preparación'),
                (2, 'EMITIDA', 'Factura emitida y enviada'),
                (3, 'PAGADA', 'Factura cancelada por el cliente'),
                (4, 'CANCELADA', 'Factura anulada o devuelta')
            ) AS ESTADOS(ID_ESTADO, ESTADO, DESCRIPCION_ESTADO)
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.ESTADOFACTURA
                WHERE
                    DBO.ESTADOFACTURA.ID_ESTADO = ESTADOS.ID_ESTADO
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

EXEC DBO.PR_MIGRARESTADOFACTURATMP;
PRINT 'Carga de catálogo ESTADOFACTURA completada con éxito.';
GO

IF OBJECT_ID('DBO.PR_MIGRARESTADOFACTURATMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_MIGRARESTADOFACTURATMP;
GO
