USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF OBJECT_ID('DBO.PR_REGISTRARDIVISA', 'P') IS NOT NULL
    DROP PROCEDURE DBO.PR_REGISTRARDIVISA;
GO

CREATE PROCEDURE DBO.PR_REGISTRARDIVISA
    @CODIGODIVISA CHAR(3),
    @NOMBRE VARCHAR(50),
    @SIMBOLO VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF
            EXISTS (
                SELECT 1
                FROM DBO.DIVISA
                WHERE CODIGO_DIVISA = @CODIGODIVISA
            )
            BEGIN
                THROW
                50014,
                'El código de divisa ya se encuentra registrado.',
                1;
            END;

        INSERT INTO DBO.DIVISA (
            CODIGO_DIVISA,
            NOMBRE,
            SIMBOLO
        )
        VALUES (
            @CODIGODIVISA,
            @NOMBRE,
            @SIMBOLO
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
