use db5099n_03

create rule range_rule_legajo
as
@rango >=1004070 and @rango < 10040700
go

drop rule range_rule_legajo

exec sp_bindrule 'range_rule_legajo','Integrantes.lu'

exec sp_unbindrule 'Integrantes.lu'

select * from sys.tables

select * from Integrantes

insert into Integrantes values(1004370, 'pepe', 'nasa')

delete Integrantes where lu = 1004370


select * from sys.database_permissions

-- Especialidad
create table Especialidad 
( 
	id smallint not null primary key, 
	nombre_especialidad varchar(50) not null
)
GO

-- Estudio
create table Estudio 
( 
	id smallint not null primary key, 
	nombre_estudio varchar(50) not null
)
GO

-- Tabla generada por la relación Especialidad - Estudio 
create table Especialidad_Estudio 
( 
	id_estudio smallint not null, 
	id_especialidad smallint not null,
	constraint fk_estudio_id foreign key (id_estudio) references Estudio(id),
	constraint fk_especialidad_id foreign key (id_especialidad) references Especialidad(id),
	constraint pk_estudio_especialidad primary key NONCLUSTERED (id_estudio, id_especialidad)
)
GO

-- Medico
create table Medico 
( 
	matricula smallint not null primary key, 
	nombre_medico varchar(50) not null,
	apellido_medico varchar(50) not null,
	sexo char, 
	check (sexo in ('m','f'))
)
GO

-- Tabla generada por la relación Medico - Especialidad 
create table Medico_Especialidad
(
	id_medico smallint not null,
	id_especialidad smallint not null,
	constraint fk_medico_matricula foreign key (id_medico) references Medico(matricula),
	constraint fk_especialidad_id foreign key (id_especialidad) references Especialidad(id),
	constraint pk_medico_especialidad primary key NONCLUSTERED (id_medico, id_especialidad)
)
GO

-- Instituto
create table Instituto
(
	id smallint not null primary key,
	nombre_instituto varchar(50) not null,
	direccion varchar(50) not null,
	estado char, check (estado in ('si', 'no'))
)
GO

-- Tabla generada por la relación Instituto - Estudio
create table Instituto_Estudio
(
	id_instituto smallint not null,
	id_estudio smallint not null,
	precio decimal(10,2) not null,
	check (precio <= 5000),
	constraint fk_instituto_id foreign key (id_instituto) references Instituto(id),
	constraint fk_estudio_id foreign key (id_estudio) references Estudio(id),
	constraint pk_instituto_estudio primary key NONCLUSTERED (id_instituto, id_estudio)
)
GO

-- Paciente
create table Paciente 
(
	dni varchar(8) not null primary key,
	nombre varchar(50) not null,
	apellido varchar(50) not null,
	sexo char, 
	fecha_nacimiento date,
	check ((datediff(yyyy, fecha_nacimiento, GETDATE()) > 21) && (datediff(yyyy, fecha_nacimiento, GETDATE()) < 80)),
	check (sexo in ('m','f')),
	check (dni like '%[^0-9]%'),
)
GO

-- Obra Social
create table ObraSocial 
(
	id smallint not null primary key,
	nombre varchar(50) not null,
	categoria char,
	check (categoria in ('os', 'pp'))
)
GO

-- Plan
/* [IMPORTANTE] El numero del plan no tiene que ser menor o igual a 12? */
create table Plan 
(
	id smallint not null primary key,
	id_obra_social smallint not null,
	estado char, check (estado in ('si', 'no')),
	constraint fk_obrasocial_id foreign key (id_obra_social) references ObraSocial(id)
)
GO

-- Tabla generada por la relación Paciente - Plan
create table Paciente_Plan 
(
	dni_paciente varchar(8) not null,
	id_plan smallint not null,
	constraint fk_paciente_dni foreign key (dni_paciente) references Paciente(dni),
	constraint fk_plan_id foreign key (id_plan) references Plan(id),
	constraint pk_paciente_plan primary key NONCLUSTERED (dni_paciente, id_plan)
)
GO

