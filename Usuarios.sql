CREATE TABLE [dbo].[Usuarios]
(
	Id INT NOT NULL PRIMARY KEY IDENTITY
,	Nombre varchar(100)
,	Edad int
,	Activo bit
,	FecCreacion date
,	FecActualizacion date
)
