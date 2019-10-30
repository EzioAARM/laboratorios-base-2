/*
create table RandomNames
(id int,
 name varchar(100), lastname varchar(100), nacionalidad varchar(100)
)

insert into RandomNames
(id, name, lastname,nacionalidad)
select 1,'Bill','Hernandez', 'cu'
union
select 2,'John', 'Alvarez', 'gt'
union
select 3,'Steve', 'Garcia', 'mx'
union
select 4,'Mike','Diaz', 'sv'
union
select 5,'Phil','Marroquin', 'pan'
union
select 6,'Sarah','Pozo', 'par'
union
select 7,'Ann','Escobar', 'hn'
union
select 8,'Marie','Linares', 'usa'
union
select 9,'Liz','Smith', 'es'
union
select 10,'Stephanie','Estevez', 'uk'
union
select 11,'Edith','Abreu', 'rs'
union
select 12,'Omari','Melendez', 'in'
union
select 13,'Albi','Montenegro', 'aus'
union
select 14,'Jaidon','Nuñez', 'cu'
union
select 15,'Margaret','Garcia', 'es'
union
select 16,'John','Olivera', 'gt'
union
select 17,'Miguel','Gonzales', 'mx'
union
select 18,'Cari','Juarez','us'
union
select 19,'Carlos','Perez', 'us' 
union
select 20,'Maykel','Oliva', 'cu'
*/	
	
	
	
	
select * from Persona
USE ABCaerolinea

GO
/*
	Procedimiento para crear usuarios y salvar las transacciones que no hayan dado error
*/
create or alter PROCEDURE CrearUsuarios @Cantidad int
AS
	DECLARE @Nombre VARCHAR(100), @Apellido VARCHAR(100), @Nacionalidad VARCHAR(100), @Fecha DATE, @Var int, @rdate DATE 	 
	BEGIN TRANSACTION Insertamos
	WHILE(@Cantidad > 0) 
	BEGIN
	SET @Var = (SELECT FLOOR(RAND()*(6-1)+1))
	SET @Nombre = (select name from RandomNames where id =  (CAST(RAND()*100 as int) % 20)  )
	SET @Apellido = (select lastname from RandomNames where id =  (CAST(RAND()*100 as int) % 20)  )
	SET @Nacionalidad =( select nacionalidad from RandomNames where id =  (CAST(RAND()*100 as int) % 20))
	SET @Fecha = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 364), '2019-01-01')
		BEGIN TRY
			INSERT INTO Persona VALUES (@Var, @Nombre, @Apellido, @Nacionalidad, '1998/01/05', '');
			SAVE TRANSACTION Insertamos
		END TRY
		BEGIN CATCH
			DECLARE @Error VARCHAR
			PRINT ERROR_MESSAGE()
		END CATCH
		SET @Cantidad -= 1;
	END
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION
	END
GO
exec CrearUsuariosR @Cantidad =2
DELETE FROM Persona
select * from Persona
/*
	Procedimiento para crear usuarios y
	Cuando encuentre un usuario mal ingresado
	Retrocedera todo  
*/
ALTER PROCEDURE CrearUsuariosR @Cantidad int 
AS 
	DECLARE @Nombre VARCHAR(100), @Apellido VARCHAR(100), @Nacionalidad VARCHAR(100), @Fecha DATE, @Var int, @rdate DATE 
	BEGIN TRANSACTION
	WHILE(@Cantidad > 0) 
		BEGIN
			SET @Nombre = (select name from RandomNames where id =  (CAST(RAND()*100 as int) % 20) ) 
			SET @Apellido = (select lastname from RandomNames where id =  (CAST(RAND()*100 as int) % 20)  )
			SET @Nacionalidad = (select nacionalidad from RandomNames where id =  (CAST(RAND()*100 as int) % 20) )
			SET @Fecha = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 364), '2019-01-01')
			SET @Var = (SELECT FLOOR(RAND()*(6-1)+1))
			BEGIN TRY
				INSERT INTO Persona VALUES (@Var, @Nombre, @Apellido, @Nacionalidad, @Fecha);
			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE()
				ROLLBACK TRANSACTION
				BREAK
			END CATCH
			SET @Cantidad -= 1;
		END
			IF @@TRANCOUNT > 0 
			BEGIN
			COMMIT TRANSACTION
			END
GO