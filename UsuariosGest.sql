CREATE PROCEDURE [dbo].[UsuariosGest]
@Id int = null,
@Nombre varchar(100) = null,
@Edad int = null,
@Activo varchar(150) = null

AS
-- Gestión de registros entidad 'Usuarios'
  
Campos_Standard:

    SET NOCOUNT ON
    SET ANSI_WARNINGS OFF
    BEGIN TRAN

    DECLARE @IdEstado smallint,
            @DsEstado varchar(4000)

    SELECT @IdEstado = 0,
           @DsEstado = 'OK.'               

    -- Identificador
    IF @Id IS NULL BEGIN
        SELECT @IdEstado = -1,
               @DsEstado = 'Debe indicar identificador de registro.'
        GOTO Salir
    END

    -- Parámetros mínimos
    IF @Id >=0 AND (@Nombre IS NULL OR
					@Edad IS NULL OR
					@Activo IS NULL) BEGIN
        SELECT @IdEstado = -1,
               @DsEstado = 'Debe indicar parámetros requeridos.'
        GOTO Salir
    END

    -- Duplicidad de descriptor 
	IF EXISTS(SELECT 1
			  FROM Usuarios
			  WHERE Nombre = @Nombre AND
					Id <> @Id) BEGIN
		SELECT @IdEstado = -2,
				@DsEstado = 'Nombre de usuario ya registrado.'
		GOTO Salir
	END	

Procesar:            

    IF @Id = 0 BEGIN
        -- Inserción Datos fijos
        INSERT INTO Usuarios(FecCreacion) 
        VALUES		        (GETDATE())
        SELECT @Id = @@IDENTITY
    END
    
    IF @Id > 0 BEGIN
        -- Actualización Datos variables
		
        UPDATE  Usuarios
        SET     Nombre = @Nombre,
				Edad = @Edad,
				Activo = @Activo,
                FecActualizacion = GETDATE()
        WHERE  Id = @Id
        
        IF @@ROWCOUNT = 0 BEGIN
            SELECT @IdEstado = -3,
                   @DsEstado = 'No se encuentra registro para actualizar.' 
            GOTO Salir			
        END
						
    END

    IF @Id < 0 BEGIN

		-- Validar existencia de registros derivados
        --IF EXISTS(SELECT 1 FROM Ingresos WHERE IdUsuario = ABS(@Id)) BEGIN
        --    SELECT @IdEstado = -4,
        --            @DsEstado = 'Usuario con Ingresos asociados. Imposible eliminar.'
        --    GOTO Salir			
        --END
	
        DELETE
        FROM   Usuarios
        WHERE  Id = ABS(@Id)

        IF @@ROWCOUNT = 0 BEGIN
            SELECT @IdEstado = -3,
                   @DsEstado = 'No se encuentra registro para eliminar.' 
            GOTO Salir			

        END
    END

Salir:
    IF @IdEstado = 0 COMMIT TRAN
    IF @IdEstado < 0 ROLLBACK TRAN

    SELECT @IdEstado AS IdEstado,
           @DsEstado AS DsEstado,
           @Id AS Id
	
	RETURN 0
