USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_MigrarDivisaTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_MigrarDivisaTMP;
GO

CREATE PROCEDURE dbo.pr_MigrarDivisaTMP
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.DIVISA (CODIGO_DIVISA, NOMBRE, SIMBOLO)
        SELECT D.CODIGO_DIVISA, D.NOMBRE, D.SIMBOLO
        FROM (VALUES 
            ('CRC', 'Colón Costarricense', '₡'),
            ('USD', 'Dólar Estadounidense', '$')
        ) AS D(CODIGO_DIVISA, NOMBRE, SIMBOLO)
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.DIVISA div WHERE div.CODIGO_DIVISA = D.CODIGO_DIVISA
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

EXEC dbo.pr_MigrarDivisaTMP;
PRINT 'Carga de catálogo DIVISA completada con éxito.';
GO

IF OBJECT_ID('dbo.pr_MigrarDivisaTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_MigrarDivisaTMP;
GO