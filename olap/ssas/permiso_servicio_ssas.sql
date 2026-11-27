-- Da lectura sobre AndinaRetailDW a la cuenta del servicio de Analysis Services.
-- El data source del cubo usa la cuenta del servicio, así que sin esto el procesamiento falla.
-- Se puede ejecutar más de una vez. El ETL no borra la base, así que el permiso sobrevive a las recargas.
USE AndinaRetailDW;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'NT Service\MSSQLServerOLAPService')
    CREATE USER [NT Service\MSSQLServerOLAPService] FOR LOGIN [NT Service\MSSQLServerOLAPService];
ALTER ROLE db_datareader ADD MEMBER [NT Service\MSSQLServerOLAPService];
