USE master;

DECLARE @CLAVEADMINISTRATIVO NVARCHAR(128) = N'Ad1234567';

IF @CLAVEADMINISTRATIVO IS NULL
    THROW 51005, 'La clave del administrativo no puede ser nula.', 1;

IF TRIM(@CLAVEADMINISTRATIVO) = ''
    THROW 50100, N'LA clave de administrativo no puede ser vacía.', 1;

IF
    EXISTS (
        SELECT 1
        FROM sys.server_principals
        WHERE
            name = N'LOGADMINISTRATIVO'
    )
    THROW 51007, 'Ya existe el login LOGADMINISTRATIVO; no se sobreescribe', 1;


DECLARE @COMANDO NVARCHAR(MAX);

SET @COMANDO = N'CREATE LOGIN LOGADMINISTRATIVO WITH PASSWORD = '
    + QUOTENAME(@CLAVEADMINISTRATIVO, '''')
    + N', CHECK_POLICY = ON, CHECK_EXPIRATION = ON';

EXEC (@COMANDO);
GO
