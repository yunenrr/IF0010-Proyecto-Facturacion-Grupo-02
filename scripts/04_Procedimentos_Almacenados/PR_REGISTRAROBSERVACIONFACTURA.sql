USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRAROBSERVACIONFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRAROBSERVACIONFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRAROBSERVACIONFACTURA
    @CODIGO_FACTURA INT,
    @OBSERVACION VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.FACTURA
                WHERE CODIGO_FACTURA = @CODIGO_FACTURA
            )
            BEGIN
                THROW 50060, 'La factura especificada no existe.', 1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.OBSERVACION_FACTURA
                WHERE CODIGO_FACTURA = @CODIGO_FACTURA
            )
            BEGIN
                THROW
                50061,
                'La factura ya tiene una observacion registrada.',
                1;
            END;

        IF @OBSERVACION IS NULL OR TRIM(@OBSERVACION) = ''
            BEGIN
                THROW 50062, 'La observacion no puede estar vacia.', 1;
            END;

        INSERT INTO DBO.OBSERVACION_FACTURA (
            CODIGO_FACTURA,
            OBSERVACION
        )
        VALUES (
            @CODIGO_FACTURA,
            TRIM(@OBSERVACION)
        );

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
