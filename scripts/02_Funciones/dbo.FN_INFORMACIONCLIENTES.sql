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
        D.PROVINCIA,
        D.CANTON,
        D.DISTRITO,
        D.SENAS_ADICIONALES,
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
    INNER JOIN DBO.DIRECCION AS D
        ON C.ID_DIRECCION = D.ID_DIRECCION
);
GO

GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Administrativo];
GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Cajero];
GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Consulta];
GO
