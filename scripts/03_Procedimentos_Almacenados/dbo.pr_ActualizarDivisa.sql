USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1 FROM SYS.OBJECTS
        WHERE NAME = 'pr_ActualizarDivisa' AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARDIVISA;
    END
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARDIVISA
    @CodigoDivisa CHAR(3),
    @Nombre VARCHAR(50),
    @Simbolo VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @CodigoDivisa = UPPER(TRIM(@CodigoDivisa));
        SET @Nombre = TRIM(@Nombre);
        SET @Simbolo = TRIM(@Simbolo);

        IF
            NOT EXISTS (
                SELECT 1 FROM DBO.DIVISA
                WHERE CODIGO_DIVISA = @CodigoDivisa
            )
            THROW 50090, 'La divisa especificada no existe en la base de datos.', 1;

        IF @Nombre IS NULL OR @Nombre = ''
            THROW 50091, 'El nombre de la divisa no puede estar vacío.', 1;

        IF @Simbolo IS NULL OR @Simbolo = ''
            THROW 50092, 'El símbolo de la divisa no puede estar vacío.', 1;

        UPDATE DBO.DIVISA
        SET
            NOMBRE = @Nombre,
            SIMBOLO = @Simbolo
        WHERE CODIGO_DIVISA = @CodigoDivisa;

        IF @@ROWCOUNT = 0
            THROW 50093, 'No se realizó ninguna actualización en la divisa.', 1;

        COMMIT TRANSACTION;

        SELECT
            CODIGO_DIVISA,
            NOMBRE,
            SIMBOLO
        FROM DBO.DIVISA
        WHERE CODIGO_DIVISA = @CodigoDivisa;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
