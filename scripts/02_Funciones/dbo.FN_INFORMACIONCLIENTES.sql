USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF NOT EXISTS (
    SELECT 1
    FROM SYS.DATABASE_PRINCIPALS
    WHERE NAME = N'Administrativo'
        AND TYPE = 'R'
)
    CREATE ROLE [Administrativo] AUTHORIZATION DBO;
GO

IF NOT EXISTS (
    SELECT 1
    FROM SYS.DATABASE_PRINCIPALS
    WHERE NAME = N'Cajero'
        AND TYPE = 'R'
)
    CREATE ROLE [Cajero] AUTHORIZATION DBO;
GO

IF NOT EXISTS (
    SELECT 1
    FROM SYS.DATABASE_PRINCIPALS
    WHERE NAME = N'Consulta'
        AND TYPE = 'R'
)
    CREATE ROLE [Consulta] AUTHORIZATION DBO;
GO

IF USER_ID(N'UsuarioCajero') IS NULL
    CREATE USER [UsuarioCajero] WITHOUT LOGIN;

IF USER_ID(N'UsuarioAdministrador') IS NULL
    CREATE USER [UsuarioAdministrador] WITHOUT LOGIN;

IF USER_ID(N'UsuarioSinRol') IS NULL
    CREATE USER [UsuarioSinRol] WITHOUT LOGIN;
GO

ALTER ROLE [Cajero] ADD MEMBER [UsuarioCajero];
ALTER ROLE [Consulta] ADD MEMBER [UsuarioCajero];
ALTER ROLE [Administrativo] ADD MEMBER [UsuarioAdministrador];
GO

IF OBJECT_ID('DBO.FN_INFORMACIONCLIENTES', 'IF') IS NOT NULL
    DROP FUNCTION DBO.FN_INFORMACIONCLIENTES;
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
        END AS CORREO,
        D.PROVINCIA,
        D.CANTON,
        D.DISTRITO,
        D.SENAS_ADICIONALES,
        C.FECHA_REGISTRO
    FROM DBO.CLIENTE AS C
    INNER JOIN DBO.DIRECCION AS D
        ON C.ID_DIRECCION = D.ID_DIRECCION
);
GO

GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Administrativo];
GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Cajero];
GRANT SELECT ON DBO.FN_INFORMACIONCLIENTES TO [Consulta];
GO
