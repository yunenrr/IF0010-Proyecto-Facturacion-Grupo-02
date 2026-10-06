USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARDIRECCION'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARDIRECCION;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARDIRECCION (
    @DIRECCIONID INT,
    @PROVINCIA VARCHAR(50),
    @CANTON VARCHAR(50),
    @DISTRITO VARCHAR(50),
    @SENASADICIONALES VARCHAR(250) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE DBO.DIRECCION
        SET
            PROVINCIA = @PROVINCIA,
            CANTON = @CANTON,
            DISTRITO = @DISTRITO,
            SENAS_ADICIONALES = @SENASADICIONALES
        WHERE
            ID_DIRECCION = @DIRECCIONID;

        IF @@ROWCOUNT = 0
            BEGIN
                THROW
                    50013,
                    'No se encontró ninguna dirección con el ID proporcionado.',
                    1;
            END;

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
