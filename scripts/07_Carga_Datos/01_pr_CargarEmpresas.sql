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
    SET XACT_ABORT ON;

    IF @CANTIDAD IS NULL OR @CANTIDAD <= 0
        BEGIN
            THROW 50001, 'La cantidad debe ser mayor a 0.', 1;
        END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ULTIMOSECUENCIAL INT = 0;
        DECLARE @TOTALDISTRITOS INT;

        SELECT @TOTALDISTRITOS = COUNT(*)
        FROM DBO.DISTRITO;

        IF @TOTALDISTRITOS = 0
            BEGIN
                THROW 50036, 'No hay distritos cargados.', 1;
            END;

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
            ID_DISTRITO,
            SENAS_ADICIONALES
        )
        SELECT
            ((D.NUM * 7) % @TOTALDISTRITOS) + 1 AS ID_DISTRITO,
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
    DI.NOMBRE AS DISTRITO,
    C.NOMBRE AS CANTON,
    P.NOMBRE AS PROVINCIA,
    D.SENAS_ADICIONALES,
    E.FECHA_CREACION,
    E.ACTIVA
FROM DBO.EMPRESAEMISORA AS E
INNER JOIN DBO.DIRECCION AS D
    ON E.ID_DIRECCION = D.ID_DIRECCION
INNER JOIN DBO.DISTRITO AS DI
    ON D.ID_DISTRITO = DI.ID_DISTRITO
INNER JOIN DBO.CANTON AS C
    ON DI.ID_CANTON = C.ID_CANTON
INNER JOIN DBO.PROVINCIA AS P
    ON C.ID_PROVINCIA = P.ID_PROVINCIA
ORDER BY E.ID_EMPRESA;
GO
