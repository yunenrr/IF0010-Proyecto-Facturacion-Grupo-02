USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_InsertarCliente' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_InsertarCliente;
END
GO

CREATE PROCEDURE dbo.pr_InsertarCliente
    @CEDULA VARCHAR(20),
    @NOMBRE VARCHAR(70),
    @ID_DIRECCION INT,
    @TELEFONO VARCHAR(15),
    @CORREO VARCHAR(75)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM dbo.CLIENTE WHERE CEDULA = @CEDULA)
            THROW 50003, 'Ya existe un cliente con esta cedula.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.DIRECCION WHERE ID_DIRECCION = @ID_DIRECCION)
            THROW 50001, 'La direccion especificada no existe.', 1;

        INSERT INTO dbo.CLIENTE (
            CEDULA, NOMBRE, ID_DIRECCION, TELEFONO, CORREO
        )
        VALUES (
            @CEDULA, @NOMBRE, @ID_DIRECCION, @TELEFONO, @CORREO
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
