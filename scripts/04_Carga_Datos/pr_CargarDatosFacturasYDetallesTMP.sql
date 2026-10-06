USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_CargarDatosFacturasYDetallesTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_CargarDatosFacturasYDetallesTMP;
GO

CREATE PROCEDURE dbo.pr_CargarDatosFacturasYDetallesTMP
    @TotalFacturas INT = 500000,
    @TamanoLote INT = 10000
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FacturasProcesadas INT = 0;
    DECLARE @FechaInicio DATETIME2 = DATEADD(YEAR, -1, SYSDATETIME());
    DECLARE @MaxCodigoActual INT;

    SELECT @MaxCodigoActual = ISNULL(MAX(CODIGO_FACTURA), 0) FROM dbo.FACTURA AS F;

    -- tablas temporales de apoyo
    CREATE TABLE #LoteFacturas (
        CODIGO_FACTURA INT PRIMARY KEY,
        IDENTIFICADOR_COMPROBANTE VARCHAR(100),
        ID_EMPRESA INT,
        ID_CLIENTE INT,
        ID_TIPO_DOCUMENTO INT,
        CODIGO_DIVISA CHAR(3),
        ID_ESTADO INT,
        FECHA_EMISION DATETIME2,
        SUBTOTAL DECIMAL(18, 2) DEFAULT 0,
        TOTAL_IMPUESTOS DECIMAL(18, 2) DEFAULT 0,
        MONTO_TOTAL DECIMAL(18, 2) DEFAULT 0
    );

    CREATE TABLE #LoteDetalles (
        CODIGO_FACTURA INT,
        NUMERO_LINEA INT,
        CODIGO_PRODUCTO INT,
        DESCRIPCION VARCHAR(255),
        CANTIDAD DECIMAL(12, 2),
        PRECIO_UNITARIO DECIMAL(18, 2),
        PORCENTAJE_IMPUESTO DECIMAL(5, 2),
        SUBTOTAL_LINEA DECIMAL(18, 2),
        MONTO_IMPUESTO DECIMAL(18, 2),
        MONTO_TOTAL_LINEA DECIMAL(18, 2)
    );

    WHILE @FacturasProcesadas < @TotalFacturas
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            TRUNCATE TABLE #LoteFacturas;
            TRUNCATE TABLE #LoteDetalles;

            WITH NUMEROS AS (
                SELECT TOP (@TamanoLote) 
                    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
                FROM sys.all_objects AS A CROSS JOIN sys.all_objects AS B
            ),
            DATOSCALCULADOS AS (
                SELECT 
                    (@MaxCodigoActual + @FacturasProcesadas + N) AS CODIGO_FACTURA,
                    ((N * 17) % 100) + 1 AS ID_EMPRESA,
                    ((N * 31) % 50000) + 1 AS ID_CLIENTE,
                    ((N % 4) + 1) AS ID_TIPO_DOCUMENTO,
                    CASE WHEN (N % 2) = 0 THEN 'CRC' ELSE 'USD' END AS CODIGO_DIVISA,
                    ((N % 4) + 1) AS ID_ESTADO,
                    DATEADD(SECOND, (N + @FacturasProcesadas) * 60, @FechaInicio) AS FECHA_EMISION
                FROM NUMEROS
            )
            INSERT INTO #LoteFacturas (
                CODIGO_FACTURA, ID_EMPRESA, ID_CLIENTE, ID_TIPO_DOCUMENTO, 
                CODIGO_DIVISA, ID_ESTADO, IDENTIFICADOR_COMPROBANTE, FECHA_EMISION
            )
            SELECT 
                D.CODIGO_FACTURA,
                D.ID_EMPRESA,
                D.ID_CLIENTE,
                D.ID_TIPO_DOCUMENTO,
                D.CODIGO_DIVISA,
                D.ID_ESTADO,
                CONCAT(
                    REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(19), d.FECHA_EMISION, 120), '-', ''), ' ', ''), ':', ''), 
                    '-', 
                    TD.ID_TIPO_DOCUMENTO
                ) AS IDENTIFICADOR_COMPROBANTE,
                D.FECHA_EMISION
            FROM DatosCalculados AS D
            INNER JOIN dbo.TIPODOCUMENTO AS TD ON TD.ID_TIPO_DOCUMENTO = D.ID_TIPO_DOCUMENTO;

            INSERT INTO #LoteDetalles (
                CODIGO_FACTURA, NUMERO_LINEA, CODIGO_PRODUCTO, DESCRIPCION,
                CANTIDAD, PRECIO_UNITARIO, PORCENTAJE_IMPUESTO, SUBTOTAL_LINEA, MONTO_IMPUESTO, MONTO_TOTAL_LINEA
            )
            SELECT 
                F.CODIGO_FACTURA,
                D.NUMEROLINEA,
                p.CODIGO_ID,
                p.DESCRIPCION,
                D.CANTIDAD,
                p.PRECIO_UNITARIO,
                p.PORCENTAJE_IMPUESTO,
                CAST((d.Cantidad * p.PRECIO_UNITARIO) AS DECIMAL(18, 2)) AS SUBTOTAL_LINEA,
                CAST(((d.Cantidad * p.PRECIO_UNITARIO) * (p.PORCENTAJE_IMPUESTO / 100.00)) AS DECIMAL(18, 2)) AS MONTO_IMPUESTO,
                CAST(((d.Cantidad * p.PRECIO_UNITARIO) * (1 + (p.PORCENTAJE_IMPUESTO / 100.00))) AS DECIMAL(18, 2)) AS MONTO_TOTAL_LINEA
            FROM #LoteFacturas AS F
            CROSS APPLY (
                SELECT 
                    gs.N AS NUMEROLINEA,
                    (((F.CODIGO_FACTURA * 13 + gs.N * 7) % 1000) + 1) AS CodigoProd,
                    (((F.CODIGO_FACTURA * 3 + gs.N) % 5) + 1) AS Cantidad
                FROM (
                    SELECT 1 AS N UNION ALL SELECT 2 UNION ALL SELECT 3 
                    UNION ALL SELECT 4 WHERE (f.CODIGO_FACTURA % 2) = 0
                    UNION ALL SELECT 5 WHERE (f.CODIGO_FACTURA % 3) = 0
                ) AS GS
            ) AS D
            INNER JOIN dbo.PRODUCTO AS P ON P.CODIGO_ID = D.CodigoProd;

            UPDATE F
            SET 
                F.SUBTOTAL = T.SubtotalSum,
                F.TOTAL_IMPUESTOS = T.ImpuestoSum,
                F.MONTO_TOTAL = T.TotalSum
            FROM #LoteFacturas AS F
            INNER JOIN (
                SELECT 
                    CODIGO_FACTURA,
                    SUM(SUBTOTAL_LINEA) AS SUBTOTALSUM,
                    SUM(MONTO_IMPUESTO) AS IMPUESTOSUM,
                    SUM(MONTO_TOTAL_LINEA) AS TOTALSUM
                FROM #LoteDetalles
                GROUP BY CODIGO_FACTURA
            ) AS T ON F.CODIGO_FACTURA = T.CODIGO_FACTURA;

            INSERT INTO dbo.FACTURA (
                CODIGO_FACTURA, IDENTIFICADOR_COMPROBANTE, ID_EMPRESA, ID_CLIENTE, 
                ID_TIPO_DOCUMENTO, CODIGO_DIVISA, ID_ESTADO, FECHA_EMISION, 
                SUBTOTAL, TOTAL_IMPUESTOS, MONTO_TOTAL
            )
            SELECT 
                CODIGO_FACTURA, IDENTIFICADOR_COMPROBANTE, ID_EMPRESA, ID_CLIENTE, 
                ID_TIPO_DOCUMENTO, CODIGO_DIVISA, ID_ESTADO, FECHA_EMISION, 
                SUBTOTAL, TOTAL_IMPUESTOS, MONTO_TOTAL
            FROM #LoteFacturas;

            INSERT INTO dbo.DETALLEFACTURA (
                CODIGO_FACTURA, NUMERO_LINEA, CODIGO_PRODUCTO, DESCRIPCION, 
                CANTIDAD, PRECIO_UNITARIO, PORCENTAJE_IMPUESTO, 
                SUBTOTAL_LINEA, MONTO_IMPUESTO, MONTO_TOTAL_LINEA
            )
            SELECT 
                CODIGO_FACTURA, NUMERO_LINEA, CODIGO_PRODUCTO, DESCRIPCION, 
                CANTIDAD, PRECIO_UNITARIO, PORCENTAJE_IMPUESTO, 
                SUBTOTAL_LINEA, MONTO_IMPUESTO, MONTO_TOTAL_LINEA
            FROM #LoteDetalles;

            COMMIT TRANSACTION;

            SET @FacturasProcesadas = @FacturasProcesadas + @TamanoLote;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;

            IF OBJECT_ID('tempdb..#LoteFacturas') IS NOT NULL DROP TABLE #LoteFacturas;
            IF OBJECT_ID('tempdb..#LoteDetalles') IS NOT NULL DROP TABLE #LoteDetalles;

            THROW;
        END CATCH
    END

    DROP TABLE #LoteFacturas;
    DROP TABLE #LoteDetalles;
END;
GO

EXEC dbo.pr_CargarDatosFacturasYDetallesTMP 
    @TotalFacturas = 500000, 
    @TamanoLote = 10000;
PRINT 'Carga masiva completada con éxito.';
GO

IF OBJECT_ID('dbo.pr_CargarDatosFacturasYDetallesTMP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_CargarDatosFacturasYDetallesTMP;
GO
PRINT 'Procedimiento temporal eliminado correctamente.';
GO