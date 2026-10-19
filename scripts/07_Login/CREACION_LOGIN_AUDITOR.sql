USE master;

DECLARE @CLAVEAUDITOR NVARCHAR(128) = N'Au123456';

IF @CLAVEAUDITOR IS NULL
    THROW 51005, 'La clave del auditor no puede ser nula.', 1;

IF TRIM(@CLAVEAUDITOR) = ''
    THROW 50100, N'LA clave de auditor no puede ser vacía.', 1;

IF
    EXISTS (
        SELECT 1
        FROM sys.server_principals
        WHERE
            name = N'LOGAUDITOR'
    )
    THROW 51007, 'Ya existe el login LOGAUDITOR; no se sobreescribe', 1;

DECLARE @COMANDO NVARCHAR(MAX);
SET 
    @COMANDO = N'CREATE LOGIN LOGAUDITOR WITH PASSWORD = '
    + QUOTENAME(@CLAVEAUDITOR, '''')
    + N', CHECK_POLICY = ON, CHECK_EXPIRATION = ON';

EXEC (@COMANDO);
GO
