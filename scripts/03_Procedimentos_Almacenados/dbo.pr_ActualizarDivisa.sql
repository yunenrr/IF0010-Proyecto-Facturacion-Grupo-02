USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_ActualizarDivisa', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_ActualizarDivisa;
GO
CREATE PROCEDURE dbo.pr_ActualizarDivisa
    @CodigoDivisa CHAR(3),
    @Nombre VARCHAR(50),
    @Simbolo VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        SET @CodigoDivisa = UPPER(TRIM(TRIM(@CodigoDivisa)));
        SET @Nombre = TRIM(TRIM(@Nombre));
        SET @Simbolo = TRIM(TRIM(@Simbolo));
        IF NOT EXISTS (SELECT 1 FROM dbo.DIVISA WHERE CODIGO_DIVISA = @CodigoDivisa)
        BEGIN
            THROW 50090, 'La divisa especificada no existe en la base de datos.', 1;
        END
        IF @Nombre IS NULL OR @Nombre = ''
        BEGIN
            THROW 50091, 'El nombre de la divisa no puede estar vacío.', 1;
        END
        IF @Simbolo IS NULL OR @Simbolo = ''
        BEGIN
            THROW 50092, 'El símbolo de la divisa no puede estar vacío.', 1;
        END
        UPDATE dbo.DIVISA
        SET 
            NOMBRE = @Nombre,
            SIMBOLO = @Simbolo
        WHERE CODIGO_DIVISA = @CodigoDivisa;
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50093, 'No se realizó ninguna actualización en la divisa.', 1;
        END
        COMMIT TRANSACTION;
        SELECT 
            CODIGO_DIVISA,
            NOMBRE,
            SIMBOLO
        FROM dbo.DIVISA
        WHERE CODIGO_DIVISA = @CodigoDivisa;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH
END;
GO
