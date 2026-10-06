USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('DBO.PR_CARGARPRODUCTOSMASIVOTMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_CARGARPRODUCTOSMASIVOTMP;
GO

CREATE PROCEDURE DBO.PR_CARGARPRODUCTOSMASIVOTMP
    @CANTIDAD INT = 1000
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAXCODIGOACTUAL INT;
    SELECT @MAXCODIGOACTUAL = ISNULL(MAX(CODIGO_ID), 0)
    FROM DBO.PRODUCTO;

    BEGIN TRY
        BEGIN TRANSACTION;

        WITH NUMEROS AS (
            SELECT TOP (@CANTIDAD)
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
            FROM SYS.ALL_OBJECTS AS A
            CROSS JOIN SYS.ALL_OBJECTS AS B
        )

        INSERT INTO DBO.PRODUCTO (
            CODIGO_ID,
            DESCRIPCION,
            PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO,
            STOCK_ACTUAL,
            STOCK_MINIMO,
            ESTADO
        )
        SELECT (@MAXCODIGOACTUAL + NUMEROS.N) AS CODIGO_ID,
            CONCAT(
                CASE (NUMEROS.N % 13)
                    WHEN 1 THEN 'Arroz'
                    WHEN 2 THEN 'Frijoles Negros'
                    WHEN 3 THEN 'Aceite Vegetal'
                    WHEN 4 THEN 'Detergente Líquido'
                    WHEN 5 THEN 'Café Molido'
                    WHEN 6 THEN 'Atún en Agua'
                    WHEN 7 THEN 'Leche Semidescremada'
                    WHEN 8 THEN 'Pasta Espagueti'
                    WHEN 9 THEN 'Jabón de Baño'
                    WHEN 10 THEN 'Shampoo'
                    WHEN 11 THEN 'Alimento para Perro'
                    WHEN 12 THEN 'Galletas de Chocolate'
                    ELSE 'Jugo de Naranja'
                END,
                ' ',
                CASE ((NUMEROS.N * 3) % 11)
                    WHEN 1 THEN 'Tío Pelón'
                    WHEN 2 THEN 'Don Pedro'
                    WHEN 3 THEN 'Suli'
                    WHEN 4 THEN 'Clover'
                    WHEN 5 THEN 'Pozuelo'
                    WHEN 6 THEN 'Roma'
                    WHEN 7 THEN 'Dos Pinos'
                    WHEN 8 THEN 'Bioland'
                    WHEN 9 THEN 'Procan'
                    WHEN 10 THEN 'Rumba'
                    ELSE 'Natura'
                END,
                ' ',
                CASE ((NUMEROS.N * 5) % 7)
                    WHEN 1 THEN '1 kg'
                    WHEN 2 THEN '500 g'
                    WHEN 3 THEN '1.5 L'
                    WHEN 4 THEN '750 ml'
                    WHEN 5 THEN 'Pack x3'
                    WHEN 6 THEN 'Bolsa Familiar'
                    ELSE 'Lata 170g'
                END
            ) AS DESCRIPCION,
            CAST(
                (((NUMEROS.N * 173) % 18500) + 450) AS DECIMAL(18, 2)
            ) AS PRECIO_UNITARIO,
            13.00 AS PORCENTAJE_IMPUESTO,
            ((NUMEROS.N * 29) % 335) + 15 AS STOCK_ACTUAL,
            10 AS STOCK_MINIMO,
            1 AS ESTADO
        FROM NUMEROS;

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

EXEC DBO.PR_CARGARPRODUCTOSMASIVOTMP @CANTIDAD = 1000;
PRINT 'Carga masiva de productos completada con éxito.';
GO

IF OBJECT_ID('DBO.PR_CARGARPRODUCTOSMASIVOTMP', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_CARGARPRODUCTOSMASIVOTMP;
GO
