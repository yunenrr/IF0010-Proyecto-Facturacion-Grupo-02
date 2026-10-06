USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarProducto', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarProducto;
GO
CREATE PROCEDURE dbo.pr_RegistrarProducto
    @CodigoID INT,
    @Descripcion VARCHAR(255),
    @PrecioUnitario DECIMAL(18, 2),
    @PorcentajeImpuesto DECIMAL(5, 2) = 13.00,
    @StockActual INT = 0,
    @StockMinimo INT = 0,
    @Estado INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF EXISTS (SELECT 1 FROM dbo.PRODUCTO WHERE CODIGO_ID = @CodigoID)
        BEGIN
            THROW 50003, 'El Código ID del producto ya existe en la base de datos.', 1;
        END
        IF @PrecioUnitario < 0
        BEGIN
            THROW 50004, 'El precio unitario no puede ser negativo.', 1;
        END
        IF @PorcentajeImpuesto < 0 OR @PorcentajeImpuesto > 100
        BEGIN
            THROW 50005, 'El porcentaje de impuesto debe estar entre 0 y 100.', 1;
        END
        IF @StockActual < 0 OR @StockMinimo < 0
        BEGIN
            THROW 50006, 'El stock actual y el stock mínimo deben ser iguales o mayores a 0.', 1;
        END
        IF @Estado NOT IN (0, 1)
        BEGIN
            THROW 50007, 'El estado del producto debe ser 1 (Activo) o 0 (Inactivo).', 1;
        END
        INSERT INTO dbo.PRODUCTO (
            CODIGO_ID,
            DESCRIPCION,
            PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO,
            STOCK_ACTUAL,
            STOCK_MINIMO,
            ESTADO,
            FECHA_CREACION
        )
        VALUES (
            @CodigoID,
            TRIM(TRIM(@Descripcion)),
            @PrecioUnitario,
            @PorcentajeImpuesto,
            @StockActual,
            @StockMinimo,
            @Estado,
            SYSDATETIME()
        );
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50025, 'No se pudo realizar el registro del producto.', 1;
        END
        COMMIT TRANSACTION;
        SELECT 
            CODIGO_ID,
            DESCRIPCION,
            PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO,
            STOCK_ACTUAL,
            STOCK_MINIMO,
            ESTADO,
            FECHA_CREACION
        FROM dbo.PRODUCTO
        WHERE CODIGO_ID = @CodigoID;
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
