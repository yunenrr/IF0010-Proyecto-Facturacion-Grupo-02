USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARDIVISA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARDIVISA;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARDIVISA
    @CODIGODIVISA CHAR(3),
    @NOMBRE VARCHAR(50),
    @SIMBOLO VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @CODIGODIVISA = UPPER(TRIM(@CODIGODIVISA));
        SET @NOMBRE = TRIM(@NOMBRE);
        SET @SIMBOLO = TRIM(@SIMBOLO);

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIVISA
                WHERE CODIGO_DIVISA = @CODIGODIVISA
            )
            BEGIN
                THROW
                50090,
                'La divisa especificada no existe en la base de datos.',
                1;
            END;

        IF @NOMBRE IS NULL OR @NOMBRE = ''
            BEGIN
                THROW 50091, 'El nombre de la divisa no puede estar vacío.', 1;
            END;

        IF @SIMBOLO IS NULL OR @SIMBOLO = ''
            BEGIN
                THROW 50092, 'El símbolo de la divisa no puede estar vacío.', 1;
            END;

        UPDATE DBO.DIVISA
        SET
            NOMBRE = @NOMBRE,
            SIMBOLO = @SIMBOLO
        WHERE
            CODIGO_DIVISA = @CODIGODIVISA;

        IF @@ROWCOUNT = 0
            BEGIN
                THROW
                50093,
                'No se realizó ninguna actualización en la divisa.',
                1;
            END;

        COMMIT TRANSACTION;

        SELECT
            D.CODIGO_DIVISA,
            D.NOMBRE,
            D.SIMBOLO
        FROM DBO.DIVISA AS D
        WHERE D.CODIGO_DIVISA = @CODIGODIVISA;
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
