USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE name = 'pr_ActualizarDireccion' AND type = 'P'
)
BEGIN
    DROP PROCEDURE dbo.pr_ActualizarDireccion;
END
GO

CREATE PROCEDURE dbo.pr_ActualizarDireccion (
    @DireccionId INT,
    @Provincia VARCHAR(50),
    @Canton VARCHAR(50),
    @Distrito VARCHAR(50),
    @SenasAdicionales VARCHAR(250) = NULL
)
AS
BEGIN
    SET NOCOUNT ON; 
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE dbo.DIRECCION
        SET
            PROVINCIA = @Provincia,
            CANTON = @Canton,
            DISTRITO = @Distrito,
            SENAS_ADICIONALES = @SenasAdicionales
        WHERE ID_DIRECCION = @DireccionId;

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50013, 'No se encontró ninguna dirección con el ID proporcionado.', 1;
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH
END
GO
