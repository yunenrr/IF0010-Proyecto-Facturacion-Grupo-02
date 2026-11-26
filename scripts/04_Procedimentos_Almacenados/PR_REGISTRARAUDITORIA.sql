USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_REGISTRARAUDITORIA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_REGISTRARAUDITORIA;
    END;
GO

CREATE PROCEDURE DBO.PR_REGISTRARAUDITORIA
    @TABLAAFECTADA VARCHAR(50),
    @LLAVEPRIMARIA VARCHAR(50),
    @IDOPERACION INT,
    @CAMPOMODIFICADO VARCHAR(50) = 'N/A',
    @VALORANTERIOR VARCHAR(MAX) = 'N/A',
    @VALORNUEVO VARCHAR(MAX) = 'N/A',
    @USUARIO VARCHAR(100) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.TIPO_OPERACION
                WHERE ID_OPERACION = @IDOPERACION
            )
            BEGIN
                THROW 50070, 'La operacion especificada no es valida.', 1;
            END;

        IF @TABLAAFECTADA IS NULL OR TRIM(@TABLAAFECTADA) = ''
            BEGIN
                THROW
                50071,
                'Debe especificar el nombre de la tabla afectada.',
                1;
            END;

        IF @LLAVEPRIMARIA IS NULL OR TRIM(@LLAVEPRIMARIA) = ''
            BEGIN
                THROW 50072, 'Debe especificar el valor.', 1;
            END;

        IF TRIM(@USUARIO) = ''
            BEGIN
                SET @USUARIO = SUSER_SNAME();
            END;

        INSERT INTO DBO.AUDITORIA_SISTEMA (
            TABLA_AFECTADA,
            LLAVE_PRIMARIA,
            ID_OPERACION,
            CAMPO_MODIFICADO,
            VALOR_ANTERIOR,
            VALOR_NUEVO,
            USUARIO,
            FECHA_HORA
        )
        VALUES (
            @TABLAAFECTADA,
            @LLAVEPRIMARIA,
            @IDOPERACION,
            @CAMPOMODIFICADO,
            @VALORANTERIOR,
            @VALORNUEVO,
            @USUARIO,
            SYSDATETIME()
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
