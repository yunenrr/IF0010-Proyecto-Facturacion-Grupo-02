USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRARDETALLEFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRARDETALLEFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRARDETALLEFACTURA
    @CODIGOFACTURA INT,
    @CODIGOPRODUCTO INT,
    @CANTIDAD DECIMAL(12, 2),
    @PORCENTAJEDESCUENTO DECIMAL(5, 2) = 0.00
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.FACTURA
                WHERE CODIGO_FACTURA = @CODIGOFACTURA
            )
            BEGIN
                THROW
                50130,
                'La Factura especificada no existe en la base de datos.',
                1;
            END;

        DECLARE @DESCRIPCIONPROD VARCHAR(255);
        DECLARE @PRECIOUNITARIO DECIMAL(18, 2);
        DECLARE @PORCENTAJEIMPUESTO DECIMAL(5, 2);
        DECLARE @STOCKACTUAL INT;

        SELECT
            @DESCRIPCIONPROD = DESCRIPCION,
            @PRECIOUNITARIO = PRECIO_UNITARIO,
            @PORCENTAJEIMPUESTO = PORCENTAJE_IMPUESTO,
            @STOCKACTUAL = STOCK_ACTUAL
        FROM DBO.PRODUCTO
        WHERE
            CODIGO_ID = @CODIGOPRODUCTO
            AND ESTADO = 1;

        IF @DESCRIPCIONPROD IS NULL
            BEGIN
                THROW
                50131,
                'El Producto especificado no existe o no se encuentra activo',
                1;
            END;

        IF @CANTIDAD <= 0
            BEGIN
                THROW
                50132,
                'La cantidad del producto debe ser mayor a 0.',
                1;
            END;

        IF @STOCKACTUAL < @CANTIDAD
            BEGIN
                THROW
                50064,
                'Stock insuficiente para registrar este detalle de factura.',
                1;
            END;

        DECLARE @SIGUIENTELINEA INT;

        SELECT @SIGUIENTELINEA = ISNULL(MAX(NUMERO_LINEA), 0) + 1
        FROM DBO.DETALLE_FACTURA
        WHERE CODIGO_FACTURA = @CODIGOFACTURA;

        DECLARE @SUBTOTALLINEA DECIMAL(18, 2);
        DECLARE @MONTODESCUENTO DECIMAL(18, 2);
        DECLARE @SUBTOTALDESCUENTO DECIMAL(18, 2);
        DECLARE @MONTOIMPUESTO DECIMAL(18, 2);
        DECLARE @MONTOTOTALLINEA DECIMAL(18, 2);

        SET @SUBTOTALLINEA = ROUND(@CANTIDAD * @PRECIOUNITARIO, 2);
        SET
            @MONTODESCUENTO = ROUND(
                @SUBTOTALLINEA * (@PORCENTAJEDESCUENTO / 100.00),
                2
            );
        SET @SUBTOTALDESCUENTO = @SUBTOTALLINEA - @MONTODESCUENTO;
        SET
            @MONTOIMPUESTO = ROUND(
                @SUBTOTALDESCUENTO * (@PORCENTAJEIMPUESTO / 100.00),
                2
            );
        SET @MONTOTOTALLINEA = @SUBTOTALDESCUENTO + @MONTOIMPUESTO;

        INSERT INTO DBO.DETALLE_FACTURA (
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
            @CODIGOFACTURA,
            @CODIGOPRODUCTO,
            @SIGUIENTELINEA,
            @DESCRIPCIONPROD,
            @CANTIDAD,
            @PRECIOUNITARIO,
            @PORCENTAJEDESCUENTO,
            @PORCENTAJEIMPUESTO,
            @SUBTOTALLINEA,
            @MONTODESCUENTO,
            @MONTOIMPUESTO,
            @MONTOTOTALLINEA
        );

        COMMIT TRANSACTION;

        SELECT
            DF.CODIGO_FACTURA,
            DF.ID_DETALLE,
            DF.NUMERO_LINEA,
            DF.CODIGO_PRODUCTO,
            DF.DESCRIPCION,
            DF.CANTIDAD,
            DF.PRECIO_UNITARIO,
            DF.PORCENTAJE_DESCUENTO,
            DF.MONTO_DESCUENTO,
            DF.PORCENTAJE_IMPUESTO,
            DF.MONTO_IMPUESTO,
            DF.SUBTOTAL_LINEA,
            DF.MONTO_TOTAL_LINEA
        FROM DBO.DETALLE_FACTURA AS DF
        WHERE
            DF.CODIGO_FACTURA = @CODIGOFACTURA
            AND DF.NUMERO_LINEA = @SIGUIENTELINEA;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        THROW;
    END CATCH;
END;
GO
