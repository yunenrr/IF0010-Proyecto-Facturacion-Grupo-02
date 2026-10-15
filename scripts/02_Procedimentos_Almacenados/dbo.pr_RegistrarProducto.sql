USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRARPRODUCTO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRARPRODUCTO;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRARPRODUCTO
    @CODIGOID INT,
    @DESCRIPCION VARCHAR(255),
    @PRECIOUNITARIO DECIMAL(18, 2),
    @PORCENTAJEIMPUESTO DECIMAL(5, 2) = 13.00,
    @STOCKACTUAL INT = 0,
    @STOCKMINIMO INT = 0,
    @ESTADO INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.PRODUCTO
                WHERE
                    CODIGO_ID = @CODIGOID
            )
            BEGIN
                THROW
                50003,
                'El Código ID ya existe.',
                1;
            END;

        IF @PRECIOUNITARIO < 0
            BEGIN
                THROW
                50004,
                'El precio unitario no puede ser negativo.',
                1;
            END;

        IF
            @PORCENTAJEIMPUESTO < 0
            OR @PORCENTAJEIMPUESTO > 100
            BEGIN
                THROW
                50005,
                'El impuesto debe estar entre 0 y 100.',
                1;
            END;

        IF
            @STOCKACTUAL < 0
            OR @STOCKMINIMO < 0
            BEGIN
                THROW
                50006,
                'El stock debe ser mayor o igual a 0.',
                1;
            END;

        IF @ESTADO NOT IN (0, 1)
            BEGIN
                THROW
                50007,
                'El estado debe ser 1 o 0.',
                1;
            END;

        INSERT INTO DBO.PRODUCTO (
            CODIGO_ID,
            DESCRIPCION,
            PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO,
            STOCK_ACTUAL,
            STOCK_MINIMO,
            ESTADO,
            FECHA_CREACION
        )
        VALUES (
            @CODIGOID,
            TRIM(@DESCRIPCION),
            @PRECIOUNITARIO,
            @PORCENTAJEIMPUESTO,
            @STOCKACTUAL,
            @STOCKMINIMO,
            @ESTADO,
            SYSDATETIME()
        );

        IF @@ROWCOUNT = 0
            BEGIN
                THROW
                50025,
                'No se pudo realizar el registro.',
                1;
            END;

        COMMIT TRANSACTION;

        SELECT
            CODIGO_ID,
            DESCRIPCION,
            PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO,
            STOCK_ACTUAL,
            STOCK_MINIMO,
            ESTADO,
            FECHA_CREACION
        FROM DBO.PRODUCTO
        WHERE
            CODIGO_ID = @CODIGOID;
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
