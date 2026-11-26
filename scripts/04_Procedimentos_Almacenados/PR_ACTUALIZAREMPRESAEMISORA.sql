USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZAREMPRESAEMISORA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZAREMPRESAEMISORA;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZAREMPRESAEMISORA
    @IDEMPRESA INT,
    @CEDULA VARCHAR(20),
    @NOMBRECOMERCIAL VARCHAR(150),
    @RAZONSOCIAL VARCHAR(150),
    @IDDIRECCION INT,
    @TELEFONO VARCHAR(20),
    @CORREO VARCHAR(100),
    @ACTIVA BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.EMPRESA_EMISORA
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
                FROM DBO.EMPRESA_EMISORA
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
                THROW 50143, 'El ID de dirección proporcionado no existe.', 1;
            END;

        IF @CORREO NOT LIKE '%_@__%._%'
            BEGIN
                THROW
                50009,
                'El formato del correo electrónico es inválido.',
                1;
            END;

        UPDATE DBO.EMPRESA_EMISORA
        SET
            CEDULA = TRIM(@CEDULA),
            NOMBRE_COMERCIAL = TRIM(@NOMBRECOMERCIAL),
            RAZON_SOCIAL = TRIM(@RAZONSOCIAL),
            ID_DIRECCION = @IDDIRECCION,
            TELEFONO = TRIM(@TELEFONO),
            CORREO = LOWER(TRIM(@CORREO)),
            ACTIVA = @ACTIVA
        WHERE
            ID_EMPRESA = @IDEMPRESA;

        IF @@ROWCOUNT = 0
            BEGIN
                THROW 50010, 'La actualización falló', 1;
            END;

        COMMIT TRANSACTION;

        SELECT
            E.ID_EMPRESA,
            E.CEDULA,
            E.NOMBRE_COMERCIAL,
            E.RAZON_SOCIAL,
            E.ID_DIRECCION,
            P.NOMBRE AS PROVINCIA,
            C.NOMBRE AS CANTON,
            DI.NOMBRE AS DISTRITO,
            D.SENAS_ADICIONALES,
            E.TELEFONO,
            E.CORREO,
            E.FECHA_CREACION,
            E.ACTIVA
        FROM DBO.EMPRESA_EMISORA AS E
        INNER JOIN DBO.DIRECCION AS D
            ON E.ID_DIRECCION = D.ID_DIRECCION
        INNER JOIN DBO.DISTRITO AS DI
            ON D.ID_DISTRITO = DI.ID_DISTRITO
        INNER JOIN DBO.CANTON AS C
            ON DI.ID_CANTON = C.ID_CANTON
        INNER JOIN DBO.PROVINCIA AS P
            ON C.ID_PROVINCIA = P.ID_PROVINCIA
        WHERE
            E.ID_EMPRESA = @IDEMPRESA;
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
