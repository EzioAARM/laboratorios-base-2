--1
CREATE OR ALTER PROCEDURE USP_QUERY1
AS
BEGIN
select CONVERT(DATE,E.fecha_inicio) AS 'Día', R.plataforma, COUNT(*) as 'Cantidad Confirmada' from Reservas R
INNER JOIN Avion A on A.id_avion = R.id_avion
INNER JOIN Escala E on E.id_avion = A.id_avion
WHERE R.estado = 'Confirmado'
GROUP BY CONVERT(DATE,E.fecha_inicio), R.plataforma
END
--2
CREATE FUNCTION dbo.Ocupado85 (@IDAvion int)
RETURNS int
AS
BEGIN
	DECLARE @Total int, @CantidadMax int, @Vendidos int
	SET @CantidadMax = (SELECT SUM(cantidad_pasajeros) FROM Clase WHERE id_avion = @IDAvion)
	SET @Vendidos = (SELECT COUNT(*) FROM Boletos Where id_avion = @IDAvion)
	SET @Total = @Vendidos / @CantidadMax
	RETURN @Total
END
CREATE OR ALTER PROCEDURE USP_QUERY2
AS 
BEGIN
SELECT COUNT(dbo.Ocupado85(id_avion)) AS Total FROM Avion
WHERE dbo.Ocupado85(id_avion) >= 0.85
END
--3


