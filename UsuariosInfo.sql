CREATE PROCEDURE [dbo].[UsuariosInfo]
	@Id int = null,
	@Nombre varchar(100) = null,
	@EdadDesde int = null,
	@EdadHasta int = null,
	@Activo bit = null,
	@FecCreacionDesde date = null,
	@FecCreacionHasta date = null,
	@Ordenar varchar(100) = null
AS	

    -- Seleccion de registros    

    SET NOCOUNT ON
    SET ANSI_WARNINGS OFF

    DECLARE @IdEstado smallint,
            @DsEstado varchar(4000)

    SELECT @IdEstado = 0,
           @DsEstado = 'OK.'

	DECLARE @Campos varchar(4000), @Dominio varchar(500), @Condicion varchar(4000)

	SET @Campos = '	Id,	Nombre, Edad, Activo, FecCreacion, FecActualizacion '
	SET @Dominio = 'Usuarios '
	SET @Condicion = '1=1 '

	IF @Id IS NOT NULL 
		SET @Condicion = @Condicion + 'AND Id=' + CAST(@Id as varchar) + ' '

	IF @Nombre IS NOT NULL 
		SET @Condicion = @Condicion + 'AND Nombre LIKE ''%' + @Nombre + '%'' '		

	IF @EdadDesde IS NOT NULL
		SET @Condicion = @Condicion + 'AND Edad >= ' + CAST(@EdadDesde as varchar) + ' '

	IF @EdadHasta IS NOT NULL
		SET @Condicion = @Condicion + 'AND Edad <= ' + CAST(@EdadHasta as varchar) + ' '

	IF @FecCreacionDesde IS NOT NULL 
        SET @Condicion = @Condicion + 'AND FecCreacion >= ''' + CAST(@FecCreacionDesde as varchar) + ''' '
        
    IF @FecCreacionHasta IS NOT NULL 
        SET @Condicion = @Condicion + 'AND FecCreacion <= ''' + CAST(@FecCreacionHasta as varchar) + ''' '

	IF @Activo IS NOT NULL 
		SET @Condicion = @Condicion + 'AND Activo=' + CAST(@Activo as varchar) + ' '
		 					
    IF @Ordenar IS NULL SET @Ordenar = 'Nombre '

Salir_OK:
    -- Componer frase SQL Base
    DECLARE @SQL1 As nvarchar(4000), @SQL2 As nvarchar(4000), @SQL3 As nvarchar(4000)
    SET @SQL1 = 'SELECT 1 FROM ' + @Dominio + 'WHERE ' + @Condicion
	SET @SQL2 = 'SELECT ' + CAST(@IdEstado as varchar(12)) + ' AS IdEstado, ''' + @DsEstado + ''' AS DsEstado, ' +
				@Campos + 'FROM ' + @Dominio + 'WHERE ' + @Condicion + 'ORDER BY ' +  @Ordenar	
	
    -- Componer frase SQL final
    SET @SQL3 = 'IF EXISTS(' + @SQL1 + ') ' + @SQL2 + 
                ' ELSE SELECT 1 AS IdEstado, ''Sin registros coincidentes'' AS DsEstado, ''La consulta no devolvió registros'' AS Estado ' +
				' , NULL AS ' + REPLACE(@Campos, ',', ', NULL AS ')
	--PRINT @SQL3
	BEGIN TRY
		EXECUTE sp_executesql @SQL3
	END TRY
	BEGIN CATCH
		SET @IdEstado = -10
		SET @DsEstado = '[sp_executesql]: ' + @SQL3 + ' - ERROR: ' + ERROR_MESSAGE()
		GOTO Salir_Err
	END CATCH

    RETURN 0

Salir_Err:
    SELECT @IdEstado AS IdEstado,
           @DsEstado AS EstadoTec,
		   NULL AS Id

	RETURN 0


RETURN 0