-- Tabla generada por la relación Plan - Estudio
create table Plan_Estudio 
(
	id_plan smallint not null,
	id_estudio smallint not null,
	cobertura decimal(3,0) not null,
	constraint fk_plan_dni foreign key (id_plan) references Plan(id),
	constraint fk_estudio_id foreign key (id_estudio) references Estudio(id),
	constraint pk_plan_estudio primary key NONCLUSTERED (id_plan, id_estudio)
)
GO

-- Registro
create table Registro 
(
	id smallint not null primary key,
	id_estudio smallint not null,
	id_instituto smallint not null,
	matricula_medico smallint not null,
	dni_paciente varchar(8) not null,
	fecha_estudio date,
	check ((datediff(mm, fecha_estudio, GETDATE()) > 30) && datename(dd, 1, GETDATE())),
	constraint fk_estudio_id foreign key (id_estudio) references Estudio(id),
	constraint fk_instituto_id foreign key (id_instituto) references Instituto(id),
	constraint fk_medico_matricula foreign key (matricula_medico) references Medico(matricula),
)
GO


-- VIEWS
CREATE VIEW vw_especialidad
AS
SELECT e.id, e.nombre_especialidad FROM Especialidad e
GO

CREATE VIEW vw_estudio
AS
SELECT e.id, e.nombre_estudio FROM Estudio e
GO

CREATE VIEW vw_especialidad_estudio
AS
SELECT est.nombre_estudio, esp.nombre_especialidad FROM Especialidad_Estudio ee 
inner join Estudio est on ee.id_estudio = est.id 
inner join Especialidad esp on ee.id_especialidad = esp.id
GO

CREATE VIEW vw_medico
AS
SELECT m.matricula, m.nombre_medico, m.apellido_medico, m.sexo FROM Medico m
GO

CREATE VIEW vw_medico_especialidad
AS
SELECT est.nombre_estudio, m.nombre_medico, m.apellido_medico, m.sexo FROM Medico_Especialidad me 
inner join Medico m on me.id_medico = m.matricula
inner join Especialidad esp on me.id_especialidad = esp.id
GO

CREATE VIEW vw_instituto
AS
SELECT i.id, i.nombre_instituto, i.direccion, i.estado FROM Instituto i
GO
	
CREATE VIEW vw_instituto_estudio
AS
SELECT i.nombre_instituto, i.direccion, i.estado, e.nombre_estudio FROM Instituto_Estudio ie 
inner join Instituto i on ie.id_instituto = i.id
inner join Estudio e on ie.id_estudio = e.id
GO

CREATE VIEW vw_obrasocial
AS
SELECT id, nombre, categoria FROM ObraSocial
GO

CREATE VIEW vw_paciente
AS
SELECT p.dni, p.nombre, p.apellido, p.sexo, p.fecha_nacimiento FROM Paciente p
GO

CREATE VIEW vw_plan
AS
SELECT p.id, os.nombre, os.categoria, p.estado FROM Plan p
inner join ObraSocial os on p.id_obra_social = os.id
GO

CREATE VIEW vw_paciente_plan
AS
SELECT p.dni, p.nombre, p.apellido, p.sexo, p.fecha_nacimiento, pl.id, pl.id_obra_social, pl.estado FROM Paciente_Plan pp
inner join Paciente p on pp.dni_paciente = p.dni
inner join Plan pl on pp.id_plan = pl.id
GO

CREATE VIEW vw_plan_estudio
AS
SELECT pl.id, pl.id_obra_social, pl.estado, e.id, e.nombre_estudio, pe.cobertura FROM Plan_Estudio pe
inner join Plan p on pe.id_plan = p.id
inner join Estudio e on pe.id_estudio = e.id
GO

CREATE VIEW vw_registro
AS
SELECT r.id, r.fecha_estudio, 
e.nombre_estudio, 
i.nombre_instituto, i.direccion, i.estado, 
m.nombre_medico, m.apellido_medico, m.sexo,
p.nombre, p.apellido, p.sexo, p.fecha_nacimiento
FROM Registro r
inner join Estudio e on r.id_estudio = e.id
inner join Instituto i on r.id_instituto = i.id
inner join Medico m on r.matricula_medico = m.matricula
inner join Paciente p on r.dni_paciente = p.dni
GO

	
