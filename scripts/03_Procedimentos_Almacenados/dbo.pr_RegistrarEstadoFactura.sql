USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarEstadoFactura', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarEstadoFactura;
GO
CREATE PROCEDURE dbo.pr_RegistrarEstadoFactura
    @Estado VARCHAR(20),
    @DescripcionEstado VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NuevoIDEstado INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF EXISTS (SELECT 1 FROM dbo.ESTADOFACTURA WHERE ESTADO = UPPER(LTRIM(RTRIM(@Estado))))
        BEGIN
            THROW 50011, 'El nombre de estado ingresado ya existe.', 1;
        END
        IF TRIM(TRIM(@Estado)) = '' OR TRIM(TRIM(@DescripcionEstado)) = ''
        BEGIN
            THROW 50012, 'El nombre del estado y su descripción no pueden estar vacíos.', 1;
        END
        INSERT INTO dbo.ESTADOFACTURA (
            ESTADO,
            DESCRIPCION_ESTADO
        )
        VALUES (
            UPPER(TRIM(TRIM(@Estado))),
            TRIM(TRIM(@DescripcionEstado))
        );
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50013, 'No se pudo hacer el registro', 1;
        END
        SET @NuevoIDEstado = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
        SELECT 
            ID_ESTADO,
            ESTADO,
            DESCRIPCION_ESTADO
        FROM dbo.ESTADOFACTURA
        WHERE ID_ESTADO = @NuevoIDEstado;
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
