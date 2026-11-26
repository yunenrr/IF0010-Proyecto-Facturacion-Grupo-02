USE master;

DECLARE @CLAVEDBA NVARCHAR(128) = N'Dba12345';

IF @CLAVEDBA IS NULL
    THROW 51005, 'La clave del DBA no puede ser nula.', 1;

IF TRIM(@CLAVEDBA) = ''
    THROW 50100, N'LA clave de DBA no puede ser vacía.', 1;

IF
    EXISTS (
        SELECT 1
        FROM sys.server_principals
        WHERE
            name = N'LOGDBA'
    )
    THROW 51007, 'Ya existe el login LOGDBA; no se sobreescribe', 1;

DECLARE @COMANDO NVARCHAR(MAX);
SET
    @COMANDO = N'CREATE LOGIN LOGDBA WITH PASSWORD = '
    + QUOTENAME(@CLAVEDBA, '''')
    + N', CHECK_POLICY = ON, CHECK_EXPIRATION = ON';

EXEC (@COMANDO);
GO
