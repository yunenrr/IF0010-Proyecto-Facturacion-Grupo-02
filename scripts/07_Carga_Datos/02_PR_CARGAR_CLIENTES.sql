USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARCLIENTES'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARCLIENTES;
    END;
GO

CREATE PROCEDURE DBO.PR_CARGARCLIENTES
    @CANTIDAD INT = 50000
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE #NOMBRES (NOMBRE VARCHAR(30));
        INSERT INTO #NOMBRES (NOMBRE)
        VALUES
        ('Carlos'),
        ('Ana'),
        ('Luis'),
        ('María'),
        ('Armando'),
        ('Sofía'),
        ('Pedro'),
        ('Lucía'),
        ('Diego'),
        ('Yunen'),
        ('Fernando'),
        ('Valeria'),
        ('José'),
        ('Camila'),
        ('Lou'),
        ('Paula'),
        ('Gabriel'),
        ('Daniela'),
        ('Andrés'),
        ('Natalia'),
        ('Alejandro'),
        ('Mariana'),
        ('Esteban'),
        ('Siani'),
        ('Sébastian'),
        ('Jimena'),
        ('Adrian'),
        ('Fabiola'),
        ('Kary'),
        ('Sonia');

        CREATE TABLE #APELLIDOS (APELLIDO VARCHAR(30));
        INSERT INTO #APELLIDOS (APELLIDO)
        VALUES
        ('Rodríguez'),
        ('Gómez'),
        ('López'),
        ('González'),
        ('Martínez'),
        ('Pérez'),
        ('Sánchez'),
        ('Ramírez'),
        ('Torres'),
        ('Flores'),
        ('Vargas'),
        ('Castro'),
        ('Villanueva'),
        ('Herrera'),
        ('Jiménez'),
        ('Reyes'),
        ('Díaz'),
        ('Mendoza'),
        ('Aguilar'),
        ('Rojas'),
        ('Araya'),
        ('Fonseca'),
        ('Chaves'),
        ('Solano'),
        ('Campos'),
        ('Monge'),
        ('Soto'),
        ('Arauz'),
        ('Gutiérrez');

        CREATE TABLE #GIROS (GIRO VARCHAR(30));
        INSERT INTO #GIROS (GIRO)
        VALUES
        ('Comercial'),
        ('Distribuidora'),
        ('Servicios'),
        ('Inversiones'),
        ('Importadora'),
        ('Ferretería'),
        ('Supermercados'),
        ('Tecnología');

        CREATE TABLE #DOMINIOS (DOMINIO VARCHAR(20));
        INSERT INTO #DOMINIOS (DOMINIO)
        VALUES
        ('gmail.com'),
        ('outlook.com'),
        ('hotmail.com'),
        ('yahoo.es'),
        ('icloud.com'),
        ('empresa.cr');

        CREATE TABLE #SENAS (SENA VARCHAR(100));
        INSERT INTO #SENAS (SENA)
        VALUES
        ('De la iglesia católica 200m Norte y 50m Este'),
        ('Contiguo al Ebais, casa color blanco con rejas negras'),
        ('Del parque central 100m Sur, frente al abastecedor'),
        ('Condominio Los Azahares, casa #'),
        ('Urbanización El Pilar, de la pulpería 75m Oeste'),
        ('Residencial Altamira, 50m Este de la plaza de deportes'),
        ('Calle principal, contiguo a la escuela primaria'),
        ('150m Oeste del supermercado local, casa esquina');

        DECLARE @BASECONTADOR INT;
        SELECT @BASECONTADOR = ISNULL(MAX(ID_CLIENTE), 0)
        FROM DBO.CLIENTE;

        DECLARE @TOTALDISTRITOS INT;
        SELECT @TOTALDISTRITOS = COUNT(*)
        FROM DBO.DISTRITO;

        IF @TOTALDISTRITOS = 0
            BEGIN
                THROW 50036, 'No hay distritos cargados.', 1;
            END;

        DECLARE @I INT = 1;
        DECLARE @NUEVOIDDIRECCION INT;
        DECLARE @IDDISTRITO INT;
        DECLARE @CODIGOPROVINCIA INT;
        DECLARE @FILASINSERTADAS INT = 0;
        DECLARE @CORREOALEATORIO VARCHAR(75);
        DECLARE @NOMTEMP VARCHAR(30);
        DECLARE @APE1TEMP VARCHAR(30);
        DECLARE @APE2TEMP VARCHAR(30);
        DECLARE @GIROTEMP VARCHAR(30);
        DECLARE @DOMTEMP VARCHAR(20);
        DECLARE @CEDULA VARCHAR(20);
        DECLARE @SENATEMP VARCHAR(100);
        DECLARE @NUEVOIDCLIENTE INT;
        DECLARE @ESJURIDICO BIT;

        WHILE @I <= @CANTIDAD
            BEGIN
                SET @ESJURIDICO = CASE WHEN @I % 10 = 0 THEN 1 ELSE 0 END;
                SET @CODIGOPROVINCIA = ((@I - 1) % 7) + 1;
                SET @IDDISTRITO = ((@I * 7) % @TOTALDISTRITOS) + 1;

                SELECT TOP 1 @SENATEMP = SENA
                FROM #SENAS
                ORDER BY NEWID();

                IF @SENATEMP LIKE '%#'
                    BEGIN
                        SET
                            @SENATEMP = CONCAT(
                                LEFT(@SENATEMP, LEN(@SENATEMP) - 1),
                                (@I % 150) + 1
                            );
                    END;

                INSERT INTO DBO.DIRECCION (
                    ID_DISTRITO,
                    SENAS_ADICIONALES
                )
                VALUES (
                    @IDDISTRITO,
                    ISNULL(@SENATEMP, 'Sin señas adicionales')
                );

                IF @@ROWCOUNT = 0
                    BEGIN
                        THROW
                        50014,
                        'No se pudo registrar la dirección para el cliente.',
                        1;
                    END;

                SET @NUEVOIDDIRECCION = SCOPE_IDENTITY();

                SELECT TOP 1 @NOMTEMP = NOMBRE
                FROM #NOMBRES
                ORDER BY NEWID();

                SELECT TOP 1 @APE1TEMP = APELLIDO
                FROM #APELLIDOS
                ORDER BY NEWID();

                SELECT TOP 1 @APE2TEMP = APELLIDO
                FROM #APELLIDOS
                ORDER BY NEWID();

                SELECT TOP 1 @GIROTEMP = GIRO
                FROM #GIROS
                ORDER BY NEWID();

                SELECT TOP 1 @DOMTEMP = DOMINIO
                FROM #DOMINIOS
                ORDER BY NEWID();

                SET @NUEVOIDCLIENTE = @BASECONTADOR + @I;

                IF @ESJURIDICO = 1
                    BEGIN
                        SET @CEDULA = CONCAT(
                            '3101',
                            RIGHT(CONCAT('000000', @NUEVOIDCLIENTE), 6)
                        );
                        SET
                            @CORREOALEATORIO = LOWER(
                                CONCAT(
                                    'contacto',
                                    @NUEVOIDCLIENTE,
                                    '@',
                                    @DOMTEMP
                                )
                            );
                    END;
                ELSE
                    BEGIN
                        SET @CEDULA = CONCAT(
                            CAST(@CODIGOPROVINCIA AS VARCHAR(1)),
                            RIGHT(CONCAT('00000000', @NUEVOIDCLIENTE), 8)
                        );
                        SET
                            @CORREOALEATORIO = LOWER(
                                CONCAT(
                                    @NOMTEMP,
                                    '.',
                                    @APE1TEMP,
                                    @NUEVOIDCLIENTE,
                                    '@',
                                    @DOMTEMP
                                )
                            );
                    END;

                INSERT INTO DBO.CLIENTE (
                    ID_CLIENTE,
                    CEDULA,
                    ID_DIRECCION,
                    TELEFONO,
                    CORREO
                )
                VALUES (
                    @NUEVOIDCLIENTE,
                    @CEDULA,
                    @NUEVOIDDIRECCION,
                    CONCAT(
                        CASE WHEN @I % 2 = 0 THEN '8' ELSE '7' END,
                        RIGHT(CONCAT('0000000', @I), 7)
                    ),
                    @CORREOALEATORIO
                );

                IF @@ROWCOUNT = 0
                    BEGIN
                        THROW 50015, 'No se pudo registrar el cliente.', 1;
                    END;

                IF @ESJURIDICO = 1
                    BEGIN
                        INSERT INTO DBO.CLIENTE_JURIDICO (
                            ID_CLIENTE,
                            RAZON_SOCIAL,
                            NOMBRE_COMERCIAL
                        )
                        VALUES (
                            @NUEVOIDCLIENTE,
                            CONCAT(
                                @GIROTEMP,
                                ' ',
                                @APE1TEMP,
                                ' ',
                                @NUEVOIDCLIENTE,
                                ' S.A.'
                            ),
                            CONCAT(
                                @GIROTEMP,
                                ' ',
                                @APE1TEMP,
                                ' ',
                                @NUEVOIDCLIENTE
                            )
                        );
                    END;
                ELSE
                    BEGIN
                        INSERT INTO DBO.CLIENTE_FISICO (
                            ID_CLIENTE,
                            NOMBRE,
                            PRIMER_APELLIDO,
                            SEGUNDO_APELLIDO
                        )
                        VALUES (
                            @NUEVOIDCLIENTE,
                            @NOMTEMP,
                            @APE1TEMP,
                            @APE2TEMP
                        );
                    END;

                SET @FILASINSERTADAS = @FILASINSERTADAS + 1;
                SET @I = @I + 1;
            END;

        IF @FILASINSERTADAS = 0
            BEGIN
                THROW
                50013,
                'No se procesó ninguna carga de clientes.',
                1;
            END;

        COMMIT TRANSACTION;

        DROP TABLE #NOMBRES;
        DROP TABLE #APELLIDOS;
        DROP TABLE #GIROS;
        DROP TABLE #DOMINIOS;
        DROP TABLE #SENAS;
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

EXEC DBO.PR_CARGARCLIENTES @CANTIDAD = 50000;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARCLIENTES'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARCLIENTES;
    END;
GO
