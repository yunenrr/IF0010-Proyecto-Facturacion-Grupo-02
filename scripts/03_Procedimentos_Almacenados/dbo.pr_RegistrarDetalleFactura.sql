USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarDetalleFactura', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarDetalleFactura;
GO
CREATE PROCEDURE dbo.pr_RegistrarDetalleFactura
    @CodigoFactura INT,
    @CodigoProducto INT,
    @Cantidad DECIMAL(12, 2),
    @PorcentajeDescuento DECIMAL(5, 2) = 0.00
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM dbo.FACTURA WHERE CODIGO_FACTURA = @CodigoFactura)
        BEGIN
            THROW 50060, 'La Factura especificada no existe en la base de datos.', 1;
        END
        DECLARE @DescripcionProd VARCHAR(255);
        DECLARE @PrecioUnitario DECIMAL(18, 2);
        DECLARE @PorcentajeImpuesto DECIMAL(5, 2);
        DECLARE @StockActual INT;
        SELECT 
            @DescripcionProd = DESCRIPCION,
            @PrecioUnitario = PRECIO_UNITARIO,
            @PorcentajeImpuesto = PORCENTAJE_IMPUESTO,
            @StockActual = STOCK_ACTUAL
        FROM dbo.PRODUCTO
        WHERE CODIGO_ID = @CodigoProducto AND ESTADO = 1;
        IF @DescripcionProd IS NULL
        BEGIN
            THROW 50062, 'El Producto especificado no existe o no se encuentra activo', 1;
        END
        IF @Cantidad <= 0
        BEGIN
            THROW 50063, 'La cantidad del producto debe ser mayor a 0.', 1;
        END
        IF @StockActual < @Cantidad
        BEGIN
            THROW 50064, 'Stock insuficiente para registrar este detalle de factura.', 1;
        END
        DECLARE @SiguienteLinea INT;
        SELECT @SiguienteLinea = ISNULL(MAX(NUMERO_LINEA), 0) + 1
        FROM dbo.DETALLEFACTURA
        WHERE CODIGO_FACTURA = @CodigoFactura;
        DECLARE @SubtotalLinea DECIMAL(18, 2);
        DECLARE @MontoDescuento DECIMAL(18, 2);
        DECLARE @SubtotalDescuento DECIMAL(18, 2);
        DECLARE @MontoImpuesto DECIMAL(18, 2);
        DECLARE @MontoTotalLinea DECIMAL(18, 2);
        SET @SubtotalLinea = ROUND(@Cantidad * @PrecioUnitario, 2);
        SET @MontoDescuento = ROUND(@SubtotalLinea * (@PorcentajeDescuento / 100.00), 2);
        SET @SubtotalDescuento = @SubtotalLinea - @MontoDescuento;
        SET @MontoImpuesto = ROUND(@SubtotalDescuento * (@PorcentajeImpuesto / 100.00), 2);
        SET @MontoTotalLinea = @SubtotalDescuento + @MontoImpuesto;
        INSERT INTO dbo.DETALLEFACTURA (
            CODIGO_FACTURA,
            CODIGO_PRODUCTO,
            NUMERO_LINEA,
            DESCRIPCION,
            CANTIDAD,
            PRECIO_UNITARIO,
            PORCENTAJE_DESCUENTO,
            PORCENTAJE_IMPUESTO,
            SUBTOTAL_LINEA,
            MONTO_DESCUENTO,
            MONTO_IMPUESTO,
            MONTO_TOTAL_LINEA
        )
        VALUES (
            @CodigoFactura,
            @CodigoProducto,
            @SiguienteLinea,
            @DescripcionProd,
            @Cantidad,
            @PrecioUnitario,
            @PorcentajeDescuento,
            @PorcentajeImpuesto,
            @SubtotalLinea,
            @MontoDescuento,
            @MontoImpuesto,
            @MontoTotalLinea
        );
        COMMIT TRANSACTION;
        SELECT 
            D.CODIGO_FACTURA,
            D.ID_DETALLE,
            D.NUMERO_LINEA,
            D.CODIGO_PRODUCTO,
            D.DESCRIPCION,
            D.CANTIDAD,
            D.PRECIO_UNITARIO,
            D.PORCENTAJE_DESCUENTO,
            D.MONTO_DESCUENTO,
            D.PORCENTAJE_IMPUESTO,
            D.MONTO_IMPUESTO,
            D.SUBTOTAL_LINEA,
            D.MONTO_TOTAL_LINEA
        FROM dbo.DETALLEFACTURA D
        WHERE D.CODIGO_FACTURA = @CodigoFactura AND D.NUMERO_LINEA = @SiguienteLinea;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
