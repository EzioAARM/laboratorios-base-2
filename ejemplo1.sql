USE master
GO
CREATE LOGIN AsistenteRRHH WITH PASSWORD='Naranja19#'
GO
USE AdventureWorks2017
GO
CREATE USER AsistenteRRHH FROM LOGIN AsistenteRRHH
GO
GRANT SELECT, UPDATE ON SCHEMA::Person TO AsistenteRRHH