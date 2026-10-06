USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ELIMINARDIRECCION'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ELIMINARDIRECCION;
    END;
GO

CREATE PROCEDURE DBO.PR_ELIMINARDIRECCION
    @ID_DIRECCION INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIRECCION
                WHERE ID_DIRECCION = @ID_DIRECCION
            )
            BEGIN
                THROW 50031, 'La direccion especificada no existe.', 1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE ID_DIRECCION = @ID_DIRECCION
            )
            BEGIN
                THROW
                50032,
                'No se puede eliminar: hay clientes usando esta direccion.',
                1;
            END;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.EMPRESAEMISORA
                WHERE ID_DIRECCION = @ID_DIRECCION
            )
            BEGIN
                THROW
                50033,
                'No se puede eliminar: hay empresas usando esta direccion.',
                1;
            END;

        DELETE FROM DBO.DIRECCION
        WHERE
            ID_DIRECCION = @ID_DIRECCION;

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
