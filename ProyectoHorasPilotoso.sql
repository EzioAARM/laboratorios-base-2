--Select * from Escala

CREATE OR ALTER FUNCTION dbo.HorasPiloto10h (@idpiloto int)  
	RETURNS int    
AS  
BEGIN     
	DECLARE @piloto_id int, @total int, @dateStart date, @dateEnd date
	set @total =0
	DECLARE piloto_cursor CURSOR FOR   
	SELECT top 10 id_piloto, fecha_inicio, fecha_fin FROM Escala	order by id_piloto 
	OPEN vendor_cursor    
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		FETCH NEXT FROM piloto_cursor INTO @piloto_id,@dateStart, @dateEnd
		set @total+= (DATEDIFF(hh, @dateStart ,@dateEnd))
	END
	CLOSE piloto_cursor 
	DEALLOCATE piloto_cursor 
	RETURN @total  
	END  
	GO  

CREATE OR ALTER FUNCTION dbo.HorasPiloto6m (@idpiloto int)  
RETURNS int  
AS  
BEGIN     
	DECLARE @piloto_id int, @total int, @dateStart date, @dateEnd date
	DECLARE piloto_cursor CURSOR FOR   
	SELECT id_piloto, fecha_inicio , fecha_fin FROM Escala
	where month(fecha_inicio) >= 4 order by id_piloto
	OPEN vendor_cursor    
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		FETCH NEXT FROM piloto_cursor INTO @piloto_id, @dateStart, @dateEnd
		set @total+= (DATEDIFF(hh, @dateStart,@dateEnd))
	END
	CLOSE piloto_cursor 
	DEALLOCATE piloto_cursor 
	RETURN(@total)  
END;  
GO  


