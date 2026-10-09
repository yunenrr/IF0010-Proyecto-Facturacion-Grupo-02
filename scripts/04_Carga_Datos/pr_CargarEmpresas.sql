USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGAREMPRESAS'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGAREMPRESAS;
    END;
GO

CREATE PROCEDURE DBO.PR_CARGAREMPRESAS
    @CANTIDAD INT = 100
AS
BEGIN
    SET NOCOUNT ON;

    IF @CANTIDAD IS NULL OR @CANTIDAD <= 0
        BEGIN
            THROW 50001, 'La cantidad debe ser mayor a 0.', 1;
        END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ULTIMOSECUENCIAL INT = 0;

        SELECT
            @ULTIMOSECUENCIAL = ISNULL(
                MAX(
                    CAST(
                        RIGHT(
                            CEDULA,
                            LEN(CEDULA) - CHARINDEX('-101-', CEDULA) - 4
                        ) AS INT
                    )
                ), 0
            )
        FROM DBO.EMPRESAEMISORA
        WHERE
            CEDULA LIKE '%-101-%';

        WITH SECUENCIA AS (
            SELECT 1 AS NUM
            UNION ALL
            SELECT NUM + 1
            FROM SECUENCIA
            WHERE NUM < @CANTIDAD
        )

        SELECT
            NUM,
            @ULTIMOSECUENCIAL + NUM AS NUMEMPRESA,
            ((NUM - 1) % 7) + 1 AS CODIGOPROVINCIA,
            CASE ((NUM - 1) % 7) + 1
                WHEN 1 THEN 'San José'
                WHEN 2 THEN 'Alajuela'
                WHEN 3 THEN 'Cartago'
                WHEN 4 THEN 'Heredia'
                WHEN 5 THEN 'Guanacaste'
                WHEN 6 THEN 'Puntarenas'
                ELSE 'Limón'
            END AS NOMBREPROVINCIA,
            CONCAT(
                '3-101-',
                RIGHT('000000' + CAST(@ULTIMOSECUENCIAL + NUM AS VARCHAR), 6)
            ) AS CEDULAGENERADA,
            CONCAT(
                'Dirección temporal local #',
                @ULTIMOSECUENCIAL + NUM
            ) AS SENAS
        INTO #DATOSGENERADOS
        FROM SECUENCIA
        OPTION (MAXRECURSION 32767);

        INSERT INTO DBO.DIRECCION (
            PROVINCIA,
            CANTON,
            DISTRITO,
            SENAS_ADICIONALES
        )
        SELECT
            D.NOMBREPROVINCIA,
            'Cantón ' + CAST(D.NUM AS VARCHAR) AS CANTON,
            'Distrito ' + CAST(D.NUM AS VARCHAR) AS DISTRITO,
            D.SENAS AS SENAS_ADICIONALES
        FROM #DATOSGENERADOS AS D
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.EMPRESAEMISORA AS E
                WHERE E.CEDULA = D.CEDULAGENERADA
            );

        INSERT INTO DBO.EMPRESAEMISORA (
            CEDULA,
            NOMBRE_COMERCIAL,
            RAZON_SOCIAL,
            ID_DIRECCION,
            TELEFONO,
            CORREO,
            FECHA_CREACION,
            ACTIVA
        )
        SELECT
            D.CEDULAGENERADA,
            CONCAT('Empresa Comercial ', D.NUMEMPRESA, ' S.A.')
                AS NOMBRE_COMERCIAL,
            CONCAT('Corporación Soluciones ', D.NUMEMPRESA, ' S.A.')
                AS RAZON_SOCIAL,
            DIR.ID_DIRECCION,
            CONCAT('22', RIGHT('000000' + CAST(D.NUMEMPRESA AS VARCHAR), 6))
                AS TELEFONO,
            CONCAT('contacto@empresa', D.NUMEMPRESA, '.com')
                AS CORREO,
            SYSDATETIME() AS FECHA_CREACION,
            1 AS ACTIVA
        FROM #DATOSGENERADOS AS D
        INNER JOIN DBO.DIRECCION AS DIR
            ON D.SENAS = DIR.SENAS_ADICIONALES
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.EMPRESAEMISORA AS E
                WHERE E.CEDULA = D.CEDULAGENERADA
            );

        DROP TABLE #DATOSGENERADOS;

        COMMIT TRANSACTION;

        PRINT 'Carga inicial realizada con éxito.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        DECLARE @ERRORMSG NVARCHAR(4000) = ERROR_MESSAGE();

        THROW 50000, @ERRORMSG, 1;
    END CATCH;
END;
GO

EXEC DBO.PR_CARGAREMPRESAS @CANTIDAD = 100;
GO

SELECT TOP 100
    E.ID_EMPRESA,
    E.CEDULA,
    E.NOMBRE_COMERCIAL,
    E.RAZON_SOCIAL,
    E.TELEFONO,
    E.CORREO,
    D.PROVINCIA,
    D.CANTON,
    D.DISTRITO,
    D.SENAS_ADICIONALES,
    E.FECHA_CREACION,
    E.ACTIVA
FROM DBO.EMPRESAEMISORA AS E
INNER JOIN DBO.DIRECCION AS D
    ON E.ID_DIRECCION = D.ID_DIRECCION
ORDER BY E.ID_EMPRESA;
GO