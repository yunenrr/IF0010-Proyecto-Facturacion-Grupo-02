USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarDireccion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarDireccion;
GO

CREATE PROCEDURE dbo.pr_RegistrarDireccion
    @Provincia VARCHAR(50),
    @Canton VARCHAR(50),
    @Distrito VARCHAR(50),
    @SenasAdicionales VARCHAR(250),
    @IdDireccion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.DIRECCION (
            PROVINCIA,
            CANTON,
            DISTRITO,
            SENAS_ADICIONALES
        )
        VALUES (
            @Provincia,
            @Canton,
            @Distrito,
            @SenasAdicionales
        );

        SET @IdDireccion = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO  