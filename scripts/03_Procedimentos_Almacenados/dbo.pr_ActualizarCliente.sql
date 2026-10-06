USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZARCLIENTE'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZARCLIENTE;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARCLIENTE
    @ID_CLIENTE INT,
    @ID_DIRECCION INT,
    @TELEFONO VARCHAR(15),
    @CORREO VARCHAR(75)
AS
    BEGIN
        SET NOCOUNT ON;
        SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE ID_CLIENTE = @ID_CLIENTE
            )
            BEGIN
                THROW 50016, 'El cliente especificado no existe.', 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIRECCION
                WHERE ID_DIRECCION = @ID_DIRECCION
            )
            BEGIN
                THROW 50017, 'La direccion especificada no existe.', 1;
            END;

        UPDATE DBO.CLIENTE
        SET
            ID_DIRECCION = @ID_DIRECCION,
            TELEFONO = @TELEFONO,
            CORREO = @CORREO,
            ULTIMA_ACTUALIZACION = SYSDATETIME()
        WHERE
            ID_CLIENTE = @ID_CLIENTE;

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
