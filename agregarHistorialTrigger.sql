CREATE OR ALTER TRIGGER agregarHistorial
ON Reservas
AFTER INSERT, UPDATE 
AS
BEGIN
    INSERT INTO HistorialReservas 
	SELECT * FROM inserted;
END

GO

CREATE OR ALTER PROCEDURE USP_reservarAsiento(@vuelo AS INT, @plataforma AS INT, @asientoE1 AS INT, @asientoE2 AS INT = NULL, @asientoE3 AS INT = NULL)
AS
BEGIN
	BEGIN TRANSACTION;
	DECLARE @cantidadAviones AS INT
	SELECT @cantidadAviones = COUNT(id_avion) FROM Escala INNER JOIN Vuelo ON Escala.id_vuelo = Vuelo.id_vuelo;
	IF (@cantidadAviones = 2 AND @asientoE2 IS NULL) OR (@cantidadAviones = 3 AND @asientoE3 IS NULL)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 5400, 'Se debe ingresar una cantidad adecuada de asientos', -1;
	END
	--Datos para la primera escala
	DECLARE @primerAvionReal AS INT
	DECLARE @primerAvionClase AS INT
	SELECT @primerAvionReal = id_avion, @primerAvionClase = id_clase FROM Asientos WHERE id_asiento = @asientoE1;
	DECLARE @existeAvion AS BIT
	SELECT @existeAvion = CASE WHEN COUNT(id_avion) = 0 THEN 0 ELSE 1 END
	FROM Escala WHERE id_avion = @primerAvionReal AND id_vuelo = @vuelo;
	IF @existeAvion = 1 
		BEGIN
			DECLARE @estadoActual AS VARCHAR(50)
			--Estado del primer asiendo
			SELECT @estadoActual = estado FROM Reservas WHERE id_vuelo = @vuelo AND id_asiento = @asientoE1;
			IF @estadoActual = 'reservado' OR @estadoActual = 'confirmado'
				BEGIN
					INSERT INTO ColaReservas (id_vuelo, id_clase, id_avion, id_asiento) VALUES (@vuelo, @primerAvionClase, @primerAvionReal, @asientoE1);
				END
			ELSE
				BEGIN
					UPDATE Reservas SET estado = 'reservado' WHERE id_vuelo = @vuelo AND id_asiento = @asientoE1
				END
			IF @asientoE2 IS NOT NULL
				BEGIN
					DECLARE @segundoAvionReal AS INT
					SELECT @segundoAvionReal = id_avion FROM Asientos WHERE id_asiento = @asientoE2;
					SELECT @existeAvion = CASE WHEN COUNT(id_avion) = 0 THEN 0 ELSE 1 END
					FROM Escala WHERE id_avion = @segundoAvionReal AND id_vuelo = @vuelo;
					IF @existeAvion = 0
						BEGIN
							ROLLBACK TRANSACTION;
							THROW 5400, 'El segundo asiento no corresponde a una escala del vuelo que se desea', -1;
						END
					SELECT @estadoActual = estado FROM Reservas WHERE id_vuelo = @vuelo AND id_asiento = @asientoE2;
					IF @estadoActual = 'reservado' OR @estadoActual = 'confirmado'
						BEGIN
							INSERT INTO ColaReservas (id_vuelo, id_clase, id_avion, id_asiento) VALUES (@vuelo, @primerAvionClase, @primerAvionReal, @asientoE2);
						END
					ELSE
						BEGIN
							UPDATE Reservas SET estado = 'reservado' WHERE id_vuelo = @vuelo AND id_asiento = @asientoE2
						END
				END
			IF @asientoE3 IS NOT NULL
				BEGIN
					DECLARE @tercerAvionReal AS INT
					SELECT @tercerAvionReal = id_avion FROM Asientos WHERE id_asiento = @asientoE3;
					SELECT @existeAvion = CASE WHEN COUNT(id_avion) = 0 THEN 0 ELSE 1 END
					FROM Escala WHERE id_avion = @tercerAvionReal AND id_vuelo = @vuelo;
					IF @existeAvion = 0
						BEGIN
							ROLLBACK TRANSACTION;
							THROW 5400, 'El tercer asiento no corresponde a una escala del vuelo que se desea', -1;
						END
					SELECT @estadoActual = estado FROM Reservas WHERE id_vuelo = @vuelo AND id_asiento = @asientoE3;
					IF @estadoActual = 'reservado' OR @estadoActual = 'confirmado'
						BEGIN
							INSERT INTO ColaReservas (id_vuelo, id_clase, id_avion, id_asiento) VALUES (@vuelo, @primerAvionClase, @primerAvionReal, @asientoE3);
						END
					ELSE
						BEGIN
							UPDATE Reservas SET estado = 'reservado' WHERE id_vuelo = @vuelo AND id_asiento = @asientoE3
						END
				END
			COMMIT TRANSACTION;
		END
	ELSE
		BEGIN
			ROLLBACK TRANSACTION;
			THROW 5400, 'El primer asiento no corresponde a una escala del vuelo que se desea', -1;
		END
END