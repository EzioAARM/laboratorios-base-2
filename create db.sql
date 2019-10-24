Create database ABCaerolinea 
go

use ABCaerolinea
go

create table Persona (
	Identificacion int primary key, 
	Nombres varchar(50), 
	Apellidos varchar(50), 
	Nacionalidad varchar(50), 
	Fecha_Nacimiento date
)

create table Cliente (
	id_cliente int primary key,
	id_persona int not null, 
	informacion_Relevante varchar(250),

	Constraint fk_Cliente_Persona foreign key (id_persona) references Persona(Identificacion)

)

create table Trabajador (
	codigo_trabajador int primary key, 
	id_persona int not null,
	Salario_A decimal not null,
	activo bit,
	fecha_contratacion datetime,

	Constraint fk_Trabajador_Persona foreign key (id_persona) references Persona(Identificacion)
)

create table Salarios(
	codigo_trabajador int not null,
	salario decimal not null,
	Fecha_pago datetime not null

	Constraint Pk_cTrabajador_Salario primary key (codigo_trabajador, Fecha_pago)
)

create table Avion (
	id_avion int primary key,
	Cantidad_maxima int not null,
	Tipo_Avion varchar(50)
)

create table Pais(
	id_pais int primary key identity (1,1),
	Nombre varchar(100) not null
)

create table Ciudad(
	id_ciudad int primary key,
	id_pais int not null,
	nombre varchar(100),

	Constraint fk_ciudad_pais foreign key (id_pais) references Pais(id_pais)
)

create table Aeropuertos (
	id_aeropuerto int primary key,
	id_ciudad int not null,
	nombre varchar(100),

	Constraint fk_Aeropuerto_Ciudad foreign key (id_ciudad) references Ciudad(id_ciudad)
)

create table Vuelo(
	id_vuelo int primary key identity(1, 1),
	origen int not null,
	destino int not null,

	Constraint fk_origen_aeropuerto foreign key (origen) references Aeropuertos(id_aeropuerto),
	Constraint fk_destino_aeropuerto foreign key (destino) references Aeropuertos(id_aeropuerto)
)

create table Escala(
	id_escala int primary key identity(1, 1),
	id_vuelo int not null,
	id_avion int not null,
	origen int not null,
	destino int not null,
	id_piloto int not null,
	fecha_inicio datetime not null,
	fecha_fin datetime not null,

	Constraint fk_escala_vuelo foreign key (id_vuelo) references Vuelo(id_vuelo),
	Constraint fk_escala_avion foreign key (id_avion) references Avion(id_avion),
	Constraint fk_escala_origen foreign key (origen) references Aeropuertos(id_aeropuerto),
	Constraint fk_escala_destino foreign key (destino) references Aeropuertos(id_aeropuerto),
	Constraint fk_escala_trabajador foreign key (id_piloto) references Trabajador(codigo_trabajador)
)

create table Tripulacion (
	codigo_trabajador int not null,
	id_vuelo int not null,

	Constraint fk_tripulacion_trabajador foreign key (codigo_trabajador) references Trabajador(codigo_trabajador),
	Constraint fk_tripulacion_vuelo foreign key (id_vuelo) references Vuelo(id_vuelo),
	Constraint pk_tripulacion primary key (codigo_trabajador, id_vuelo)
)

create table Clase(
	id_clase int primary key identity(1,5),
	id_avion int not null,
	tipo varchar(50) not null,
	cantidad_pasajeros int not null,

	Constraint fk_clase_avion foreign key (id_avion) references Avion(id_avion),
	Constraint ck_tipoclase check (tipo = 'Primera' or tipo = 'Economica' or tipo = 'Ejecutiva' )
)

create table HistorialCostoClase (
	id_avion int not null,
	id_clase int not null,
	fecha_inicio datetime not null,
	fecha_final datetime,
	costo decimal not null
)

create table Boletos(
	numero_boleto int primary key identity(1,1),
	id_avion int not null,
	id_cliente int not null,
	id_escala int not null,
	id_clase int not null,
	numero_asiento int not null,

	Constraint fk_boletos_avion foreign key (id_avion) references Avion(id_avion),
	Constraint fk_boletos_cliente foreign key (id_cliente) references Cliente(id_cliente),
	Constraint fk_boletos_escala foreign key (id_escala) references Escala(id_escala),
	Constraint fk_boletos_clase foreign key (id_clase) references Clase(id_clase)
)

create table Plataforma(
	id_plataforma int primary key,
	nombre varchar(50) not null
)

create table Reservas(
	id_reserva int primary key identity(1, 1),
	num_registro int not null,
	id_vuelo int not null,
	estado varchar(50) not null,
	id_clase int not null,
	id_avion int not null,
	precio decimal,
	descuento decimal,
	plataforma int not null,

	Constraint fk_reserva_clase foreign key (id_clase) references Clase(id_clase),
	Constraint fk_reserva_avion foreign key (id_avion) references Avion(id_avion),
	Constraint fk_reserva_vuelo foreign key (id_vuelo) references Vuelo(id_vuelo),
	Constraint fk_reserva_plataforma foreign key (plataforma) references Plataforma(id_plataforma)
)

create table HistorialReservas(
	id_reserva int primary key identity(1, 1),
	id_vuelo int not null,
	estado varchar(50) not null,
	num_registro int not null,
	fecha_transaccion datetime default getdate()
)

