CREATE OR ALTER PROCEDURE USP_reservarAsiento(@vuelo AS INT, @plataforma AS INT, @tiempoReserva AS INT, @asientoE1 AS INT, @asientoE2 AS INT = NULL, @asientoE3 AS INT = NULL)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
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
					UPDATE Reservas SET estado = 'reservado', fecha_vencimiento = DATEADD(MINUTE, @tiempoReserva, GETDATE()) WHERE id_vuelo = @vuelo AND id_asiento = @asientoE1
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
							UPDATE Reservas SET estado = 'reservado', fecha_vencimiento = DATEADD(MINUTE, @tiempoReserva, GETDATE()) WHERE id_vuelo = @vuelo AND id_asiento = @asientoE2
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
							UPDATE Reservas SET estado = 'reservado', fecha_vencimiento = DATEADD(MINUTE, @tiempoReserva, GETDATE()) WHERE id_vuelo = @vuelo AND id_asiento = @asientoE3
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

GO

CREATE OR ALTER PROCEDURE USP_confirmarReserva(@reserva AS INT, @cliente AS INT)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		DECLARE @avion AS INT
		DECLARE @clase AS INT
		DECLARE @vuelo AS INT
		DECLARE @boleto AS INT
		SELECT TOP 1 @avion = id_avion, @clase = id_clase, @vuelo = id_vuelo FROM Reservas WHERE id_reserva = @reserva;
		SELECT @boleto = MAX(numero_boleto) FROM Boletos;
		SET @boleto = @boleto + 1;
		INSERT INTO Boletos (numero_boleto, id_avion, id_cliente, id_escala, id_clase, id_asiento) 
		SELECT @boleto, @avion, @cliente, id_escala, @clase, id_asiento FROM Reservas INNER JOIN Escala ON Reservas.id_vuelo = Escala.id_vuelo;
		UPDATE Reservas SET estado = 'confirmado' WHERE id_reserva = @reserva;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH
END

GO

CREATE OR ALTER PROCEDURE USP_cancelarReserva(@reserva AS INT)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		DECLARE @fechaActual AS DATETIME
		DECLARE @fechaVence AS DATETIME
		SELECT @fechaActual = GETDATE(), @fechaVence = fecha_vencimiento FROM Reservas WHERE id_reserva = @reserva;
		IF (@fechaActual >= @fechaVence)
		BEGIN
			UPDATE Reservas SET estado = 'cancelado' WHERE id_reserva = @reserva;
			UPDATE Reservas SET estado = 'disponible' WHERE id_reserva = @reserva;
			DECLARE @vueloReserva AS INT
			DECLARE @asientoReserva AS INT
			SELECT @vueloReserva = id_vuelo, @asientoReserva = id_asiento FROM Reservas WHERE id_reserva = @reserva
			DECLARE @personasCola AS INT
			SELECT @personasCola = COUNT(1) FROM ColaReservas WHERE id_vuelo = @vueloReserva AND id_asiento = @asientoReserva
			IF @personasCola > 0 
			BEGIN
				DECLARE @personaCola AS INTEGER
				SELECT TOP 1 @personaCola = id_cola FROM ColaReservas WHERE id_vuelo = @vueloReserva AND id_asiento = @asientoReserva
				ORDER BY fecha_modificacion ASC
				UPDATE Reservas SET estado = 'reservado' WHERE id_vuelo = @vueloReserva AND id_asiento = @asientoReserva
				DELETE FROM ColaReservas WHERE id_cola = @personaCola
			END
		END
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH
END