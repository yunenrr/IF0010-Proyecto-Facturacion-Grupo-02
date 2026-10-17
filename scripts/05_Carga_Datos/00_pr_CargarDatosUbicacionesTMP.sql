USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARDATOSUBICACIONTMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARDATOSUBICACIONTMP;
    END;
GO

CREATE PROCEDURE DBO.PR_CARGARDATOSUBICACIONTMP
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO DBO.PROVINCIA (
            ID_PROVINCIA,
            NOMBRE
        )
        SELECT
            T.ID_PROVINCIA,
            T.NOMBRE
        FROM (
            VALUES
            (1, 'San José'),
            (2, 'Alajuela'),
            (3, 'Cartago'),
            (4, 'Heredia'),
            (5, 'Guanacaste'),
            (6, 'Puntarenas'),
            (7, 'Limón')
        ) AS T(ID_PROVINCIA, NOMBRE)
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.PROVINCIA AS P
                WHERE
                    P.ID_PROVINCIA = T.ID_PROVINCIA
            );

        INSERT INTO DBO.CANTON (
            ID_CANTON,
            ID_PROVINCIA,
            NOMBRE
        )
        SELECT
            T.ID_CANTON,
            T.ID_PROVINCIA,
            T.NOMBRE
        FROM (
            VALUES
            (1, 1, 'San José'),
            (2, 1, 'Escazú'),
            (3, 1, 'Desamparados'),
            (4, 1, 'Pérez Zeledón'),
            (5, 2, 'Alajuela'),
            (6, 2, 'San Ramón'),
            (7, 2, 'Grecia'),
            (8, 2, 'San Carlos'),
            (9, 3, 'Cartago'),
            (10, 3, 'Paraíso'),
            (11, 3, 'La Unión'),
            (12, 3, 'El Guarco'),
            (13, 4, 'Heredia'),
            (14, 4, 'Barva'),
            (15, 4, 'Santo Domingo'),
            (16, 4, 'Belén'),
            (17, 5, 'Liberia'),
            (18, 5, 'Nicoya'),
            (19, 5, 'Santa Cruz'),
            (20, 5, 'Bagaces'),
            (21, 6, 'Puntarenas'),
            (22, 6, 'Esparza'),
            (23, 6, 'Quepos'),
            (24, 6, 'Golfito'),
            (25, 7, 'Limón'),
            (26, 7, 'Pococí'),
            (27, 7, 'Siquirres'),
            (28, 7, 'Talamanca')
        ) AS T(ID_CANTON, ID_PROVINCIA, NOMBRE)
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.CANTON AS C
                WHERE
                    C.ID_CANTON = T.ID_CANTON
            );

        INSERT INTO DBO.DISTRITO (
            ID_DISTRITO,
            ID_CANTON,
            NOMBRE
        )
        SELECT
            ((C.ID_CANTON - 1) * 3) + X.N AS ID_DISTRITO,
            C.ID_CANTON,
            X.NOMBRE
        FROM DBO.CANTON AS C
        CROSS JOIN (
            VALUES
            (1, 'Carmen'),
            (2, 'San Rafael'),
            (3, 'San Antonio')
        ) AS X(N, NOMBRE)
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM DBO.DISTRITO AS D
                WHERE
                    D.ID_DISTRITO = ((C.ID_CANTON - 1) * 3) + X.N
            );

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

EXEC DBO.PR_CARGARDATOSUBICACIONTMP;
PRINT 'Carga de provincias, cantones y distritos completada con exito.';
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_CARGARDATOSUBICACIONTMP'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_CARGARDATOSUBICACIONTMP;
    END;
GO
