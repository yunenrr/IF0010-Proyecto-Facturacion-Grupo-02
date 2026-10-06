USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARESTADOFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARESTADOFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARESTADOFACTURA
    @ID_ESTADO INT,
    @ESTADO VARCHAR(20),
    @DESCRIPCION_ESTADO VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.ESTADOFACTURA
                WHERE ID_ESTADO = @ID_ESTADO
            )
            BEGIN
                THROW
                    50120,
                    'El estado de factura especificado no existe.',
                    1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.ESTADOFACTURA
                WHERE
                    ESTADO = @ESTADO
                    AND ID_ESTADO <> @ID_ESTADO
            )
            BEGIN
                THROW 50121, 'Ya existe otro estado con ese nombre.', 1;
            END;

        UPDATE DBO.ESTADOFACTURA
        SET
            ESTADO = @ESTADO,
            DESCRIPCION_ESTADO = @DESCRIPCION_ESTADO
        WHERE
            ID_ESTADO = @ID_ESTADO;

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
