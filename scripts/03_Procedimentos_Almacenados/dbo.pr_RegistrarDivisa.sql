USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarDivisa', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarDivisa;
GO

CREATE PROCEDURE dbo.pr_RegistrarDivisa
    @CodigoDivisa CHAR(3),
    @Nombre VARCHAR(50),
    @Simbolo VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM dbo.DIVISA
            WHERE CODIGO_DIVISA = @CodigoDivisa
        )
        BEGIN
            THROW 50014, 'El código de divisa ya se encuentra registrado.', 1;
        END;

        INSERT INTO dbo.DIVISA (
            CODIGO_DIVISA,
            NOMBRE,
            SIMBOLO
        )
        VALUES (
            @CodigoDivisa,
            @Nombre,
            @Simbolo
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