USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('DBO.PR_ACTUALIZAREMPRESAEMISORA', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_ACTUALIZAREMPRESAEMISORA;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZAREMPRESAEMISORA
    @IDEMPRESA INT,
    @CEDULA VARCHAR(20),
    @NOMBRECOMERCIALL VARCHAR(150),
    @RAZONSOCIAL VARCHAR(150),
    @IDDIRECCION INT,
    @TELEFONO VARCHAR(20),
    @CORREO VARCHAR(100),
    @ACTIVA BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.EMPRESAEMISORA
                WHERE ID_EMPRESA = @IDEMPRESA
            )
            BEGIN
                THROW
                    50008,
                    'La empresa emisora especificada no existe en el sistema.',
                    1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.EMPRESAEMISORA
                WHERE
                    CEDULA = @CEDULA
                    AND ID_EMPRESA <> @IDEMPRESA
            )
            BEGIN
                THROW 50002, 'La cédula ingresada ya existe.', 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIRECCION
                WHERE ID_DIRECCION = @IDDIRECCION
            )
            BEGIN
                THROW 50001, 'El ID de dirección proporcionado no existe.', 1;
            END;

        IF @CORREO NOT LIKE '%_@__%._%'
            BEGIN
                THROW
                    50009,
                    'El formato del correo electrónico es inválido.',
                    1;
            END;

        UPDATE DBO.EMPRESAEMISORA
        SET
            CEDULA = TRIM(TRIM(@CEDULA)),
            NOMBRE_COMERCIAL = TRIM(TRIM(@NOMBRECOMERCIALL)),
            RAZON_SOCIAL = TRIM(TRIM(@RAZONSOCIAL)),
            ID_DIRECCION = @IDDIRECCION,
            TELEFONO = TRIM(TRIM(@TELEFONO)),
            CORREO = LOWER(TRIM(TRIM(@CORREO))),
            ACTIVA = @ACTIVA
        WHERE
            ID_EMPRESA = @IDEMPRESA;

        IF @@ROWCOUNT = 0
            BEGIN
                THROW 50010, 'La actualización falló', 1;
            END;

        COMMIT TRANSACTION;

        SELECT
            DBO.EMPRESAEMISORA.ID_EMPRESA,
            DBO.EMPRESAEMISORA.CEDULA,
            DBO.EMPRESAEMISORA.NOMBRE_COMERCIAL,
            DBO.EMPRESAEMISORA.RAZON_SOCIAL,
            DBO.EMPRESAEMISORA.ID_DIRECCION,
            DBO.DIRECCION.PROVINCIA,
            DBO.DIRECCION.CANTON,
            DBO.DIRECCION.DISTRITO,
            DBO.DIRECCION.SENAS_ADICIONALES,
            DBO.EMPRESAEMISORA.TELEFONO,
            DBO.EMPRESAEMISORA.CORREO,
            DBO.EMPRESAEMISORA.FECHA_CREACION,
            DBO.EMPRESAEMISORA.ACTIVA
        FROM DBO.EMPRESAEMISORA
        INNER JOIN DBO.DIRECCION
            ON DBO.EMPRESAEMISORA.ID_DIRECCION = DBO.DIRECCION.ID_DIRECCION
        WHERE
            DBO.EMPRESAEMISORA.ID_EMPRESA = @IDEMPRESA;
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
