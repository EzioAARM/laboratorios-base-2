CREATE DATABASE ABCaerolinea 
GO

USE ABCaerolinea
GO

CREATE TABLE Persona (
	Identificacion INT PRIMARY KEY, 
	Nombres VARCHAR(50), 
	Apellidos VARCHAR(50), 
	Nacionalidad VARCHAR(50), 
	Fecha_Nacimiento DATE
)

CREATE TABLE Cliente (
	id_cliente INT PRIMARY KEY,
	id_persona INT NOT NULL, 
	informacion_Relevante VARCHAR(250),
	CONSTRAINT fk_Cliente_Persona FOREIGN KEY (id_persona) REFERENCES Persona(Identificacion)
)

CREATE TABLE Trabajador (
	codigo_trabajador INT PRIMARY KEY, 
	id_persona INT NOT NULL,
	Salario_A decimal NOT NULL,
	activo BIT,
	fecha_contratacion DATETIME,
	CONSTRAINT fk_Trabajador_Persona FOREIGN KEY (id_persona) REFERENCES Persona(Identificacion)
)

CREATE TABLE Salarios(
	codigo_trabajador INT NOT NULL,
	salario DECIMAL NOT NULL,
	Fecha_pago DATETIME NOT NULL,
	CONSTRAINT Pk_cTrabajador_Salario PRIMARY KEY (codigo_trabajador, Fecha_pago)
)

CREATE TABLE Avion (
	id_avion INT PRIMARY KEY,
	Cantidad_maxima INT NOT NULL,
	Tipo_Avion VARCHAR(50)
)

CREATE TABLE Pais(
	id_pais INT PRIMARY KEY IDENTITY (1,1),
	Nombre VARCHAR(100) NOT NULL
)

CREATE TABLE Ciudad(
	id_ciudad INT PRIMARY KEY,
	id_pais INT NOT NULL,
	nombre VARCHAR(100),
	CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
)

CREATE TABLE Aeropuertos (
	id_aeropuerto INT PRIMARY KEY,
	id_ciudad INT NOT NULL,
	nombre VARCHAR(100),
	CONSTRAINT fk_Aeropuerto_Ciudad FOREIGN KEY (id_ciudad) REFERENCES Ciudad(id_ciudad)
)

CREATE TABLE Vuelo(
	id_vuelo INT PRIMARY KEY IDENTITY(1, 1),
	origen INT NOT NULL,
	destino INT NOT NULL,
	CONSTRAINT fk_origen_aeropuerto FOREIGN KEY (origen) REFERENCES Aeropuertos(id_aeropuerto),
	CONSTRAINT fk_destino_aeropuerto FOREIGN KEY (destino) REFERENCES Aeropuertos(id_aeropuerto)
)

CREATE TABLE Escala(
	id_escala INT PRIMARY KEY IDENTITY(1, 1),
	id_vuelo INT NOT NULL,
	id_avion INT NOT NULL,
	origen INT NOT NULL,
	destino INT NOT NULL,
	id_piloto INT NOT NULL,
	fecha_inicio DATETIME NOT NULL,
	fecha_fin DATETIME NOT NULL,
	CONSTRAINT fk_escala_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo),
	CONSTRAINT fk_escala_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion),
	CONSTRAINT fk_escala_origen FOREIGN KEY (origen) REFERENCES Aeropuertos(id_aeropuerto),
	CONSTRAINT fk_escala_destino FOREIGN KEY (destino) REFERENCES Aeropuertos(id_aeropuerto),
	CONSTRAINT fk_escala_trabajador FOREIGN KEY (id_piloto) REFERENCES Trabajador(codigo_trabajador)
)

CREATE TABLE Tripulacion (
	codigo_trabajador INT NOT NULL,
	id_vuelo INT NOT NULL,

	CONSTRAINT fk_tripulacion_trabajador FOREIGN KEY (codigo_trabajador) REFERENCES Trabajador(codigo_trabajador),
	CONSTRAINT fk_tripulacion_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo),
	CONSTRAINT pk_tripulacion PRIMARY KEY (codigo_trabajador, id_vuelo)
)

CREATE TABLE Clase(
	id_clase INT PRIMARY KEY IDENTITY(1,5),
	id_avion INT NOT NULL,
	tipo VARCHAR(50) NOT NULL,
	cantidad_pasajeros INT NOT NULL,

	CONSTRAINT fk_clase_avion FOREIGN KEY(id_avion) REFERENCES Avion(id_avion),
	CONSTRAINT ck_tipoclase CHECK (tipo = 'Primera' OR tipo = 'Economica' OR tipo = 'Ejecutiva' )
)

CREATE TABLE HistorialCostoClase (
	id_avion INT NOT NULL,
	id_clase INT NOT NULL,
	fecha_inicio DATETIME NOT NULL,
	fecha_final DATETIME,
	costo DECIMAL NOT NULL
)

CREATE TABLE Boletos(
	numero_boleto INT PRIMARY KEY IDENTITY(1,1),
	id_avion INT NOT NULL,
	id_cliente INT NOT NULL,
	id_escala INT NOT NULL,
	id_clase INT NOT NULL,
	numero_asiento INT NOT NULL,

	CONSTRAINT fk_boletos_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion),
	CONSTRAINT fk_boletos_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
	CONSTRAINT fk_boletos_escala FOREIGN KEY (id_escala) REFERENCES Escala(id_escala),
	CONSTRAINT fk_boletos_clase FOREIGN KEY (id_clase) REFERENCES Clase(id_clase)
)

CREATE TABLE Plataforma(
	id_plataforma INT PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL
)

CREATE TABLE Reservas(
	id_reserva INT PRIMARY KEY IDENTITY(1, 1),
	num_registro INT NOT NULL,
	id_vuelo INT NOT NULL,
	estado varchar(50) not null,
	id_clase INT NOT NULL,
	id_avion INT NOT NULL,
	precio DECIMAL,
	descuento DECIMAL,
	plataforma INT NOT NULL,

	CONSTRAINT fk_reserva_clase FOREIGN KEY (id_clase) REFERENCES Clase(id_clase),
	CONSTRAINT fk_reserva_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion),
	CONSTRAINT fk_reserva_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo),
	CONSTRAINT fk_reserva_plataforma FOREIGN KEY (plataforma) REFERENCES Plataforma(id_plataforma)
)

CREATE TABLE HistorialReservas(
	id_reserva INT PRIMARY KEY IDENTITY(1, 1),
	id_vuelo INT NOT NULL,
	estado VARCHAR(50) NOT NULL,
	num_registro INT NOT NULL,
	fecha_transaccion DATETIME default GETDATE()
)

