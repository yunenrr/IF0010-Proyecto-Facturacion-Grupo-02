USE FACTURACIONSOLUCIONESMAGNIFICAS;
GO

IF
    NOT EXISTS (
        SELECT 1
        FROM sys.database_role_members rm
        JOIN
            sys.database_principals r ON rm.role_principal_id = r.principal_id
        JOIN
            sys.database_principals u ON rm.member_principal_id = u.principal_id
        WHERE
            r.name = N'AUDITOR'
            AND u.name = N'USERAUDITOR'
    )
BEGIN
    ALTER ROLE [AUDITOR] ADD MEMBER [USERAUDITOR];
END;
GO
