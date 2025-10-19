-- Crear un rol para reportes
CREATE ROLE RolReportes;

-- Crear login y usuario
CREATE LOGIN CristhianCastro WITH PASSWORD = 'Pass@123';
CREATE USER CristhianCastro FOR LOGIN CristhianCastro;

-- Asignar el rol
EXEC sp_addrolemember 'RolReportes', 'CristhianCastro';

-- Dar permisos de solo lectura
GRANT SELECT ON dbo.Transacciones TO RolReportes;
GRANT SELECT ON dbo.AlertasFraude TO RolReportes;
GRANT SELECT ON dbo.HistorialRevision TO RolReportes;

/* Verificando el rol en la BD */

SELECT name, principal_id
FROM sys.database_principals
WHERE type = 'R';

-- Usuario --
SELECT name, type_desc
FROM  sys.database_principals
WHERE type IN ('S', 'U');

-- Ver permisos del rol
SELECT dp.name AS PrincipalName,
       o.name AS ObjectName,
       p.permission_name,
       p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects o ON p.major_id = o.object_id
WHERE dp.name = 'RolReportes';
