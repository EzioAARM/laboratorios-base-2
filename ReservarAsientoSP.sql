USE ABCaerolinea
GO

CREATE OR ALTER PROCEDURE USP_reservarAsiento(@vuelo AS INT, @plataforma AS INT, @tiempoReserva AS INT, @asientoE1 AS INT, @asientoE2 AS INT = NULL, @asientoE3 AS INT = NULL)
AS
BEGIN
	BEGIN TRANSACTION;
	DECLARE @cantidadAviones AS INT
	SELECT @cantidadAviones = COUNT(id_avion) FROM Escala INNER JOIN Vuelo ON Escala.id_vuelo = Vuelo.id_vuelo WHERE Escala.id_vuelo = @vuelo;
	IF (@cantidadAviones = 2 AND @asientoE2 IS NULL) OR (@cantidadAviones = 3 AND @asientoE3 IS NULL)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 54000, 'Se debe ingresar una cantidad adecuada de asientos', 1;
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
							THROW 54000, 'El segundo asiento no corresponde a una escala del vuelo que se desea', 1;
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
							THROW 54000, 'El tercer asiento no corresponde a una escala del vuelo que se desea', 1;
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
			--Save transaction ReservaInicial;
			COMMIT TRANSACTION;
		END
	ELSE
		BEGIN
			ROLLBACK TRANSACTION;
			THROW 54000, 'El primer asiento no corresponde a una escala del vuelo que se desea', 1;
		END
END
GO


CREATE OR ALTER PROCEDURE USP_CheckReserva
AS
BEGIN
	update Reservas
	set estado = 'cancelado'
	where DATEDIFF(MI, fecha_vencimiento, getdate()) <= 0;
END
GO


USE msdb
GO
CREATE OR ALTER PROCEDURE USP_CREACIONJOB
AS 
BEGIN


EXEC dbo.sp_add_job
	@job_name = N'ChekDate';


EXEC dbo.sp_add_jobstep
	@job_name = N'ChekDate',
	@step_name = N'Correr el SP',  
    @subsystem = N'TSQL',  
    @command = N'USE ABCaerolinea; EXEC USP_CheckReserva;',   
    @retry_attempts = 1,  
    @retry_interval = 1; 
	
EXEC dbo.sp_add_schedule  
    @schedule_name = N'CadaMinuto',  
    @freq_type = 4,
	@freq_interval = 127,
	@freq_subday_type = 4,
	@freq_subday_interval = 1,
	@active_start_time = 233000 ;
	

EXEC sp_attach_schedule  
   @job_name = N'ChekDate',  
   @schedule_name = N'CadaMinuto';  


EXEC dbo.sp_add_jobserver  
    @job_name = N'ChekDate';   

EXEC sp_start_job @job_name = N'ChekDate';
END

