USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('DBO.PR_MIGRARDIVISATMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_MIGRARDIVISATMP;
GO

CREATE PROCEDURE DBO.PR_MIGRARDIVISATMP
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO DBO.DIVISA (
            CODIGO_DIVISA,
            NOMBRE,
            SIMBOLO
        )
        SELECT
            DIVISAS.CODIGO_DIVISA,
            DIVISAS.NOMBRE,
            DIVISAS.SIMBOLO
        FROM
            (
                VALUES
                ('CRC', 'Colón Costarricense', '₡'),
                ('USD', 'Dólar Estadounidense', '$')
            ) AS DIVISAS (CODIGO_DIVISA, NOMBRE, SIMBOLO)
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIVISA
                WHERE DBO.DIVISA.CODIGO_DIVISA = DIVISAS.CODIGO_DIVISA
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

EXEC DBO.PR_MIGRARDIVISATMP;
PRINT 'Carga de catálogo DIVISA completada con éxito.';
GO

IF OBJECT_ID('DBO.PR_MIGRARDIVISATMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_MIGRARDIVISATMP;
GO
