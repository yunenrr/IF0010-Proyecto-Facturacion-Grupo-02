USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarEmpresaEmisora', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarEmpresaEmisora;
GO

CREATE PROCEDURE dbo.pr_RegistrarEmpresaEmisora
    @Cedula VARCHAR(20),
    @NombreComercial VARCHAR(150),
    @RazonSocial VARCHAR(150),
    @IdDireccion INT,
    @Telefono VARCHAR(20) = NULL,
    @Correo VARCHAR(100) = NULL,
    @IdEmpresa INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.DIRECCION WHERE ID_DIRECCION = @IdDireccion)
        BEGIN
            THROW 50001, 'La dirección especificada no existe.', 1;
        END

        IF EXISTS (SELECT 1 FROM dbo.EMPRESAEMISORA WHERE CEDULA = @Cedula)
        BEGIN
            THROW 50002, 'La cédula de la empresa emisora ya se encuentra registrada.', 1;
        END

        INSERT INTO dbo.EMPRESAEMISORA (
            CEDULA,
            NOMBRE_COMERCIAL,
            RAZON_SOCIAL,
            ID_DIRECCION,
            TELEFONO,
            CORREO
        )
        VALUES (
            @Cedula,
            @NombreComercial,
            @RazonSocial,
            @IdDireccion,
            @Telefono,
            @Correo
        );

        SET @IdEmpresa = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO