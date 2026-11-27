-- Permiso de lectura para la cuenta del servicio SSAS (necesario para procesar el cubo)
USE AndinaRetailDW;
CREATE USER [NT Service\MSSQLServerOLAPService] FOR LOGIN [NT Service\MSSQLServerOLAPService];
ALTER ROLE db_datareader ADD MEMBER [NT Service\MSSQLServerOLAPService];
