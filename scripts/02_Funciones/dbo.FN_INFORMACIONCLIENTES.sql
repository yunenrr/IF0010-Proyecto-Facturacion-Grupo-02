USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    NOT EXISTS (
        SELECT 1
        FROM SYS.DATABASE_PRINCIPALS
        WHERE
            NAME = N'Administrativo'
            AND TYPE = 'R'
    )
    BEGIN
        CREATE ROLE [Administrativo] AUTHORIZATION DBO;
    END;
GO

IF
    NOT EXISTS (
        SELECT 1
        FROM SYS.DATABASE_PRINCIPALS
        WHERE
            NAME = N'Cajero'
            AND TYPE = 'R'
    )
    BEGIN
        CREATE ROLE [Cajero] AUTHORIZATION DBO;
    END;
GO

IF
    NOT EXISTS (
        SELECT 1
        FROM SYS.DATABASE_PRINCIPALS
        WHERE
            NAME = N'Consulta'
            AND TYPE = 'R'
    )
    BEGIN
        CREATE ROLE [Consulta] AUTHORIZATION DBO;
    END;
GO

IF USER_ID(N'UsuarioCajero') IS NULL
    BEGIN
        CREATE USER [UsuarioCajero] WITHOUT LOGIN;
    END;

IF USER_ID(N'UsuarioAdministrador') IS NULL
    BEGIN
        CREATE USER [UsuarioAdministrador] WITHOUT LOGIN;
    END;

IF USER_ID(N'UsuarioSinRol') IS NULL
    BEGIN
        CREATE USER [UsuarioSinRol] WITHOUT LOGIN;
    END;
GO

ALTER ROLE [Cajero] ADD MEMBER [UsuarioCajero];
ALTER ROLE [Consulta] ADD MEMBER [UsuarioCajero];
ALTER ROLE [Administrativo] ADD MEMBER [UsuarioAdministrador];
GO

IF OBJECT_ID('DBO.FN_INFORMACIONCLIENTES', 'IF') IS NOT NULL
    BEGIN
        DROP FUNCTION DBO.FN_INFORMACIONCLIENTES;
    END;
GO

CREATE FUNCTION DBO.FN_INFORMACIONCLIENTES()
RETURNS TABLE
AS
RETURN
(
    SELECT
        C.ID_CLIENTE,
        C.CEDULA_CLIENTE,
        C.NOMBRE,
        PR.NOMBRE AS PROVINCIA,
        CA.NOMBRE AS CANTON,
        DT.NOMBRE AS DISTRITO,
        DI.SENAS_ADICIONALES,
        C.FECHA_REGISTRO,
        CASE
            WHEN
                IS_MEMBER(N'Administrativo') = 1
                OR IS_SRVROLEMEMBER(N'sysadmin') = 1
                THEN C.TELEFONO
            ELSE CONCAT('XXXX-', RIGHT(C.TELEFONO, 4))
        END AS TELEFONO,
        CASE
            WHEN
                IS_MEMBER(N'Administrativo') = 1
                OR IS_SRVROLEMEMBER(N'sysadmin') = 1
                THEN C.CORREO
            ELSE CONCAT(
                LEFT(C.CORREO, 1),
                '***',
                SUBSTRING(
                    C.CORREO,
                    CHARINDEX('@', C.CORREO) - 1,
                    1
                ),
                '@***',
                RIGHT(C.CORREO, 4)
            )
        END AS CORREO
    FROM DBO.CLIENTE AS C
    INNER JOIN DBO.DIRECCION AS DI
        ON C.ID_DIRECCION = DI.ID_DIRECCION
    INNER JOIN DBO.DISTRITO AS DT
        ON DI.ID_DISTRITO = DT.ID_DISTRITO
    INNER JOIN DBO.CANTON AS CA
        ON DT.ID_CANTON = CA.ID_CANTON
    INNER JOIN DBO.PROVINCIA AS PR
        ON CA.ID_PROVINCIA = PR.ID_PROVINCIA
);
GO

GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Administrativo];
GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Cajero];
GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Consulta];
GO
