USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_INSERTARCLIENTEJURIDICO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_INSERTARCLIENTEJURIDICO;
    END;
GO

CREATE PROCEDURE DBO.PR_INSERTARCLIENTEJURIDICO
    @CEDULA VARCHAR(20),
    @RAZON_SOCIAL VARCHAR(150),
    @NOMBRE_COMERCIAL VARCHAR(150),
    @ID_DIRECCION INT,
    @TELEFONO VARCHAR(15),
    @CORREO VARCHAR(75)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE CEDULA = @CEDULA
            )
            BEGIN
                THROW 50120, 'Ya existe un cliente con esta cedula.', 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIRECCION
                WHERE ID_DIRECCION = @ID_DIRECCION
            )
            BEGIN
                THROW 50121, 'La direccion especificada no existe.', 1;
            END;

        IF
            @RAZON_SOCIAL IS NULL
            OR TRIM(@RAZON_SOCIAL) = ''
            OR @NOMBRE_COMERCIAL IS NULL
            OR TRIM(@NOMBRE_COMERCIAL) = ''
            BEGIN
                THROW
                50122,
                'La razon social y el nombre comercial son obligatorios.',
                1;
            END;

        DECLARE @NUEVOIDCLIENTE INT;

        SELECT @NUEVOIDCLIENTE = ISNULL(MAX(ID_CLIENTE), 0) + 1
        FROM DBO.CLIENTE;

        INSERT INTO DBO.CLIENTE (
            ID_CLIENTE,
            CEDULA,
            ID_DIRECCION,
            TELEFONO,
            CORREO
        )
        VALUES (
            @NUEVOIDCLIENTE,
            @CEDULA,
            @ID_DIRECCION,
            @TELEFONO,
            @CORREO
        );

        INSERT INTO DBO.CLIENTE_JURIDICO (
            ID_CLIENTE,
            RAZON_SOCIAL,
            NOMBRE_COMERCIAL
        )
        VALUES (
            @NUEVOIDCLIENTE,
            TRIM(@RAZON_SOCIAL),
            TRIM(@NOMBRE_COMERCIAL)
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
