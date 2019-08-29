CREATE FUNCTION hojasTrabajadas (@fechaInicial DATE, @horaInicial TIME, @fechaFinal DATE, @horaFinal TIME)
RETURNS INT
AS
BEGIN
	DECLARE @diaActual AS NVARCHAR(50)
	DECLARE @horasPrimerDia AS INT
	SELECT @horasPrimerDia = DATEDIFF(HOUR, @horaInicial, '17:00:00')
	DECLARE @horasUltimoDia AS INT
	SELECT @horasUltimoDia = DATEDIFF(HOUR, '08:00:00', @horaFinal)
	IF @horasPrimerDia < 0
	BEGIN
		SET @horasPrimerDia = 0
	END;
	IF @horasUltimoDia < 0
	BEGIN
		SET @horasUltimoDia = 0
	END;
	DECLARE @i AS INT
	SET @i = 0
	DECLARE @diadiff AS INT
	SELECT @diadiff = DATEDIFF(DAY, @fechaInicial, @fechaFinal);
	DECLARE @fechaActual AS DATE
	SET @fechaActual = @fechaInicial
	DECLARE @horasTotal AS INT
	SET @horasTotal = 0
	WHILE (@i < @diadiff)
	BEGIN
		SELECT @diaActual = DATENAME(WEEKDAY, @fechaActual)
		IF @diaActual != 'Friday' AND @diaActual != 'Sunday' AND @diaActual != 'Saturday'
		BEGIN
			IF @i = 0 
			BEGIN
				SET @horasTotal = @horasPrimerDia
			END
			ELSE
			BEGIN
				SET @horasTotal = @horasTotal + 8
			END;
		END;
		SET @fechaActual = DATEADD(DAY, 1, @fechaActual)
		SET @i = @i + 1;
	END;
	SET @horasTotal = @horasTotal + @horasUltimoDia
	RETURN @horasTotal
END;