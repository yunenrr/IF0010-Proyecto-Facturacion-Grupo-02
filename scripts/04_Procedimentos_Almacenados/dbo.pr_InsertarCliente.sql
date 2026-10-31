USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_INSERTARCLIENTE'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_INSERTARCLIENTE;
    END;
GO

CREATE PROCEDURE DBO.PR_INSERTARCLIENTE
    @CEDULA_CLIENTE VARCHAR(20),
    @NOMBRE VARCHAR(70),
    @PRIMERAPELLIDO VARCHAR(50),
    @SEGUNDOAPELLIDO VARCHAR(50),
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
            EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE CEDULA_CLIENTE = @CEDULA_CLIENTE
            )
            BEGIN
                THROW 50014, 'Ya existe un cliente con esta cedula.', 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.DIRECCION
                WHERE ID_DIRECCION = @ID_DIRECCION
            )
            BEGIN
                THROW 50015, 'La direccion especificada no existe.', 1;
            END;

        DECLARE @NUEVOIDCLIENTE INT;

        SELECT @NUEVOIDCLIENTE = ISNULL(MAX(ID_CLIENTE), 0) + 1
        FROM DBO.CLIENTE;

        INSERT INTO DBO.CLIENTE (
            ID_CLIENTE,
            CEDULA_CLIENTE,
            NOMBRE,
            PRIMERAPELLIDO,
            SEGUNDOAPELLIDO,
            ID_DIRECCION,
            TELEFONO,
            CORREO
        )
        VALUES (
            @NUEVOIDCLIENTE,
            @CEDULA_CLIENTE,
            @NOMBRE,
            @PRIMERAPELLIDO,
            @SEGUNDOAPELLIDO,
            @ID_DIRECCION,
            @TELEFONO,
            @CORREO
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
