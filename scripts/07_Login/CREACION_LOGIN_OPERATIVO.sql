USE master;

DECLARE @CLAVEOPERATIVO NVARCHAR(128) = N'Op1234567';

IF @CLAVEOPERATIVO IS NULL
    THROW 51005, 'La clave del operativo no puede ser nula.', 1;

IF TRIM(@CLAVEOPERATIVO) = ''
    THROW 50100, N'LA clave de operativo no puede ser vacía.', 1;

IF
    EXISTS (
        SELECT 1
        FROM sys.server_principals
        WHERE
            name = N'LOGOPERATIVO'
    )
    THROW 51007, 'Ya existe el login LOGOPERATIVO; no se sobreescribe', 1;

DECLARE @COMANDO NVARCHAR(MAX);
SET
    @COMANDO = N'CREATE LOGIN LOGOPERATIVO WITH PASSWORD = '
    + QUOTENAME(@CLAVEOPERATIVO, '''')
    + N', CHECK_POLICY = ON, CHECK_EXPIRATION = ON';

EXEC (@COMANDO);
GO
