USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRARFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRARFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRARFACTURA
    @IDENTIFICADOR_COMPROBANTE VARCHAR(30),
    @ID_EMPRESA INT,
    @ID_CLIENTE INT,
    @ID_TIPO_DOCUMENTO INT,
    @CODIGO_DIVISA CHAR(3),
    @ID_ESTADO INT,
    @OBSERVACIONES VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.FACTURA
                WHERE
                    IDENTIFICADOR_COMPROBANTE = @IDENTIFICADOR_COMPROBANTE
            )
            BEGIN
                THROW
                50053,
                'Ya existe una factura con ese identificador de comprobante.',
                1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.EMPRESAEMISORA
                WHERE
                    ID_EMPRESA = @ID_EMPRESA
                    AND ACTIVA = 1
            )
            BEGIN
                THROW
                50054,
                'La empresa emisora no existe o no esta activa.',
                1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE ID_CLIENTE = @ID_CLIENTE
            )
            BEGIN
                THROW 50055, 'El cliente especificado no existe.', 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.TIPODOCUMENTO
                WHERE ID_TIPO_DOCUMENTO = @ID_TIPO_DOCUMENTO
            )
            BEGIN
                THROW
                50056,
                'El tipo de documento especificado no existe.',
                1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIVISA
                WHERE CODIGO_DIVISA = @CODIGO_DIVISA
            )
            BEGIN
                THROW 50057, 'La divisa especificada no existe.', 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.ESTADOFACTURA
                WHERE ID_ESTADO = @ID_ESTADO
            )
            BEGIN
                THROW 50058, 'El estado especificado no existe.', 1;
            END;

        DECLARE @NUEVO_CODIGO INT = (
            SELECT ISNULL(MAX(CODIGO_FACTURA), 0) + 1
            FROM DBO.FACTURA
        );

        INSERT INTO DBO.FACTURA (
            CODIGO_FACTURA,
            IDENTIFICADOR_COMPROBANTE,
            ID_EMPRESA,
            ID_CLIENTE,
            ID_TIPO_DOCUMENTO,
            CODIGO_DIVISA,
            ID_ESTADO,
            OBSERVACIONES
        )
        VALUES (
            @NUEVO_CODIGO,
            @IDENTIFICADOR_COMPROBANTE,
            @ID_EMPRESA,
            @ID_CLIENTE,
            @ID_TIPO_DOCUMENTO,
            @CODIGO_DIVISA,
            @ID_ESTADO,
            @OBSERVACIONES
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
