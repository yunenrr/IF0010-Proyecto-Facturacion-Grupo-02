USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('DBO.PR_CARGARDATOSFACTURASYDETALLESTMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_CARGARDATOSFACTURASYDETALLESTMP;
GO

CREATE PROCEDURE DBO.PR_CARGARDATOSFACTURASYDETALLESTMP
    @TotalFacturas INT = 500000,
    @TamanoLote INT = 10000
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @FacturasProcesadas INT = 0;
    DECLARE @FechaInicio DATETIME2;
    DECLARE @MaxCodigoActual INT;

    SET @FechaInicio = DATEADD(YEAR, -1, SYSDATETIME());

    SELECT @MaxCodigoActual = ISNULL(MAX(CODIGO_FACTURA), 0)
    FROM DBO.FACTURA;

    CREATE TABLE #Numeros (N INT);

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

            TRUNCATE TABLE #Numeros;
            TRUNCATE TABLE #LoteFacturas;
            TRUNCATE TABLE #LoteDetalles;

            ;WITH SECUENCIA AS (
                SELECT TOP (@TamanoLote)
                    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
                FROM SYS.ALL_OBJECTS AS A
                CROSS JOIN SYS.ALL_OBJECTS AS B
            )
            INSERT INTO #Numeros (N)
            SELECT N
            FROM SECUENCIA;

            INSERT INTO #LoteFacturas (
                CODIGO_FACTURA,
                ID_EMPRESA,
                ID_CLIENTE,
                ID_TIPO_DOCUMENTO,
                CODIGO_DIVISA,
                ID_ESTADO,
                IDENTIFICADOR_COMPROBANTE,
                FECHA_EMISION
            )
            SELECT
                @MaxCodigoActual + @FacturasProcesadas + N.N,
                ((N.N * 17) % 100) + 1,
                ((N.N * 31) % 50000) + 1,
                ((N.N % 4) + 1),
                CASE WHEN (N.N % 2) = 0 THEN 'CRC' ELSE 'USD' END,
                ((N.N % 4) + 1),
                CONCAT(
                    FORMAT(
                        DATEADD(
                            SECOND,
                            (N.N + @FacturasProcesadas) * 60,
                            @FechaInicio
                        ),
                        'yyyyMMddHHmmss'
                    ),
                    '-',
                    ((N.N % 4) + 1)
                ),
                DATEADD(
                    SECOND,
                    (N.N + @FacturasProcesadas) * 60,
                    @FechaInicio
                )
            FROM #Numeros AS N;

            INSERT INTO #LoteDetalles (
                CODIGO_FACTURA,
                NUMERO_LINEA,
                CODIGO_PRODUCTO,
                DESCRIPCION,
                CANTIDAD,
                PRECIO_UNITARIO,
                PORCENTAJE_IMPUESTO,
                SUBTOTAL_LINEA,
                MONTO_IMPUESTO,
                MONTO_TOTAL_LINEA
            )
            SELECT
                F.CODIGO_FACTURA,
                L.NUMLINEA,
                P.CODIGO_ID,
                P.DESCRIPCION,
                L.CANT,
                P.PRECIO_UNITARIO,
                P.PORCENTAJE_IMPUESTO,
                CAST(
                    L.CANT * P.PRECIO_UNITARIO AS DECIMAL(18, 2)
                ),
                CAST(
                    L.CANT * P.PRECIO_UNITARIO
                    * P.PORCENTAJE_IMPUESTO / 100.00
                    AS DECIMAL(18, 2)
                ),
                CAST(
                    L.CANT * P.PRECIO_UNITARIO
                    * (1 + P.PORCENTAJE_IMPUESTO / 100.00)
                    AS DECIMAL(18, 2)
                )
            FROM #LoteFacturas AS F
            CROSS JOIN (VALUES (1), (2), (3), (4), (5)) AS X(NUMLINEA)
            CROSS APPLY (
                SELECT
                    X.NUMLINEA AS NUMLINEA,
                    (
                        (F.CODIGO_FACTURA * 13 + X.NUMLINEA * 7) % 1000
                    ) + 1 AS CODIGOPROD,
                    (
                        (F.CODIGO_FACTURA * 3 + X.NUMLINEA) % 5
                    ) + 1 AS CANT
            ) AS L
            INNER JOIN DBO.PRODUCTO AS P
                ON L.CODIGOPROD = P.CODIGO_ID
            WHERE
                X.NUMLINEA <= 3
                OR (
                    X.NUMLINEA = 4
                    AND (F.CODIGO_FACTURA % 2) = 0
                )
                OR (
                    X.NUMLINEA = 5
                    AND (F.CODIGO_FACTURA % 3) = 0
                );

            UPDATE F
            SET
                F.SUBTOTAL = T.SUBTOTALSUM,
                F.TOTAL_IMPUESTOS = T.IMPUESTOSUM,
                F.MONTO_TOTAL = T.TOTALSUM
            FROM #LoteFacturas AS F
            INNER JOIN (
                SELECT
                    CODIGO_FACTURA,
                    SUM(SUBTOTAL_LINEA) AS SUBTOTALSUM,
                    SUM(MONTO_IMPUESTO) AS IMPUESTOSUM,
                    SUM(MONTO_TOTAL_LINEA) AS TOTALSUM
                FROM #LoteDetalles
                GROUP BY CODIGO_FACTURA
            ) AS T
                ON F.CODIGO_FACTURA = T.CODIGO_FACTURA;

            INSERT INTO DBO.FACTURA (
                CODIGO_FACTURA,
                IDENTIFICADOR_COMPROBANTE,
                ID_EMPRESA,
                ID_CLIENTE,
                ID_TIPO_DOCUMENTO,
                CODIGO_DIVISA,
                ID_ESTADO,
                FECHA_EMISION,
                SUBTOTAL,
                TOTAL_IMPUESTOS,
                MONTO_TOTAL
            )
            SELECT
                CODIGO_FACTURA,
                IDENTIFICADOR_COMPROBANTE,
                ID_EMPRESA,
                ID_CLIENTE,
                ID_TIPO_DOCUMENTO,
                CODIGO_DIVISA,
                ID_ESTADO,
                FECHA_EMISION,
                SUBTOTAL,
                TOTAL_IMPUESTOS,
                MONTO_TOTAL
            FROM #LoteFacturas;

            INSERT INTO DBO.DETALLEFACTURA (
                CODIGO_FACTURA,
                NUMERO_LINEA,
                CODIGO_PRODUCTO,
                DESCRIPCION,
                CANTIDAD,
                PRECIO_UNITARIO,
                PORCENTAJE_IMPUESTO,
                SUBTOTAL_LINEA,
                MONTO_IMPUESTO,
                MONTO_TOTAL_LINEA
            )
            SELECT
                CODIGO_FACTURA,
                NUMERO_LINEA,
                CODIGO_PRODUCTO,
                DESCRIPCION,
                CANTIDAD,
                PRECIO_UNITARIO,
                PORCENTAJE_IMPUESTO,
                SUBTOTAL_LINEA,
                MONTO_IMPUESTO,
                MONTO_TOTAL_LINEA
            FROM #LoteDetalles;

            COMMIT TRANSACTION;

            SET @FacturasProcesadas
                = @FacturasProcesadas + @TamanoLote;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;

            THROW;
        END CATCH
    END;

    DROP TABLE #Numeros;
    DROP TABLE #LoteFacturas;
    DROP TABLE #LoteDetalles;
END;
GO

EXEC DBO.PR_CARGARDATOSFACTURASYDETALLESTMP
    @TotalFacturas = 500000,
    @TamanoLote = 10000;
GO

PRINT 'Carga masiva completada con exito.';
GO

IF OBJECT_ID('DBO.PR_CARGARDATOSFACTURASYDETALLESTMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_CARGARDATOSFACTURASYDETALLESTMP;
GO

PRINT 'Procedimiento temporal eliminado correctamente.';
GO
