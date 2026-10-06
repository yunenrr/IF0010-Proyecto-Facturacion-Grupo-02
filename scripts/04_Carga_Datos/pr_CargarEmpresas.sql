USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_CargarEmpresas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_CargarEmpresas;
GO
CREATE PROCEDURE dbo.pr_CargarEmpresas
    @Cantidad INT = 100
AS
BEGIN
    SET NOCOUNT ON;
    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        THROW 50001, 'La cantidad de empresas a cargar debe ser un número mayor a 0.', 1;
    END
    BEGIN TRY
        BEGIN TRANSACTION;
        CREATE TABLE #SufijosComerciales (ID INT IDENTITY(1,1), Nombre VARCHAR(50));
        INSERT INTO #SufijosComerciales (Nombre) VALUES 
            ('Tecnología'), ('Supermercados'), ('Farmacias'), ('Librería'), ('Ferretería'), 
            ('Restaurante'), ('Distribuidora'), ('Logística'), ('Consultores'), ('Inversiones'),
            ('Automotriz'), ('Servicios Digitales'), ('Panadería'), ('Agropecuaria'), ('Boutique');
        CREATE TABLE #SustantivosComerciales (ID INT IDENTITY(1,1), Nombre VARCHAR(50));
        INSERT INTO #SustantivosComerciales (Nombre) VALUES 
            ('El Sol'), ('La Estrella'), ('San José'), ('Del Caribe'), ('Del Valle'), 
            ('Central'), ('Costarricense'), ('Irazú'), ('Arenal'), ('Tropicana'),
            ('La Paz'), ('Monteverde'), ('Poás'), ('La Sabana'), ('Pacífico');
        DECLARE @UltimoSecuencial INT = 0;   
        SELECT @UltimoSecuencial = ISNULL(MAX(CAST(RIGHT(CEDULA, 6) AS INT)), 0)
        FROM dbo.EMPRESAEMISORA
        WHERE CEDULA LIKE '%-101-%';
        DECLARE @i INT = 1;
        DECLARE @NumEmpresa INT;
        DECLARE @CodigoProvincia INT;
        DECLARE @Provincia VARCHAR(50);
        DECLARE @Canton VARCHAR(50);
        DECLARE @Distrito VARCHAR(50);
        DECLARE @Senas VARCHAR(255);
        DECLARE @NombreBase VARCHAR(100);
        DECLARE @NombreComercial VARCHAR(150);
        DECLARE @RazonSocial VARCHAR(150);
        DECLARE @Correo VARCHAR(100);
        DECLARE @Telefono VARCHAR(20);
        DECLARE @NuevoIdDireccion INT;
        WHILE @i <= @Cantidad
        BEGIN
            SET @NumEmpresa = @UltimoSecuencial + @i;
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
            SET @Canton = CASE @CodigoProvincia
                WHEN 1 THEN CASE (@i % 4) WHEN 0 THEN 'San José' WHEN 1 THEN 'Escazú' WHEN 2 THEN 'Desamparados' ELSE 'Pérez Zeledón' END
                WHEN 2 THEN CASE (@i % 4) WHEN 0 THEN 'Alajuela' WHEN 1 THEN 'San Ramón' WHEN 2 THEN 'Grecia' ELSE 'San Carlos' END
                WHEN 3 THEN CASE (@i % 4) WHEN 0 THEN 'Cartago' WHEN 1 THEN 'Paraíso' WHEN 2 THEN 'La Unión' ELSE 'El Guarco' END
                WHEN 4 THEN CASE (@i % 4) WHEN 0 THEN 'Heredia' WHEN 1 THEN 'Barva' WHEN 2 THEN 'Santo Domingo' ELSE 'Belén' END
                WHEN 5 THEN CASE (@i % 4) WHEN 0 THEN 'Liberia' WHEN 1 THEN 'Nicoya' WHEN 2 THEN 'Santa Cruz' ELSE 'Bagaces' END
                WHEN 6 THEN CASE (@i % 4) WHEN 0 THEN 'Puntarenas' WHEN 1 THEN 'Esparza' WHEN 2 THEN 'Quepos' ELSE 'Golfito' END
                ELSE CASE (@i % 4) WHEN 0 THEN 'Limón' WHEN 1 THEN 'Pocoçí' WHEN 2 THEN 'Siquirres' ELSE 'Talamanca' END
            END;
            SET @Distrito = CASE @CodigoProvincia
                WHEN 1 THEN CASE (@i % 4) WHEN 0 THEN 'Carmen' WHEN 1 THEN 'San Rafael' WHEN 2 THEN 'San Antonio' ELSE 'San Isidro' END
                WHEN 2 THEN CASE (@i % 4) WHEN 0 THEN 'San José' WHEN 1 THEN 'Santiago' WHEN 2 THEN 'San Roque' ELSE 'Quesada' END
                WHEN 3 THEN CASE (@i % 4) WHEN 0 THEN 'Oriental' WHEN 1 THEN 'Orosi' WHEN 2 THEN 'Tres Ríos' ELSE 'Tejar' END
                WHEN 4 THEN CASE (@i % 4) WHEN 0 THEN 'Mercedes' WHEN 1 THEN 'San Pedro' WHEN 2 THEN 'Santa Rosa' ELSE 'San Antonio' END
                WHEN 5 THEN CASE (@i % 4) WHEN 0 THEN 'Liberia' WHEN 1 THEN 'Mansión' WHEN 2 THEN 'Tamarindo' ELSE 'Bagaces' END
                WHEN 6 THEN CASE (@i % 4) WHEN 0 THEN 'Chacarita' WHEN 1 THEN 'Espíritu Santo' WHEN 2 THEN 'Manuel Antonio' ELSE 'Golfito' END
                ELSE CASE (@i % 4) WHEN 0 THEN 'Limón' WHEN 1 THEN 'Guápiles' WHEN 2 THEN 'Siquirres' ELSE 'Puerto Viejo' END
            END;
            SET @Senas = CASE (@i % 5)
                WHEN 0 THEN CONCAT(CAST((@i % 300) + 25 AS VARCHAR), ' metros oeste del parque central, local #', CAST((@i % 15) + 1 AS VARCHAR))
                WHEN 1 THEN CONCAT('Contiguo al Banco Nacional, edificio ', CHAR(65 + (@i % 5)), ', piso ', CAST((@i % 4) + 1 AS VARCHAR))
                WHEN 2 THEN '100 metros norte y 50 metros este de la iglesia parroquial'
                WHEN 3 THEN CONCAT('Oficentro Empresarial, Torre ', CAST((@i % 3) + 1 AS VARCHAR), ', oficina ', CAST((@i % 20) + 101 AS VARCHAR))
                ELSE CONCAT('Frente a la estación de servicio, local comercial #', CAST((@i % 10) + 1 AS VARCHAR))
            END;
            SELECT TOP 1 @NombreBase = CONCAT(S.Nombre, ' ', N.Nombre)
            FROM #SufijosComerciales S, #SustantivosComerciales N
            ORDER BY NEWID();
            SET @NombreComercial = CONCAT(@NombreBase, ' ', CASE (@i % 3) WHEN 0 THEN 'CR' WHEN 1 THEN 'Tropic' ELSE 'Solutions' END);
            SET @RazonSocial = CONCAT('Corporación ', @NombreBase, CASE (@i % 3) WHEN 0 THEN ' Sociedad Anónima' WHEN 1 THEN ' S.A.' ELSE ' Limitada' END);
            SET @Correo = CONCAT(LOWER(REPLACE(REPLACE(REPLACE(@NombreBase, ' ', ''), 'ñ', 'n'), 'á', 'a')), CAST(@NumEmpresa AS VARCHAR), '@empresa.cr');
            SET @Telefono = CONCAT(
                CASE (@i % 3) WHEN 0 THEN '22' WHEN 1 THEN '25' ELSE '40' END,
                RIGHT(CONCAT('000000', CAST((@i * 387) + 1234 AS VARCHAR)), 6)
            );
            INSERT INTO dbo.DIRECCION (PROVINCIA, CANTON, DISTRITO, SENAS_ADICIONALES)
            VALUES (@Provincia, @Canton, @Distrito, @Senas);
            SET @NuevoIdDireccion = SCOPE_IDENTITY();
            INSERT INTO dbo.EMPRESAEMISORA (
                CEDULA, NOMBRE_COMERCIAL, RAZON_SOCIAL, ID_DIRECCION, TELEFONO, CORREO, FECHA_CREACION, ACTIVA
            )
            VALUES (
                CONCAT(CAST(@CodigoProvincia AS VARCHAR), '-101-', RIGHT(CONCAT('000000', CAST(@NumEmpresa AS VARCHAR)), 6)),
                @NombreComercial,
                @RazonSocial,
                @NuevoIdDireccion, 
                @Telefono,
                @Correo,
                SYSDATETIME(),
                1
            );

            SET @i = @i + 1;
        END

        DROP TABLE #SufijosComerciales;
        DROP TABLE #SustantivosComerciales;

        COMMIT TRANSACTION;
        PRINT 'Carga inicial realizada con éxito.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrorMsg, 1;
    END CATCH
END;
GO
EXEC dbo.pr_CargarEmpresas @Cantidad = 100;
GO
DROP PROCEDURE dbo.pr_CargarEmpresas;
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
FROM dbo.EMPRESAEMISORA E
INNER JOIN dbo.DIRECCION D ON E.ID_DIRECCION = D.ID_DIRECCION
ORDER BY E.ID_EMPRESA DESC;
GO
