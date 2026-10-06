USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('dbo.pr_RegistrarAuditoria', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_RegistrarAuditoria;
GO

CREATE PROCEDURE dbo.pr_RegistrarAuditoria
    @TablaAfectada VARCHAR(50),
    @LlavePrimaria VARCHAR(50),
    @Operacion VARCHAR(10),
    @CampoModificado VARCHAR(50) = NULL,
    @ValorAnterior VARCHAR(MAX) = NULL,
    @ValorNuevo VARCHAR(MAX) = NULL,
    @Usuario VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        SET @Operacion = UPPER(@Operacion);
        
        IF @Operacion NOT IN ('INSERT', 'UPDATE', 'DELETE')
        BEGIN
            THROW 50070, 'La operación especificada no es válida. Debe ser INSERT, UPDATE o DELETE.', 1;
        END
        IF @TablaAfectada IS NULL OR TRIM(TRIM(@TablaAfectada)) = ''
        BEGIN
            THROW 50071, 'Debe especificar el nombre de la tabla afectada.', 1;
        END
        IF @LlavePrimaria IS NULL OR TRIM(TRIM(@LlavePrimaria)) = ''
        BEGIN
            THROW 50072, 'Debe especificar el valor.', 1;
        END
        IF @Usuario IS NULL OR TRIM(TRIM(@Usuario)) = ''
        BEGIN
            SET @Usuario = SUSER_SNAME();
        END
        INSERT INTO dbo.AUDITORIASISTEMA (
            TABLA_AFECTADA,
            LLAVE_PRIMARIA,
            OPERACION,
            CAMPO_MODIFICADO,
            VALOR_ANTERIOR,
            VALOR_NUEVO,
            USUARIO,
            FECHA_HORA
        )
        VALUES (
            @TablaAfectada,
            @LlavePrimaria,
            @Operacion,
            @CampoModificado,
            @ValorAnterior,
            @ValorNuevo,
            @Usuario,
            SYSDATETIME()
        );
        DECLARE @IDAuditoriaGenerado INT = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
        SELECT 
            A.ID_AUDITORIA,
            A.TABLA_AFECTADA,
            A.LLAVE_PRIMARIA,
            A.OPERACION,
            A.CAMPO_MODIFICADO,
            A.VALOR_ANTERIOR,
            A.VALOR_NUEVO,
            A.USUARIO,
            A.FECHA_HORA
        FROM dbo.AUDITORIASISTEMA A
        WHERE A.ID_AUDITORIA = @IDAuditoriaGenerado;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
