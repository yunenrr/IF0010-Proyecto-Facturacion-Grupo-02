USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRARESTADOFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRARESTADOFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRARESTADOFACTURA
    @ESTADO VARCHAR(20),
    @DESCRIPCION_ESTADO VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NUEVO_ID_ESTADO INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @ESTADO = UPPER(TRIM(@ESTADO));
        SET @DESCRIPCION_ESTADO = TRIM(@DESCRIPCION_ESTADO);

        IF
            EXISTS (
                SELECT 1
                FROM DBO.ESTADOFACTURA
                WHERE ESTADO = @ESTADO
            )
            BEGIN
                THROW
                50011,
                'El nombre de estado ingresado ya existe.',
                1;
            END;

        IF @ESTADO = '' OR @DESCRIPCION_ESTADO = ''
            BEGIN
                THROW
                50012,
                'El nombre del estado y su descripción no pueden estar vacíos.',
                1;
            END;

        INSERT INTO DBO.ESTADOFACTURA (
            ESTADO,
            DESCRIPCION_ESTADO
        )
        VALUES (
            @ESTADO,
            @DESCRIPCION_ESTADO
        );

        IF @@ROWCOUNT = 0
            BEGIN
                THROW 50013, 'No se pudo hacer el registro', 1;
            END;

        SET @NUEVO_ID_ESTADO = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT
            ID_ESTADO,
            ESTADO,
            DESCRIPCION_ESTADO
        FROM DBO.ESTADOFACTURA
        WHERE
            ID_ESTADO = @NUEVO_ID_ESTADO;
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
