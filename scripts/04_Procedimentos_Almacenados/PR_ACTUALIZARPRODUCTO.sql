USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARPRODUCTO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARPRODUCTO;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARPRODUCTO
    @CODIGO_ID INT,
    @DESCRIPCION VARCHAR(255),
    @PRECIO_UNITARIO DECIMAL(18, 2),
    @PORCENTAJE_IMPUESTO DECIMAL(5, 2),
    @ESTADO INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.PRODUCTO
                WHERE CODIGO_ID = @CODIGO_ID
            )
            BEGIN
                THROW 50103, 'El producto especificado no existe.', 1;
            END;

        IF @PRECIO_UNITARIO < 0
            BEGIN
                THROW 50104, 'El precio no puede ser negativo.', 1;
            END;

        IF @PORCENTAJE_IMPUESTO NOT BETWEEN 0 AND 100
            BEGIN
                THROW
                50105,
                'El porcentaje de impuesto debe estar entre 0 y 100.',
                1;
            END;

        UPDATE DBO.PRODUCTO
        SET
            DESCRIPCION = @DESCRIPCION,
            PRECIO_UNITARIO = @PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO = @PORCENTAJE_IMPUESTO,
            ESTADO = @ESTADO
        WHERE
            CODIGO_ID = @CODIGO_ID;

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
