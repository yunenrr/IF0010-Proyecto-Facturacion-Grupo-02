USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARDATOSFACTURASYDETALLESTMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARDATOSFACTURASYDETALLESTMP;
    END;
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

    INSERT INTO #Numeros (N)
    SELECT TOP (@TamanoLote) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM SYS.ALL_OBJECTS AS A
    CROSS JOIN SYS.ALL_OBJECTS AS B;

    WHILE @FacturasProcesadas < @TotalFacturas
        BEGIN
            BEGIN TRY
                BEGIN TRANSACTION;

                TRUNCATE TABLE #LoteFacturas;
                TRUNCATE TABLE #LoteDetalles;

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
                    @MaxCodigoActual + @FacturasProcesadas + N.N
                        AS CODIGO_FACTURA,
                    ((N.N * 17) % 100) + 1 AS ID_EMPRESA,
                    ((N.N * 31) % 50000) + 1 AS ID_CLIENTE,
                    TD.ID_TIPO_DOCUMENTO AS ID_TIPO_DOCUMENTO,
                    CASE
                        WHEN (N.N % 2) = 0 THEN 'CRC'
                        ELSE 'USD'
                    END AS CODIGO_DIVISA,
                    ((N.N % 4) + 1) AS ID_ESTADO,
                    CONCAT(
                        CONVERT(
                            VARCHAR(8),
                            DATEADD(
                                SECOND,
                                (N.N + @FacturasProcesadas) * 60,
                                @FechaInicio
                            ),
                            112
                        ),
                        REPLACE(
                            CONVERT(
                                VARCHAR(8),
                                DATEADD(
                                    SECOND,
                                    (N.N + @FacturasProcesadas) * 60,
                                    @FechaInicio
                                ),
                                108
                            ),
                            ':',
                            ''
                        ),
                        '-',
                        TD.DESCRIPCION_TIPO_DOCUMENTO
                    ) AS IDENTIFICADOR_COMPROBANTE,
                    DATEADD(
                        SECOND,
                        (N.N + @FacturasProcesadas) * 60,
                        @FechaInicio
                    ) AS FECHA_EMISION
                FROM #Numeros AS N
                INNER JOIN DBO.TIPODOCUMENTO AS TD
                    ON ((N.N % 4) + 1) = TD.ID_TIPO_DOCUMENTO;

                WITH LINEAS AS (
                    SELECT
                        F.CODIGO_FACTURA,
                        X.NUMLINEA,
                        ((F.CODIGO_FACTURA * 13 + X.NUMLINEA * 7) % 1000)
                        + 1 AS CODIGOPROD,
                        ((F.CODIGO_FACTURA * 3 + X.NUMLINEA) % 5)
                        + 1 AS CANT
                    FROM #LoteFacturas AS F
                    CROSS JOIN (
                        VALUES (1), (2), (3), (4), (5)
                    ) AS X(NUMLINEA)
                    WHERE
                        X.NUMLINEA <= 3
                        OR (
                            X.NUMLINEA = 4
                            AND (F.CODIGO_FACTURA % 2) = 0
                        )
                        OR (
                            X.NUMLINEA = 5
                            AND (F.CODIGO_FACTURA % 3) = 0
                        )
                )

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
                    L.CODIGO_FACTURA,
                    L.NUMLINEA,
                    P.CODIGO_ID,
                    P.DESCRIPCION,
                    L.CANT,
                    P.PRECIO_UNITARIO,
                    P.PORCENTAJE_IMPUESTO,
                    CAST(
                        L.CANT * P.PRECIO_UNITARIO
                        AS DECIMAL(18, 2)
                    ) AS SUBTOTAL_LINEA,
                    CAST(
                        L.CANT * P.PRECIO_UNITARIO
                        * P.PORCENTAJE_IMPUESTO / 100.00
                        AS DECIMAL(18, 2)
                    ) AS MONTO_IMPUESTO,
                    CAST(
                        L.CANT * P.PRECIO_UNITARIO
                        * (1 + P.PORCENTAJE_IMPUESTO / 100.00)
                        AS DECIMAL(18, 2)
                    ) AS MONTO_TOTAL_LINEA
                FROM LINEAS AS L
                INNER JOIN DBO.PRODUCTO AS P
                    ON L.CODIGOPROD = P.CODIGO_ID;

                WITH TOTALES AS (
                    SELECT
                        CODIGO_FACTURA,
                        SUM(SUBTOTAL_LINEA) AS SUBTOTALSUM,
                        SUM(MONTO_IMPUESTO) AS IMPUESTOSUM,
                        SUM(MONTO_TOTAL_LINEA) AS TOTALSUM
                    FROM #LoteDetalles
                    GROUP BY CODIGO_FACTURA
                )

                UPDATE F
                SET
                    F.SUBTOTAL = T.SUBTOTALSUM,
                    F.TOTAL_IMPUESTOS = T.IMPUESTOSUM,
                    F.MONTO_TOTAL = T.TOTALSUM
                FROM #LoteFacturas AS F
                INNER JOIN TOTALES AS T
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
                    MONTO_TOTAL,
                    OBSERVACIONES
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
                    MONTO_TOTAL,
                    'N/A' AS OBSERVACIONES
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

                SET @FacturasProcesadas += @TamanoLote;
            END TRY
            BEGIN CATCH
                IF XACT_STATE() <> 0
                    BEGIN
                        ROLLBACK TRANSACTION;
                    END;

                THROW;
            END CATCH;
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

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARDATOSFACTURASYDETALLESTMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARDATOSFACTURASYDETALLESTMP;
    END;
GO

PRINT 'Procedimiento temporal eliminado correctamente.';
GO