USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_RegistrarFactura' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_RegistrarFactura;
END
GO

CREATE PROCEDURE dbo.pr_RegistrarFactura
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

        IF EXISTS (
            SELECT 1 FROM dbo.FACTURA
            WHERE IDENTIFICADOR_COMPROBANTE = @IDENTIFICADOR_COMPROBANTE
        )
            THROW 50053, 'Ya existe una factura con ese identificador de comprobante.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.EMPRESAEMISORA
            WHERE ID_EMPRESA = @ID_EMPRESA AND ACTIVA = 1
        )
            THROW 50054, 'La empresa emisora no existe o no esta activa.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTE WHERE ID_CLIENTE = @ID_CLIENTE)
            THROW 50055, 'El cliente especificado no existe.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.TIPODOCUMENTO WHERE ID_TIPO_DOCUMENTO = @ID_TIPO_DOCUMENTO
        )
            THROW 50056, 'El tipo de documento especificado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.DIVISA WHERE CODIGO_DIVISA = @CODIGO_DIVISA)
            THROW 50057, 'La divisa especificada no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOFACTURA WHERE ID_ESTADO = @ID_ESTADO)
            THROW 50058, 'El estado especificado no existe.', 1;

        DECLARE @NuevoCodigo INT = (
            SELECT ISNULL(MAX(CODIGO_FACTURA), 0) + 1 FROM dbo.FACTURA
        );

        INSERT INTO dbo.FACTURA (
            CODIGO_FACTURA, IDENTIFICADOR_COMPROBANTE, ID_EMPRESA, ID_CLIENTE,
            ID_TIPO_DOCUMENTO, CODIGO_DIVISA, ID_ESTADO, OBSERVACIONES
        )
        VALUES (
            @NuevoCodigo, @IDENTIFICADOR_COMPROBANTE, @ID_EMPRESA, @ID_CLIENTE,
            @ID_TIPO_DOCUMENTO, @CODIGO_DIVISA, @ID_ESTADO, @OBSERVACIONES
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
