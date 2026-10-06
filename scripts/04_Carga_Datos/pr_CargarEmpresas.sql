 USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (
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

        CREATE TABLE #SUFIJOSCOMERCIALES (
            ID INT IDENTITY (1, 1),
            NOMBRE VARCHAR(50)
        );

        INSERT INTO #SUFIJOSCOMERCIALES (NOMBRE)
        VALUES
            ('Tecnología'),
            ('Supermercados'),
            ('Farmacias'),
            ('Librería'),
            ('Ferretería'),
            ('Restaurante'),
            ('Distribuidora'),
            ('Logística'),
            ('Consultores'),
            ('Inversiones'),
            ('Automotriz'),
            ('Servicios Digitales'),
            ('Panadería'),
            ('Agropecuaria'),
            ('Boutique');

        CREATE TABLE #SUSTANTIVOSCOMERCIALES (
            ID INT IDENTITY (1, 1),
            NOMBRE VARCHAR(50)
        );

        INSERT INTO #SUSTANTIVOSCOMERCIALES (NOMBRE)
        VALUES
            ('El Sol'),
            ('La Estrella'),
            ('San José'),
            ('Del Caribe'),
            ('Del Valle'),
            ('Central'),
            ('Costarricense'),
            ('Irazú'),
            ('Arenal'),
            ('Tropicana'),
            ('La Paz'),
            ('Monteverde'),
            ('Poás'),
            ('La Sabana'),
            ('Pacífico');

        DECLARE @ULTIMOSECUENCIAL INT = 0;

        SELECT
            @ULTIMOSECUENCIAL = ISNULL(
                MAX(CAST(RIGHT(CEDULA, 6) AS INT)), 0
            )
        FROM DBO.EMPRESAEMISORA
        WHERE
            CEDULA LIKE '%-101-%';

        DECLARE @I INT = 1;
        DECLARE @NUMEMPRESA INT;
        DECLARE @CODIGOPROVINCIA INT;
        DECLARE @MOD4 INT;
        DECLARE @PROVINCIA VARCHAR(50);
        DECLARE @CANTON VARCHAR(50);
        DECLARE @DISTRITO VARCHAR(50);
        DECLARE @SENAS VARCHAR(255);
        DECLARE @NOMBREBASE VARCHAR(100);
        DECLARE @NOMBRECOMERCIAL VARCHAR(150);
        DECLARE @RAZONSOCIAL VARCHAR(150);
        DECLARE @CORREO VARCHAR(100);
        DECLARE @TELEFONO VARCHAR(20);
        DECLARE @NUEVOIDDIRECCION INT;
        DECLARE @SUFIJO VARCHAR(20);
        DECLARE @TIPO_SOCIEDAD VARCHAR(30);

        WHILE @I <= @CANTIDAD
        BEGIN
            SET @NUMEMPRESA = @ULTIMOSECUENCIAL + @I;
            SET @CODIGOPROVINCIA = ((@I - 1) % 7) + 1;
            SET @MOD4 = @I % 4;

            SET @PROVINCIA = CASE @CODIGOPROVINCIA
                WHEN 1
                    THEN 'San José'
                WHEN 2
                    THEN 'Alajuela'
                WHEN 3
                    THEN 'Cartago'
                WHEN 4
                    THEN 'Heredia'
                WHEN 5
                    THEN 'Guanacaste'
                WHEN 6
                    THEN 'Puntarenas'
                ELSE 'Limón'
            END;

            IF @CODIGOPROVINCIA = 1
                SET @CANTON = CASE @MOD4
                    WHEN 0
                        THEN 'San José'
                    WHEN 1
                        THEN 'Escazú'
                    WHEN 2
                        THEN 'Desamparados'
                    ELSE 'Pérez Zeledón'
                END;
            ELSE IF @CODIGOPROVINCIA = 2
                SET @CANTON = CASE @MOD4
                    WHEN 0
                        THEN 'Alajuela'
                    WHEN 1
                        THEN 'San Ramón'
                    WHEN 2
                        THEN 'Grecia'
                    ELSE 'San Carlos'
                END;
            ELSE IF @CODIGOPROVINCIA = 3
                SET @CANTON = CASE @MOD4
                    WHEN 0
                        THEN 'Cartago'
                    WHEN 1
                        THEN 'Paraíso'
                    WHEN 2
                        THEN 'La Unión'
                    ELSE 'El Guarco'
                END;
            ELSE IF @CODIGOPROVINCIA = 4
                SET @CANTON = CASE @MOD4
                    WHEN 0
                        THEN 'Heredia'
                    WHEN 1
                        THEN 'Barva'
                    WHEN 2
                        THEN 'Santo Domingo'
                    ELSE 'Belén'
                END;
            ELSE IF @CODIGOPROVINCIA = 5
                SET @CANTON = CASE @MOD4
                    WHEN 0
                        THEN 'Liberia'
                    WHEN 1
                        THEN 'Nicoya'
                    WHEN 2
                        THEN 'Santa Cruz'
                    ELSE 'Bagaces'
                END;
            ELSE IF @CODIGOPROVINCIA = 6
                SET @CANTON = CASE @MOD4
                    WHEN 0
                        THEN 'Puntarenas'
                    WHEN 1
                        THEN 'Esparza'
                    WHEN 2
                        THEN 'Quepos'
                    ELSE 'Golfito'
                END;
            ELSE
                SET @CANTON = CASE @MOD4
                    WHEN 0
                        THEN 'Limón'
                    WHEN 1
                        THEN 'Pocoçí'
                    WHEN 2
                        THEN 'Siquirres'
                    ELSE 'Talamanca'
                END;

            IF @CODIGOPROVINCIA = 1
                SET @DISTRITO = CASE @MOD4
                    WHEN 0
                        THEN 'Carmen'
                    WHEN 1
                        THEN 'San Rafael'
                    WHEN 2
                        THEN 'San Antonio'
                    ELSE 'San Isidro'
                END;
            ELSE IF @CODIGOPROVINCIA = 2
                SET @DISTRITO = CASE @MOD4
                    WHEN 0
                        THEN 'San José'
                    WHEN 1
                        THEN 'Santiago'
                    WHEN 2
                        THEN 'San Roque'
                    ELSE 'Quesada'
                END;
            ELSE IF @CODIGOPROVINCIA = 3
                SET @DISTRITO = CASE @MOD4
                    WHEN 0
                        THEN 'Oriental'
                    WHEN 1
                        THEN 'Orosi'
                    WHEN 2
                        THEN 'Tres Ríos'
                    ELSE 'Tejar'
                END;
            ELSE IF @CODIGOPROVINCIA = 4
                SET @DISTRITO = CASE @MOD4
                    WHEN 0
                        THEN 'Mercedes'
                    WHEN 1
                        THEN 'San Pedro'
                    WHEN 2
                        THEN 'Santa Rosa'
                    ELSE 'San Antonio'
                END;
            ELSE IF @CODIGOPROVINCIA = 5
                SET @DISTRITO = CASE @MOD4
                    WHEN 0
                        THEN 'Liberia'
                    WHEN 1
                        THEN 'Mansión'
                    WHEN 2
                        THEN 'Tamarindo'
                    ELSE 'Bagaces'
                END;
            ELSE IF @CODIGOPROVINCIA = 6
                SET @DISTRITO = CASE @MOD4
                    WHEN 0
                        THEN 'Chacarita'
                    WHEN 1
                        THEN 'Espíritu Santo'
                    WHEN 2
                        THEN 'Manuel Antonio'
                    ELSE 'Golfito'
                END;
            ELSE
                SET @DISTRITO = CASE @MOD4
                    WHEN 0
                        THEN 'Limón'
                    WHEN 1
                        THEN 'Guápiles'
                    WHEN 2
                        THEN 'Siquirres'
                    ELSE 'Puerto Viejo'
                END;

            SET @SENAS = CASE (@I % 5)
                WHEN 0
                    THEN CONCAT(
                        CAST((@I % 300) + 25 AS VARCHAR),
                        'm oeste del parque central, local #',
                        CAST((@I % 15) + 1 AS VARCHAR)
                    )
                WHEN 1
                    THEN CONCAT(
                        'Contiguo a Banco Nacional, edif. ',
                        CHAR(65 + (@I % 5)),
                        ', piso ',
                        CAST((@I % 4) + 1 AS VARCHAR)
                    )
                WHEN 2
                    THEN '100m norte y 50m este de la iglesia'
                WHEN 3
                    THEN CONCAT(
                        'Oficentro, Torre ',
                        CAST((@I % 3) + 1 AS VARCHAR),
                        ', ofic. ',
                        CAST((@I % 20) + 101 AS VARCHAR)
                    )
                ELSE CONCAT(
                    'Frente a gasolinera, local #',
                    CAST((@I % 10) + 1 AS VARCHAR)
                )
            END;

            SELECT TOP 1
                @NOMBREBASE = CONCAT(S.NOMBRE, ' ', N.NOMBRE)
            FROM #SUFIJOSCOMERCIALES AS S, #SUSTANTIVOSCOMERCIALES AS N
            ORDER BY NEWID();

            SET @SUFIJO = CASE (@I % 3)
                WHEN 0
                    THEN 'CR'
                WHEN 1
                    THEN 'Tropic'
                ELSE 'Solutions'
            END;

            SET @NOMBRECOMERCIAL = CONCAT(@NOMBREBASE, ' ', @SUFIJO);

            SET @TIPO_SOCIEDAD = CASE (@I % 3)
                WHEN 0
                    THEN ' Sociedad Anónima'
                WHEN 1
                    THEN ' S.A.'
                ELSE ' Limitada'
            END;

            SET @RAZONSOCIAL = CONCAT(
                'Corporación ', @NOMBREBASE, @TIPO_SOCIEDAD
            );

            SET @CORREO = CONCAT(
                LOWER(
                    REPLACE(
                        REPLACE(
                            REPLACE(@NOMBREBASE, ' ', ''),
                            'ñ',
                            'n'
                        ),
                        'á',
                        'a'
                    )
                ),
                CAST(@NUMEMPRESA AS VARCHAR),
                '@empresa.cr'
            );

            SET @TELEFONO = CONCAT(
                CASE (@I % 3)
                    WHEN 0
                        THEN '22'
                    WHEN 1
                        THEN '25'
                    ELSE '40'
                END,
                RIGHT(
                    CONCAT(
                        '000000',
                        CAST((@I * 387) + 1234 AS VARCHAR)
                    ),
                    6
                )
            );

            INSERT INTO DBO.DIRECCION (
                PROVINCIA,
                CANTON,
                DISTRITO,
                SENAS_ADICIONALES
            )
            VALUES (
                @PROVINCIA,
                @CANTON,
                @DISTRITO,
                @SENAS
            );

            SET @NUEVOIDDIRECCION = SCOPE_IDENTITY();

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
            VALUES (
                CONCAT(
                    CAST(@CODIGOPROVINCIA AS VARCHAR),
                    '-101-',
                    RIGHT(
                        CONCAT(
                            '000000',
                            CAST(@NUMEMPRESA AS VARCHAR)
                        ),
                        6
                    )
                ),
                @NOMBRECOMERCIAL,
                @RAZONSOCIAL,
                @NUEVOIDDIRECCION,
                @TELEFONO,
                @CORREO,
                SYSDATETIME(),
                1
            );

            SET @I = @I + 1;
        END;

        DROP TABLE #SUFIJOSCOMERCIALES;
        DROP TABLE #SUSTANTIVOSCOMERCIALES;

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

SELECT
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
ORDER BY E.ID_EMPRESA DESC;
GO
