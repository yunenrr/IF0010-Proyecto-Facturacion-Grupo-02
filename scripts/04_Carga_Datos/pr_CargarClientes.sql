USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO
IF OBJECT_ID('dbo.pr_CargarClientes', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_CargarClientes;
GO
CREATE PROCEDURE dbo.pr_CargarClientes
    @Cantidad INT = 50000
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        CREATE TABLE #Nombres (Nombre VARCHAR(30));
        INSERT INTO #Nombres (Nombre) VALUES 
        ('Carlos'), ('Ana'), ('Luis'), ('María'), ('Juan'), ('Sofía'), ('Pedro'), ('Lucía'), ('Diego'), ('Elena'),
        ('Fernando'), ('Valeria'), ('José'), ('Camila'), ('Mateo'), ('Paula'), ('Gabriel'), ('Daniela'), ('Andrés'), ('Natalia'),
        ('Alejandro'), ('Mariana'), ('Esteban'), ('Ximena'), ('Sébastian'), ('Jimena'), ('Adrian'), ('Fabiola'), ('Ignacio'), ('Sonia');
        CREATE TABLE #Apellidos (Apellido VARCHAR(30));
        INSERT INTO #Apellidos (Apellido) VALUES 
        ('Rodríguez'), ('Gómez'), ('López'), ('González'), ('Martínez'), ('Pérez'), ('Sánchez'), ('Ramírez'), ('Torres'), ('Flores'),
        ('Vargas'), ('Castro'), ('Morales'), ('Herrera'), ('Jiménez'), ('Reyes'), ('Díaz'), ('Mendoza'), ('Aguilar'), ('Rojas'),
        ('Araya'), ('Mora'), ('Chaves'), ('Solano'), ('Campos'), ('Monge'), ('Cascante'), ('Soto'), ('Quesada'), ('Gutiérrez');
        CREATE TABLE #Dominios (Dominio VARCHAR(20));
        INSERT INTO #Dominios (Dominio) VALUES 
        ('gmail.com'), ('outlook.com'), ('hotmail.com'), ('yahoo.es'), ('icloud.com'), ('empresa.cr');
        CREATE TABLE #Cantones (Canton VARCHAR(50));
        INSERT INTO #Cantones (Canton) VALUES 
        ('Central'), ('Escazú'), ('Desamparados'), ('Puriscal'), ('Tarrazú'), ('Aserrí'), ('Mora'), ('Goicoechea'), 
        ('Santa Ana'), ('Alajuelita'), ('Vázquez de Coronado'), ('Tibás'), ('Moravia'), ('Montes de Oca'), ('Turrialba'),
        ('San Ramón'), ('Grecia'), ('Atenas'), ('Naranjo'), ('Palmares'), ('Poás'), ('San Carlos'), ('Pérez Zeledón');
        CREATE TABLE #Distritos (Distrito VARCHAR(50));
        INSERT INTO #Distritos (Distrito) VALUES 
        ('Carmen'), ('Merced'), ('Hospital'), ('Catedral'), ('Zapote'), ('San Francisco de Dos Ríos'), ('Uruca'), 
        ('Mata Redonda'), ('Pavas'), ('Hatillo'), ('San Sebastián'), ('San Rafael'), ('San Antonio'), ('Guadalupe'), 
        ('San Pedro'), ('Curridabat'), ('San Juan'), ('San Isidro'), ('Quesada'), ('San José');
        CREATE TABLE #Senas (Sena VARCHAR(100));
        INSERT INTO #Senas (Sena) VALUES 
        ('De la iglesia católica 200m Norte y 50m Este'),
        ('Contiguo al Ebais, casa color blanco con rejas negras'),
        ('Del parque central 100m Sur, frente al abastecedor'),
        ('Condominio Los Azahares, casa #'),
        ('Urbanización El Pilar, de la pulpería 75m Oeste'),
        ('Residencial Altamira, 50m Este de la plaza de deportes'),
        ('Calle principal, contiguo a la escuela primaria'),
        ('150m Oeste del supermercado local, casa esquina');
        DECLARE @BaseContador INT;
        SELECT @BaseContador = ISNULL(MAX(ID_CLIENTE), 0) FROM dbo.CLIENTE;
        DECLARE @i INT = 1;
        DECLARE @NuevoIdDireccion INT;
        DECLARE @Provincia VARCHAR(50);
        DECLARE @CodigoProvincia INT;
        DECLARE @FilasInsertadas INT = 0;
        DECLARE @NombreAleatorio VARCHAR(70);
        DECLARE @CorreoAleatorio VARCHAR(75);
        DECLARE @NomTemp VARCHAR(30);
        DECLARE @Ape1Temp VARCHAR(30);
        DECLARE @Ape2Temp VARCHAR(30);
        DECLARE @DomTemp VARCHAR(20);
        DECLARE @CedulaProvincial VARCHAR(20);
        DECLARE @CantonTemp VARCHAR(50);
        DECLARE @DistritoTemp VARCHAR(50);
        DECLARE @SenaTemp VARCHAR(100);
        CREATE TABLE #ClientesInsertados (
            ID_CLIENTE INT,
            CEDULA_CLIENTE VARCHAR(20),
            NOMBRE VARCHAR(70),
            ID_DIRECCION INT,
            TELEFONO VARCHAR(15),
            CORREO VARCHAR(75),
            FECHA_REGISTRO DATETIME2
        );

        WHILE @i <= @Cantidad
        BEGIN
            SET @CodigoProvincia = ((@i - 1) % 7) + 1;
            SET @Provincia = CASE @CodigoProvincia
                WHEN 1 THEN 'San José'
                WHEN 2 THEN 'Alajuela'
                WHEN 3 THEN 'Cartago'
                WHEN 4 THEN 'Heredia'
                WHEN 5 THEN 'Guanacaste'
                WHEN 6 THEN 'Puntarenas'
                ELSE 'Limón'
            END;
            SELECT TOP 1 @CantonTemp = Canton FROM #Cantones ORDER BY NEWID();
            SELECT TOP 1 @DistritoTemp = Distrito FROM #Distritos ORDER BY NEWID();
            SELECT TOP 1 @SenaTemp = Sena FROM #Senas ORDER BY NEWID();
            IF @SenaTemp LIKE '%#'
                SET @SenaTemp = CONCAT(LEFT(@SenaTemp, LEN(@SenaTemp)-1), (@i % 150) + 1);
            INSERT INTO dbo.DIRECCION (
                PROVINCIA, 
                CANTON, 
                DISTRITO, 
                SENAS_ADICIONALES
            )
            VALUES (
                @Provincia,
                ISNULL(@CantonTemp, 'Central'),
                ISNULL(@DistritoTemp, 'San José'),
                ISNULL(@SenaTemp, 'Sin señas adicionales')
            );
            IF @@ROWCOUNT = 0
            BEGIN
                THROW 50014, 'No se pudo registrar la dirección para el cliente.', 1;
            END
            SET @NuevoIdDireccion = SCOPE_IDENTITY();
            SELECT TOP 1 @NomTemp = Nombre FROM #Nombres ORDER BY NEWID();
            SELECT TOP 1 @Ape1Temp = Apellido FROM #Apellidos ORDER BY NEWID();
            SELECT TOP 1 @Ape2Temp = Apellido FROM #Apellidos ORDER BY NEWID();
            SELECT TOP 1 @DomTemp = Dominio FROM #Dominios ORDER BY NEWID();
            SET @NombreAleatorio = CONCAT(@NomTemp, ' ', @Ape1Temp, ' ', @Ape2Temp);
            SET @CedulaProvincial = CONCAT(
                CAST(@CodigoProvincia AS VARCHAR(1)), 
                RIGHT(CONCAT('00000000', @BaseContador + @i), 8)
            );
            SET @CorreoAleatorio = LOWER(CONCAT(@NomTemp, '.', @Ape1Temp, @BaseContador + @i, '@', @DomTemp));
            INSERT INTO dbo.CLIENTE (
                CEDULA_CLIENTE,
                NOMBRE,
                ID_DIRECCION,
                TELEFONO,
                CORREO
            )
            OUTPUT 
                INSERTED.ID_CLIENTE,
                INSERTED.CEDULA_CLIENTE,
                INSERTED.NOMBRE,
                INSERTED.ID_DIRECCION,
                INSERTED.TELEFONO,
                INSERTED.CORREO,
                INSERTED.FECHA_REGISTRO
            INTO #ClientesInsertados
            VALUES (
                @CedulaProvincial, 
                @NombreAleatorio,
                @NuevoIdDireccion, 
                CONCAT(CASE WHEN @i % 2 = 0 THEN '8' ELSE '7' END, RIGHT(CONCAT('0000000', @i), 7)),
                @CorreoAleatorio
            );
            IF @@ROWCOUNT = 0
            BEGIN
                THROW 50015, 'No se pudo registrar el cliente.', 1;
            END
            SET @FilasInsertadas = @FilasInsertadas + 1;
            SET @i = @i + 1;
        END
        IF @FilasInsertadas = 0
        BEGIN
            THROW 50013, 'No se procesó ninguna carga de clientes.', 1;
        END
        COMMIT TRANSACTION;
        SELECT 
            C.ID_CLIENTE,
            C.CEDULA_CLIENTE,
            C.NOMBRE,
            C.TELEFONO,
            C.CORREO,
            D.ID_DIRECCION,
            D.PROVINCIA,
            D.CANTON,
            D.DISTRITO,
            D.SENAS_ADICIONALES,
            C.FECHA_REGISTRO
        FROM #ClientesInsertados C
        INNER JOIN dbo.DIRECCION D ON C.ID_DIRECCION = D.ID_DIRECCION;
        DROP TABLE #Nombres;
        DROP TABLE #Apellidos;
        DROP TABLE #Dominios;
        DROP TABLE #Cantones;
        DROP TABLE #Distritos;
        DROP TABLE #Senas;
        DROP TABLE #ClientesInsertados;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH
END;
GO
EXEC dbo.pr_CargarClientes @Cantidad = 50000;
GO
IF OBJECT_ID('dbo.pr_CargarClientes', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_CargarClientes;
GO
