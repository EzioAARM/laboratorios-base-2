CREATE PROCEDURE USP_CREAR_TABLA_RESUMEN AS
BEGIN
	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='RESUMEN' and xtype='U')
		CREATE TABLE RESUMEN (
			nombre_departamento varchar(64) not null primary key,
			cantidad_empleado int not null,
			salaios float not null
		)
END