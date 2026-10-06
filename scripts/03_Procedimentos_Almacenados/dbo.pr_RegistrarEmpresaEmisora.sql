USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRAREMPRESAEMISORA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRAREMPRESAEMISORA;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRAREMPRESAEMISORA
    @CEDULA VARCHAR(20),
    @NOMBRECOMERCIALL VARCHAR(150),
    @RAZONSOCIAL VARCHAR(150),
    @IDDIRECCION INT,
    @TELEFONO VARCHAR(20) = NULL,
    @CORREO VARCHAR(100) = NULL,
    @IDEMPRESA INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIRECCION
                WHERE ID_DIRECCION = @IDDIRECCION
            )
            BEGIN
                THROW 50001, 'La dirección especificada no existe.', 1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.EMPRESAEMISORA
                WHERE CEDULA = @CEDULA
            )
            BEGIN
                THROW
                50002,
                'La cédula de la empresa emisora ya se encuentra registrada.',
                1;
            END;

        INSERT INTO DBO.EMPRESAEMISORA (
            CEDULA,
            NOMBRE_COMERCIAL,
            RAZON_SOCIAL,
            ID_DIRECCION,
            TELEFONO,
            CORREO
        )
        VALUES (
            TRIM(@CEDULA),
            TRIM(@NOMBRECOMERCIALL),
            TRIM(@RAZONSOCIAL),
            @IDDIRECCION,
            TRIM(@TELEFONO),
            LOWER(TRIM(@CORREO))
        );

        SET @IDEMPRESA = SCOPE_IDENTITY();

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
