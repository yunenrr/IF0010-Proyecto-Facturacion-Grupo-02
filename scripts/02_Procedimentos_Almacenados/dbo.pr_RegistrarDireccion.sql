USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRARDIRECCION'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRARDIRECCION;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRARDIRECCION
    @IDDISTRITO INT,
    @SENASADICIONALES VARCHAR(250),
    @IDDIRECCION INT OUTPUT
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

        INSERT INTO DBO.DIRECCION (
            ID_DISTRITO,
            SENAS_ADICIONALES
        )
        VALUES (
            @IDDISTRITO,
            @SENASADICIONALES
        );

        SET @IDDIRECCION = SCOPE_IDENTITY();

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
