USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_ActualizarEmpresaEmisora', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_ActualizarEmpresaEmisora;
GO
CREATE PROCEDURE dbo.pr_ActualizarEmpresaEmisora
    @IDEmpresa INT,
    @Cedula VARCHAR(20),
    @NombreComercial VARCHAR(150),
    @RazonSocial VARCHAR(150),
    @IDDireccion INT,
    @Telefono VARCHAR(20),
    @Correo VARCHAR(100),
    @Activa BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM dbo.EMPRESAEMISORA WHERE ID_EMPRESA = @IDEmpresa)
        BEGIN
            THROW 50008, 'La empresa emisora especificada no existe en el sistema.', 1;
        END
        IF EXISTS (
            SELECT 1 
            FROM dbo.EMPRESAEMISORA 
            WHERE CEDULA = @Cedula AND ID_EMPRESA <> @IDEmpresa
        )
        BEGIN
            THROW 50002, 'La cédula ingresada ya existe.', 1;
        END
        IF NOT EXISTS (SELECT 1 FROM dbo.DIRECCION WHERE ID_DIRECCION = @IDDireccion)
        BEGIN
            THROW 50001, 'El ID de dirección proporcionado no existe.', 1;
        END
        IF @Correo NOT LIKE '%_@__%._%'
        BEGIN
            THROW 50009, 'El formato del correo electrónico es inválido.', 1;
        END
        UPDATE dbo.EMPRESAEMISORA
        SET 
            CEDULA = TRIM(TRIM(@Cedula)),
            NOMBRE_COMERCIAL = TRIM(TRIM(@NombreComercial)),
            RAZON_SOCIAL = TRIM(TRIM(@RazonSocial)),
            ID_DIRECCION = @IDDireccion,
            TELEFONO = TRIM(TRIM(@Telefono)),
            CORREO = LOWER(TRIM(TRIM(@Correo))),
            ACTIVA = @Activa
        WHERE ID_EMPRESA = @IDEmpresa;
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50010, 'La actualización falló', 1;
        END
        COMMIT TRANSACTION;
        SELECT 
            E.ID_EMPRESA,
            E.CEDULA,
            E.NOMBRE_COMERCIAL,
            E.RAZON_SOCIAL,
            E.ID_DIRECCION,
            D.PROVINCIA,
            D.CANTON,
            D.DISTRITO,
            D.SENAS_ADICIONALES,
            E.TELEFONO,
            E.CORREO,
            E.FECHA_CREACION,
            E.ACTIVA
        FROM dbo.EMPRESAEMISORA E
        INNER JOIN dbo.DIRECCION D ON E.ID_DIRECCION = D.ID_DIRECCION
        WHERE E.ID_EMPRESA = @IDEmpresa;
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
