USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_MIGRARESTADOFACTURATMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_MIGRARESTADOFACTURATMP;
    END;
GO

CREATE PROCEDURE DBO.PR_MIGRARESTADOFACTURATMP
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO DBO.ESTADO_FACTURA (
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
                (3, 'PAGADA', 'Factura pagada por el cliente'),
                (4, 'CANCELADA', 'Factura anulada o devuelta')
            ) AS ESTADOS(ID_ESTADO, ESTADO, DESCRIPCION_ESTADO)
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.ESTADO_FACTURA AS EF
                WHERE
                    EF.ID_ESTADO = ESTADOS.ID_ESTADO
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
PRINT 'Carga de catálogo ESTADO_FACTURA completada con éxito.';
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_MIGRARESTADOFACTURATMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_MIGRARESTADOFACTURATMP;
    END;
GO
