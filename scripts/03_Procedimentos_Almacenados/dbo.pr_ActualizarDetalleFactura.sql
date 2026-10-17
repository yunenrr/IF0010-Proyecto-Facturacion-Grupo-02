USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARDETALLEFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARDETALLEFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARDETALLEFACTURA
    @CODIGO_FACTURA INT,
    @ID_DETALLE INT,
    @CANTIDAD DECIMAL(12, 2),
    @PORCENTAJE_DESCUENTO DECIMAL(5, 2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DETALLEFACTURA
                WHERE
                    CODIGO_FACTURA = @CODIGO_FACTURA
                    AND ID_DETALLE = @ID_DETALLE
            )
            BEGIN
                THROW 50071, 'El detalle especificado no existe.', 1;
            END;

        IF @CANTIDAD <= 0
            BEGIN
                THROW 50072, 'La cantidad debe ser mayor a cero.', 1;
            END;

        IF @PORCENTAJE_DESCUENTO NOT BETWEEN 0 AND 100
            BEGIN
                THROW
                50073,
                'El porcentaje de descuento debe estar entre 0 y 100.',
                1;
            END;

        UPDATE DBO.DETALLEFACTURA
        SET
            CANTIDAD = @CANTIDAD,
            PORCENTAJE_DESCUENTO = @PORCENTAJE_DESCUENTO,
            SUBTOTAL_LINEA = ROUND(@CANTIDAD * PRECIO_UNITARIO, 2),
            MONTO_DESCUENTO = ROUND(
                @CANTIDAD * PRECIO_UNITARIO
                * @PORCENTAJE_DESCUENTO / 100.00,
                2
            ),
            MONTO_IMPUESTO = ROUND(
                @CANTIDAD * PRECIO_UNITARIO
                * (1 - @PORCENTAJE_DESCUENTO / 100.00)
                * PORCENTAJE_IMPUESTO / 100.00,
                2
            ),
            MONTO_TOTAL_LINEA = ROUND(
                @CANTIDAD * PRECIO_UNITARIO
                * (1 - @PORCENTAJE_DESCUENTO / 100.00)
                * (1 + PORCENTAJE_IMPUESTO / 100.00),
                2
            )
        WHERE
            CODIGO_FACTURA = @CODIGO_FACTURA
            AND ID_DETALLE = @ID_DETALLE;

        UPDATE F
        SET
            F.SUBTOTAL = T.SUBTOTALSUM,
            F.TOTAL_DESCUENTOS = T.DESCUENTOSUM,
            F.TOTAL_IMPUESTOS = T.IMPUESTOSUM,
            F.MONTO_TOTAL = T.TOTALSUM,
            F.UPDATED_AT = SYSDATETIME()
        FROM DBO.FACTURA AS F
        INNER JOIN (
            SELECT
                CODIGO_FACTURA,
                SUM(SUBTOTAL_LINEA) AS SUBTOTALSUM,
                SUM(MONTO_DESCUENTO) AS DESCUENTOSUM,
                SUM(MONTO_IMPUESTO) AS IMPUESTOSUM,
                SUM(MONTO_TOTAL_LINEA) AS TOTALSUM
            FROM DBO.DETALLEFACTURA
            WHERE CODIGO_FACTURA = @CODIGO_FACTURA
            GROUP BY CODIGO_FACTURA
        ) AS T
            ON F.CODIGO_FACTURA = T.CODIGO_FACTURA;

        COMMIT TRANSACTION;
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
