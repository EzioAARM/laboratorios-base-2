USE master;
GO
DROP DATABASE ABCaerolinea;
GO
CREATE DATABASE ABCaerolinea 
GO

USE ABCaerolinea
GO

/*
	Supertipo persona para luego dividirlo en Cliente o trabajador
*/
CREATE TABLE Persona (
	Identificacion INT PRIMARY KEY, 
	Nombres VARCHAR(50), 
	Apellidos VARCHAR(50), 
	Nacionalidad VARCHAR(50), 
	Fecha_Nacimiento DATE,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
)

/*
	Informacion sobre los clientes
*/
CREATE TABLE Cliente (
	id_cliente INT PRIMARY KEY,
	id_persona INT NOT NULL, 
	informacion_Relevante VARCHAR(250),
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_Cliente_Persona FOREIGN KEY (id_persona) REFERENCES Persona(Identificacion)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Informacion sobre los empleados que tiene la empresa
*/
CREATE TABLE Trabajador (
	codigo_trabajador INT PRIMARY KEY, 
	id_persona INT NOT NULL,
	Salario_A decimal NOT NULL,
	activo BIT,
	fecha_contratacion DATETIME,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_Trabajador_Persona FOREIGN KEY (id_persona) REFERENCES Persona(Identificacion)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Guarda informacion sobre el historial de salarios que han tenido los empleados
*/
CREATE TABLE Salarios(
	codigo_trabajador INT NOT NULL,
	salario DECIMAL NOT NULL,
	Fecha_pago DATETIME NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT Pk_cTrabajador_Salario PRIMARY KEY (codigo_trabajador, Fecha_pago),
	CONSTRAINT fk_salarios_historial FOREIGN KEY (codigo_trabajador) REFERENCES Trabajador(codigo_trabajador)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
)

/*
	Guarda informacion sobre los aviones que tiene la empresa
*/
CREATE TABLE Avion (
	id_avion INT PRIMARY KEY,
	Cantidad_maxima INT NOT NULL,
	Tipo_Avion VARCHAR(50),
	fecha_modificacion DATETIME DEFAULT GETDATE(),
)

/*
	Guarda informacion sobre los paises en los que hay aeropuertos
*/
CREATE TABLE Pais(
	id_pais INT PRIMARY KEY IDENTITY (1,1),
	Nombre VARCHAR(100) NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
)

/*
	Guarda informacion sobre las ciudades en las que hay aeropuertos
*/
CREATE TABLE Ciudad(
	id_ciudad INT PRIMARY KEY,
	id_pais INT NOT NULL,
	nombre VARCHAR(100),
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Tiene informacion sobre puntos de partida y destinos (aeropuertos)
*/
CREATE TABLE Aeropuertos (
	id_aeropuerto INT PRIMARY KEY,
	id_ciudad INT NOT NULL,
	nombre VARCHAR(100),
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_Aeropuerto_Ciudad FOREIGN KEY (id_ciudad) REFERENCES Ciudad(id_ciudad)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Guarda el origen y el destino del vuelo, el resto de informacion se encuentra en la tabla "Escala"
*/
CREATE TABLE Vuelo(
	id_vuelo INT PRIMARY KEY IDENTITY(1, 1),
	origen INT NOT NULL,
	destino INT NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_origen_aeropuerto FOREIGN KEY (origen) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	CONSTRAINT fk_destino_aeropuerto FOREIGN KEY (destino) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
)

/*
	El listado de escalas relacionados con un vuelo especifico
*/
CREATE TABLE Escala(
	id_escala INT PRIMARY KEY IDENTITY(1, 1),
	id_vuelo INT NOT NULL,
	id_avion INT NOT NULL,
	origen INT NOT NULL,
	destino INT NOT NULL,
	id_piloto INT NOT NULL,
	fecha_inicio DATETIME NOT NULL,
	fecha_fin DATETIME NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_escala_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_escala_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_escala_origen FOREIGN KEY (origen) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	CONSTRAINT fk_escala_destino FOREIGN KEY (destino) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	CONSTRAINT fk_escala_trabajador FOREIGN KEY (id_piloto) REFERENCES Trabajador(codigo_trabajador)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	El listado de trabajadores que esta en el vuelo
*/
CREATE TABLE Tripulacion (
	codigo_trabajador INT NOT NULL,
	id_vuelo INT NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_tripulacion_trabajador FOREIGN KEY (codigo_trabajador) REFERENCES Trabajador(codigo_trabajador)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_tripulacion_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT pk_tripulacion PRIMARY KEY (codigo_trabajador, id_vuelo)
)

/*
	Lleva registro de las clases registradas para los aviones
*/
CREATE TABLE Clase(
	id_clase INT PRIMARY KEY IDENTITY(1,5),
	id_avion INT NOT NULL,
	tipo VARCHAR(50) NOT NULL,
	cantidad_pasajeros INT NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_clase_avion FOREIGN KEY(id_avion) REFERENCES Avion(id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT ck_tipoclase CHECK (tipo = 'Primera' OR tipo = 'Economica' OR tipo = 'Ejecutiva' )
)

/*
	Registro de la informacion de los asientos disponibles por avion
*/
CREATE TABLE Asientos(
	id_asiento INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
	numero_asiento VARCHAR(10) NOT NULL,
	id_avion INT NOT NULL, 
	id_clase INT NOT NULL,
	informacion_extra VARCHAR(MAX),
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_asientos_clase FOREIGN KEY (id_clase) REFERENCES Clase(id_clase)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_asientos_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
)

/*
	Luego de confirmar se emite el boleto (inserta en esta tabla)
*/
CREATE TABLE Boletos(
	numero_boleto INT,
	id_avion INT NOT NULL,
	id_cliente INT NOT NULL,
	id_escala INT NOT NULL,
	id_clase INT NOT NULL,
	id_asiento INT NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_boletos_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_boletos_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_boletos_escala FOREIGN KEY (id_escala) REFERENCES Escala(id_escala)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	CONSTRAINT fk_boletos_clase FOREIGN KEY (id_clase) REFERENCES Clase(id_clase)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	CONSTRAINT fk_boletos_asiento FOREIGN KEY (id_asiento) REFERENCES Asientos(id_asiento)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	CONSTRAINT pk_boletos PRIMARY KEY (numero_boleto, id_escala)
)

/*
	Tiene registro de las plataformas o lugares en los cuales se pueden hacer transacciones
	Por ejemplo una app, una plataforma web, sucursales, etc
*/
CREATE TABLE Plataforma(
	id_plataforma INT PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE()
)

/*
	Reservas existentes para los asientos disponibles a la fecha actual
	Luego de eso se van a HistorialReservas
*/
CREATE TABLE Reservas(
	id_reserva INT PRIMARY KEY IDENTITY(1, 1),
	id_vuelo INT NOT NULL,
	estado varchar(50) not null,
	id_clase INT NOT NULL,
	id_avion INT NOT NULL,
	precio DECIMAL,
	descuento DECIMAL,
	plataforma INT NOT NULL,
	id_asiento INT NOT NULL,
	fecha_vencimiento DATETIME,
	fecha_modificacion DATETIME DEFAULT GETDATE(),
	CONSTRAINT fk_reserva_clase FOREIGN KEY (id_clase) REFERENCES Clase(id_clase)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_reserva_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	CONSTRAINT fk_reserva_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_reserva_plataforma FOREIGN KEY (plataforma) REFERENCES Plataforma(id_plataforma)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_reserva_asiento FOREIGN KEY (id_asiento) REFERENCES Asientos(id_asiento)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
)

/*
	Almacenamiento temporal para las personas que estan en cola para reservar un asiento
*/
CREATE TABLE ColaReservas(
	id_cola INT PRIMARY KEY IDENTITY(1, 1),
	id_vuelo INT NOT NULL,
	id_clase INT NOT NULL,
	id_avion INT NOT NULL,
	id_asiento INT NOT NULL,
	fecha_modificacion DATETIME DEFAULT GETDATE()
)

/*
	Tabla para el historial de las reservas, cancelaciones y personas en cola
*/
CREATE TABLE HistorialReservas(
	id_historial INT IDENTITY(1, 1) PRIMARY KEY,
	id_reserva INT,
	id_vuelo INT NOT NULL,
	estado varchar(50) not null,
	id_clase INT NOT NULL,
	id_avion INT NOT NULL,
	precio DECIMAL,
	descuento DECIMAL,
	plataforma INT NOT NULL,
	id_asiento VARCHAR(10) NOT NULL,
	fecha_transaccion DATETIME DEFAULT GETDATE(),
	fecha_modificacion DATETIME DEFAULT GETDATE()
)
/*
	Creacion de triggers
*/
GO
-- Trigger para agregar automaticamente cada modificacion que se haga en las reservas y poder llevar un historial completo
CREATE OR ALTER TRIGGER agregarHistorial
ON Reservas
AFTER INSERT, UPDATE 
AS
BEGIN
    INSERT INTO HistorialReservas 
	SELECT * FROM inserted;
END

GO
-- Triggers para actualizar la fecha de modificacion de los registros en cada tabla
CREATE OR ALTER TRIGGER fechaModificacionPersona
ON Persona
AFTER UPDATE
AS
BEGIN
	UPDATE Persona SET fecha_modificacion = GETDATE() 
	FROM Persona INNER JOIN inserted i ON Persona.Identificacion = i.Identificacion;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionCliente
ON Cliente
AFTER UPDATE
AS
BEGIN
	UPDATE Cliente SET fecha_modificacion = GETDATE() 
	FROM Cliente INNER JOIN inserted i ON Cliente.id_cliente = i.id_cliente;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionTrabajador
ON Trabajador
AFTER UPDATE
AS
BEGIN
	UPDATE Trabajador SET fecha_modificacion = GETDATE() 
	FROM Trabajador INNER JOIN inserted i ON Trabajador.codigo_trabajador = i.codigo_trabajador;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionSalarios
ON Salarios
AFTER UPDATE
AS
BEGIN
	UPDATE Salarios SET fecha_modificacion = GETDATE() 
	FROM Salarios INNER JOIN inserted i ON Salarios.codigo_trabajador = i.codigo_trabajador AND Salarios.fecha_pago = i.fecha_pago;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionAvion
ON Avion
AFTER UPDATE
AS
BEGIN
	UPDATE Avion SET fecha_modificacion = GETDATE() 
	FROM Avion INNER JOIN inserted i ON Avion.id_avion = i.id_avion;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionPais
ON Pais
AFTER UPDATE
AS
BEGIN
	UPDATE Pais SET fecha_modificacion = GETDATE() 
	FROM Pais INNER JOIN inserted i ON Pais.id_pais = i.id_pais;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionCiudad
ON Ciudad
AFTER UPDATE
AS
BEGIN
	UPDATE Ciudad SET fecha_modificacion = GETDATE() 
	FROM Ciudad INNER JOIN inserted i ON Ciudad.id_ciudad = i.id_ciudad;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionAeropuertos
ON Aeropuertos
AFTER UPDATE
AS
BEGIN
	UPDATE Aeropuertos SET fecha_modificacion = GETDATE() 
	FROM Aeropuertos INNER JOIN inserted i ON Aeropuertos.id_aeropuerto = i.id_aeropuerto;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionVuelo
ON Vuelo
AFTER UPDATE
AS
BEGIN
	UPDATE Vuelo SET fecha_modificacion = GETDATE() 
	FROM Vuelo INNER JOIN inserted i ON Vuelo.id_vuelo = i.id_vuelo;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionEscala
ON Escala
AFTER UPDATE
AS
BEGIN
	UPDATE Escala SET fecha_modificacion = GETDATE() 
	FROM Escala INNER JOIN inserted i ON Escala.id_escala = i.id_escala;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionTripulacion
ON Tripulacion
AFTER UPDATE
AS
BEGIN
	UPDATE Tripulacion SET fecha_modificacion = GETDATE() 
	FROM Tripulacion INNER JOIN inserted i ON Tripulacion.codigo_trabajador = i.codigo_trabajador;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionClase
ON Clase
AFTER UPDATE
AS
BEGIN
	UPDATE Clase SET fecha_modificacion = GETDATE() 
	FROM Clase INNER JOIN inserted i ON Clase.id_clase = i.id_clase;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionAsientos
ON Asientos
AFTER UPDATE
AS
BEGIN
	UPDATE Asientos SET fecha_modificacion = GETDATE() 
	FROM Asientos INNER JOIN inserted i ON Asientos.id_asiento = i.id_asiento;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionBoletos
ON Boletos
AFTER UPDATE
AS
BEGIN
	UPDATE Boletos SET fecha_modificacion = GETDATE() 
	FROM Boletos INNER JOIN inserted i ON Boletos.numero_boleto = i.numero_boleto;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionPlataforma
ON Plataforma
AFTER UPDATE
AS
BEGIN
	UPDATE Plataforma SET fecha_modificacion = GETDATE() 
	FROM Plataforma INNER JOIN inserted i ON Plataforma.id_plataforma = i.id_plataforma;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionReservas
ON Reservas
AFTER UPDATE
AS
BEGIN
	UPDATE Reservas SET fecha_modificacion = GETDATE() 
	FROM Reservas INNER JOIN inserted i ON Reservas.id_reserva = i.id_reserva;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionColaReservas
ON ColaReservas
AFTER UPDATE
AS
BEGIN
	UPDATE ColaReservas SET fecha_modificacion = GETDATE() 
	FROM ColaReservas INNER JOIN inserted i ON ColaReservas.id_cola = i.id_cola;
END

GO

CREATE OR ALTER TRIGGER fechaModificacionHistorialReservas
ON HistorialReservas
AFTER UPDATE
AS
BEGIN
	UPDATE HistorialReservas SET fecha_modificacion = GETDATE() 
	FROM HistorialReservas INNER JOIN inserted i ON HistorialReservas.id_reserva = i.id_reserva;
END

GO

CREATE OR ALTER TRIGGER verificarEscalas
ON Escala
AFTER INSERT
AS
BEGIN
	DECLARE @insertado AS INT
	DECLARE @vuelo AS INT
	SELECT @insertado = id_escala, @vuelo = id_vuelo FROM inserted
	DECLARE @cantidadRegistros AS INT
	SELECT @cantidadRegistros = COUNT(id_escala) FROM Escala WHERE id_vuelo = @vuelo
	IF @cantidadRegistros > 3
	BEGIN
		ROLLBACK TRANSACTION;
	END
	ELSE 
	BEGIN
		COMMIT TRANSACTION;
	END
END
