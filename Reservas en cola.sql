CREATE OR ALTER FUNCTION dbo.ReservasenCola (@month int, @year int)  
RETURNS int  
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @Cantidad int;  
     SET @Cantidad =  (select count(*) from ColaReservas  where month(fecha_modificacion)= @month and year(fecha_modificacion)=@year )
     RETURN(@Cantidad);  
END;  
GO  
