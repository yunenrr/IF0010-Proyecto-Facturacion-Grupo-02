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
        ('Juan'),
        ('Sofía'),
        ('Pedro'),
        ('Lucía'),
        ('Diego'),
        ('Elena'),
        ('Fernando'),
        ('Valeria'),
        ('José'),
        ('Camila'),
        ('Mateo'),
        ('Paula'),
        ('Gabriel'),
        ('Daniela'),
        ('Andrés'),
        ('Natalia'),
        ('Alejandro'),
        ('Mariana'),
        ('Esteban'),
        ('Ximena'),
        ('Sébastian'),
        ('Jimena'),
        ('Adrian'),
        ('Fabiola'),
        ('Ignacio'),
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
        ('Morales'),
        ('Herrera'),
        ('Jiménez'),
        ('Reyes'),
        ('Díaz'),
        ('Mendoza'),
        ('Aguilar'),
        ('Rojas'),
        ('Araya'),
        ('Mora'),
        ('Chaves'),
        ('Solano'),
        ('Campos'),
        ('Monge'),
        ('Cascante'),
        ('Soto'),
        ('Quesada'),
        ('Gutiérrez');

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
        DECLARE @DOMTEMP VARCHAR(20);
        DECLARE @CEDULAPROVINCIAL VARCHAR(20);
        DECLARE @SENATEMP VARCHAR(100);
        DECLARE @NUEVOIDCLIENTE INT;

        CREATE TABLE #CLIENTESINSERTADOS (
            ID_CLIENTE INT,
            CEDULA_CLIENTE VARCHAR(20),
            NOMBRE VARCHAR(70),
            PRIMERAPELLIDO VARCHAR(50),
            SEGUNDOAPELLIDO VARCHAR(50),
            ID_DIRECCION INT,
            TELEFONO VARCHAR(15),
            CORREO VARCHAR(75),
            FECHA_REGISTRO DATETIME2
        );

        WHILE @I <= @CANTIDAD
            BEGIN
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

                SELECT TOP 1 @DOMTEMP = DOMINIO
                FROM #DOMINIOS
                ORDER BY NEWID();

                SET @CEDULAPROVINCIAL = CONCAT(
                    CAST(@CODIGOPROVINCIA AS VARCHAR(1)),
                    RIGHT(CONCAT('00000000', @BASECONTADOR + @I), 8)
                );
                SET
                    @CORREOALEATORIO = LOWER(
                        CONCAT(
                            @NOMTEMP,
                            '.',
                            @APE1TEMP,
                            @BASECONTADOR + @I,
                            '@',
                            @DOMTEMP
                        )
                    );

                SET @NUEVOIDCLIENTE = @BASECONTADOR + @I;

                INSERT INTO DBO.CLIENTE (
                    ID_CLIENTE,
                    CEDULA_CLIENTE,
                    NOMBRE,
                    PRIMERAPELLIDO,
                    SEGUNDOAPELLIDO,
                    ID_DIRECCION,
                    TELEFONO,
                    CORREO
                )
                OUTPUT
                    INSERTED.ID_CLIENTE,
                    INSERTED.CEDULA_CLIENTE,
                    INSERTED.NOMBRE,
                    INSERTED.PRIMER_APELLIDO,
                    INSERTED.SEGUNDO_APELLIDO,
                    INSERTED.ID_DIRECCION,
                    INSERTED.TELEFONO,
                    INSERTED.CORREO,
                    INSERTED.FECHA_REGISTRO
                INTO #CLIENTESINSERTADOS
                VALUES (
                    @NUEVOIDCLIENTE,
                    @CEDULAPROVINCIAL,
                    @NOMTEMP,
                    @APE1TEMP,
                    @APE2TEMP,
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

        SELECT COUNT(*) AS CLIENTES_INSERTADOS
        FROM #CLIENTESINSERTADOS;

        DROP TABLE #NOMBRES;
        DROP TABLE #APELLIDOS;
        DROP TABLE #DOMINIOS;
        DROP TABLE #SENAS;
        DROP TABLE #CLIENTESINSERTADOS;
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
