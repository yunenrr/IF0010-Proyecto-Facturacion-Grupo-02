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

CREATE PROCEDURE DBO.PR_ACTUALIZARDIRECCION
    @IDDIRECCION INT,
    @IDDISTRITO INT,
    @SENASADICIONALES VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DISTRITO
                WHERE ID_DISTRITO = @IDDISTRITO
            )
            BEGIN
                THROW 50034, 'El distrito especificado no existe.', 1;
            END;

        UPDATE DBO.DIRECCION
        SET
            ID_DISTRITO = @IDDISTRITO,
            SENAS_ADICIONALES = @SENASADICIONALES
        WHERE
            ID_DIRECCION = @IDDIRECCION;

        IF @@ROWCOUNT = 0
            BEGIN
                THROW 50035, 'La direccion especificada no existe.', 1;
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
