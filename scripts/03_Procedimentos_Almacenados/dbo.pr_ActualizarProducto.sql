USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_ActualizarProducto' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_ActualizarProducto;
END
GO

CREATE PROCEDURE dbo.pr_ActualizarProducto
    @CODIGO_ID INT,
    @DESCRIPCION VARCHAR(255),
    @PRECIO_UNITARIO DECIMAL(18, 2),
    @PORCENTAJE_IMPUESTO DECIMAL(5, 2),
    @ESTADO INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTO WHERE CODIGO_ID = @CODIGO_ID)
            THROW 50103, 'El producto especificado no existe.', 1;

        IF @PRECIO_UNITARIO < 0
            THROW 50104, 'El precio no puede ser negativo.', 1;

        IF @PORCENTAJE_IMPUESTO NOT BETWEEN 0 AND 100
            THROW 50105, 'El porcentaje de impuesto debe estar entre 0 y 100.', 1;

        UPDATE dbo.PRODUCTO
        SET DESCRIPCION = @DESCRIPCION,
            PRECIO_UNITARIO = @PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO = @PORCENTAJE_IMPUESTO,
            ESTADO = @ESTADO
        WHERE CODIGO_ID = @CODIGO_ID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO