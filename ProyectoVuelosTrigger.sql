--select * from Escala

CREATE or ALTER TRIGGER triggerVuelo ON Escala
AFTER UPDATE, INSERT
AS
BEGIN
	DECLARE @Origen int, @Destino int, @FechaInicio datetime, @FechaAux datetime
	SET @Origen = (select origen from inserted)
	SET @Destino = (SELECT destino from inserted)
	SET @FechaInicio = (Select fecha_inicio FROM inserted)

	DECLARE Auxiliar CURSOR FOR SELECT fecha_inicio FROM Escala WHERE @Origen = origen AND @Destino = destino
	OPEN Auxiliar
	WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM Auxiliar into  @FechaAux
		IF CONVERT(DATE, @FechaAux) = CONVERT(DATE, @FechaInicio)				--Primero validamos que sean de la misma fecha
		BEGIN
			IF DATEPART(HOUR, @FechaAux) <= 12									--Vemos si la hora AUX es menor o igual a 12hrs
			BEGIN
				IF DATEPART(HOUR, @FechaInicio) <= 12							--En caso de que la fecha que se inserto/actulizao es menor o igual TAMBIEN a 12hrs
				BEGIN
					PRINT 'No se permite vuelos del mismo origen, destino, dia y jornada iguales'
					ROLLBACK
				END
			END
			IF DATEPART(HOUR, @FechaAux) > 12									---Vemos si la hora AUX es mayor a 12hrs
			BEGIN
				IF DATEPART(HOUR, @FechaInicio) > 12							--Si coinciden las horas
				BEGIN
					PRINT 'No se permite vuelos del mismo origen, destino, dia y jornada iguales'
					ROLLBACK
				END
			END
		END
	END
	CLOSE Auxiliar
	DEALLOCATE Auxiliar 
END