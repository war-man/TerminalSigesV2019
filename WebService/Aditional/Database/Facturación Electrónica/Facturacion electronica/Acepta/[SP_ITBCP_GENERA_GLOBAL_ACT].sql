USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_GENERA_GLOBAL_ACT]    Script Date: 21/06/2019 15:37:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****Procedimiento ACEPTA UBL2.1 06/05/2019********/

ALTER PROCEDURE [dbo].[SP_ITBCP_GENERA_GLOBAL_ACT]  
	
	@fe_MtoNet NUMERIC(12,2), @fe_MtoDsc NUMERIC(12,2), @fe_TipVen CHAR(1), @fe_TotTxt VARCHAR(100),
	@fe_CorRec VARCHAR(50), @fe_TipDoc CHAR(2), @fe_FecVen DATETIME, @fe_CodUsu VARCHAR(60),
	@fe_LadVen VARCHAR(2), @fe_TurVen VARCHAR(2), @fe_NroPla VARCHAR(250), @fe_ConPag VARCHAR(20),
	@fe_NumOdo VARCHAR(20), @fe_NomTar VARCHAR(50), @fe_NroLic VARCHAR(120), @fe_ObsVen VARCHAR(250),
	@fe_DirSuc VARCHAR(120), @fe_scop VARCHAR(50),@fe_NomSuc varchar(50),@fe_ProSuc varchar(60),
	@fe_NroAut varchar(60), @fe_MtoImp NUMERIC(12,2)
	
AS

--DECLARE @fe_MtoImp NUMERIC(6,2),@fe_TxtLey varchar(120),@fe_CodLey varchar(5)
DECLARE @fe_TxtLey varchar(120),@fe_CodLey varchar(5)

--SET @fe_MtoImp = (SELECT TOP 1 IMPUESTO FROM parametro)

--set @fe_TxtLey = (case when @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' else
--             (case when @fe_MtoImp = 0 THEN 'BIENES TRANSFERIDOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA' ELSE 'Son: '+@fe_TotTxt END ) end)

set @fe_TxtLey = 'Son: '+@fe_TotTxt


set @fe_CodLey = (case when @fe_TipVen = 'T' THEN '1002' else
                 (case when @fe_MtoImp = 0 THEN '2001' ELSE '1000' END ) end)

IF @fe_TipDoc = '01' OR @fe_TipDoc = '03'

BEGIN



IF @fe_TipDoc = '01'
BEGIN

		SELECT 0 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
        UNION ALL 

		/*-DETRACCIÓN */
		SELECT 1 AS ORDEN, 
		         '||||||'+
			   	  '}' 
				 AS GLOBALES
		UNION ALL
		
		SELECT 2 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL

		/*-FACTURA GUÍA */
		SELECT 3 AS ORDEN, 
		         '|||||||||||||||||||||||||'+
			   	  '}' 
				 AS GLOBALES
		UNION ALL
		
		SELECT 4 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL

		/*-FACTURA GUÍA - CONDUCTORES */
		SELECT 5 AS ORDEN, 
		         '|'+
			   	  '}' 
				 AS GLOBALES
		UNION ALL
		
		SELECT 6 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL

		/*-FACTURA GUÍA - VEHÍCULOS */
		SELECT 7 AS ORDEN, 
			   	  @fe_NroPla+'}' 
				 AS GLOBALES
		UNION ALL

		SELECT 8 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL

		/*-LEYENDAS */

		SELECT 9 AS ORDEN, 
		@fe_TxtLey +
		--(CASE WHEN @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' ELSE @fe_TotTxt END) +
		          '|'+
        @fe_CodLey +
	   -- (CASE WHEN @fe_TipVen = 'T' THEN '1002' ELSE '1000' END)  +       
			   	   '}' 
				 AS GLOBALES
		UNION ALL
		
		SELECT 10 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL

		/*-ADJUNTOS */
/**************************************************************************/
		SELECT 11 AS ORDEN,	
	     	/*Nombre de la sucursal*/
		      -- @fe_NomSuc + '|' +
   		       ltrim(rtrim(@fe_NomSuc))+ ' - '+ @fe_DirSuc + '|' +
			/*Dirección de sucursal*/
				--@fe_DirSuc + '|||' +
				 '||' +
			/*Fecha de Vencimiento*/
				--CONVERT(CHAR(10),@fe_FecVen,126) + '|' +
				CONVERT(CHAR(10),@fe_FecVen,103) + '|' +
			/*Campos vacios*/
				'|||||||||||||||||||||' +
			/*Codigo Scop */
				 @fe_scop  + '|' + 	
			/*Usuario*/
				@fe_CodUsu + '|' + 
			/*Lado*/
				@fe_LadVen + '|' + 
			/*Turno*/
				@fe_TurVen + '|' + 
			/*Placa*/
				(CASE WHEN LEN(@fe_NroPla) BETWEEN 192 AND 250 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64) + ' ' + SUBSTRING(@fe_NroPla, 129, 64)  + ' ' + SUBSTRING(@fe_NroPla, 193, 57) 
			          WHEN LEN(@fe_NroPla) BETWEEN 128 AND 192 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64) + ' ' + SUBSTRING(@fe_NroPla, 129, 64)
			          WHEN LEN(@fe_NroPla) BETWEEN 064 AND 128 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64)
			          ELSE @fe_NroPla END) + '|' + 
			/*Condición de Pago*/
				@fe_ConPag + '|' + 
			/*Odometro*/
				@fe_NumOdo + '|' + 
			/*Tarjeta de crédito*/
				@fe_NomTar + '|' + 
			/*Licitación*/
				@fe_NroLic + '|' + 
			/*Leyenda Amazonía*/
			     '|' + 
				--(CASE WHEN @fe_MtoImp = 0 THEN 'BIENES TRANSFERIDOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA' ELSE '' END) +
			/*Sucursal-Ubicación*/
                @fe_ProSuc +'|' +
			/*Sucursal-Nombre*/
			   --  @fe_NomSuc + 
			     +'|' +
				 /*NroAutorizacionSUNAT*/
				 @fe_NroAut +
				 '}'
				AS GLOBALES
		
		UNION ALL
		
		SELECT 12 AS ORDEN, 
				ltrim(rtrim(@fe_ObsVen))+
				(case when @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' else
             (case when @fe_MtoImp = 0 THEN 'BIENES TRANSFERIDOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA' ELSE '' END ) end)
				 + '|' +
			/*Glosa de la leyenda*/
			    '|' +
			--	(CASE WHEN @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' ELSE @fe_TotTxt END) + '|' +
			/*Correo Receptor*/
				@fe_CorRec +  '||}'
			AS GLOBALES
		UNION ALL

		SELECT 13 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
		ORDER BY ORDEN  

END
ELSE
BEGIN

		SELECT 0 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
        UNION ALL 
		/*-LEYENDAS */

		SELECT 1 AS ORDEN, 
		@fe_TxtLey +
		--(CASE WHEN @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' ELSE @fe_TotTxt END) +
		          '|'+
        @fe_CodLey +
        --(CASE WHEN @fe_TipVen = 'T' THEN '1002' ELSE '1000' END)  +       
			   	   '}' 
				 AS GLOBALES
		UNION ALL
		
		SELECT 2 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL


/********************************************/
		SELECT 3 AS ORDEN,	
			/*Nombre de la sucursal*/
		       ltrim(rtrim(@fe_NomSuc))+ ' - '+ @fe_DirSuc + '|' +
			/*Dirección de sucursal*/
				--@fe_DirSuc + '|||' +
				 '||' +
			/*Fecha de Vencimiento*/
				--CONVERT(CHAR(10),@fe_FecVen,126) + '|' +
				CONVERT(CHAR(10),@fe_FecVen,103) + '|' +
			/*Campos vacios*/
				'|||||||||||||||||||||' +
			/*Codigo Scop */
				@fe_scop + '|' + 	
			/*Usuario*/
				@fe_CodUsu + '|' + 
			/*Lado*/
				@fe_LadVen + '|' + 
			/*Turno*/
				@fe_TurVen + '|' + 
			/*Placa*/
				(CASE WHEN LEN(@fe_NroPla) BETWEEN 192 AND 250 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64) + ' ' + SUBSTRING(@fe_NroPla, 129, 64)  + ' ' + SUBSTRING(@fe_NroPla, 193, 57) 
			          WHEN LEN(@fe_NroPla) BETWEEN 128 AND 192 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64) + ' ' + SUBSTRING(@fe_NroPla, 129, 64)
			          WHEN LEN(@fe_NroPla) BETWEEN 064 AND 128 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64)
			          ELSE @fe_NroPla END) + '|' + 
			/*Condición de Pago*/
				@fe_ConPag + '|' + 
			/*Odometro*/
				@fe_NumOdo + '|' + 
			/*Tarjeta de crédito*/
				@fe_NomTar + '|' + 
			/*Licitación*/
				@fe_NroLic + '|' + 
			/*Leyenda Amazonía*/
			     '|' +
				--(CASE WHEN @fe_MtoImp = 0 THEN 'BIENES TRANSFERIDOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA' ELSE '' END) +
			/*Sucursal-Ubicación*/
                @fe_ProSuc +'|' +
			/*Sucursal-Nombre*/
			   --  @fe_NomSuc + 
			     +'|' +
		   /*NroAutorizacionSUNAT*/
				 @fe_NroAut +
				 '}'
				AS GLOBALES
		
		UNION ALL
		
		SELECT 4 AS ORDEN, 
				ltrim(rtrim(@fe_ObsVen)) +
				(case when @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' else
             (case when @fe_MtoImp = 0 THEN 'BIENES TRANSFERIDOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA' ELSE '' END ) end)
				+ '|' +
			/*Glosa de la leyenda*/
			+ '|' +
			--	(CASE WHEN @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' ELSE @fe_TotTxt END) + '|' +
			/*Correo Receptor*/
				@fe_CorRec +  '||}'
			AS GLOBALES
		UNION ALL

		SELECT 5 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
		ORDER BY ORDEN  
END

END		
		
ELSE
		
	BEGIN 
	
			/*-DETRACCIÓN */
		SELECT 1 AS ORDEN, 
		         '||||||'+
			   	  '}' 
				 AS GLOBALES
		UNION ALL

		SELECT 2 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL

		
		/*-LEYENDAS */


		SELECT 3 AS ORDEN, 
		@fe_TxtLey +
		--(CASE WHEN @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' ELSE @fe_TotTxt END) +
		          '|'+
        @fe_CodLey +
		--(CASE WHEN @fe_TipVen = 'T' THEN '1002' ELSE '1000' END)  +       
			   	   '}' 
			 AS GLOBALES
		UNION ALL
		
		SELECT 4 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
         UNION ALL

		/*-ADJUNTOS */

		SELECT 5 AS ORDEN,	
			/*Nombre de la sucursal*/
		      -- @fe_NomSuc + '|' +
			  ltrim(rtrim(@fe_NomSuc))+ ' - '+ @fe_DirSuc + '|' +
			/*Dirección de sucursal*/
			--	'|'+@fe_DirSuc +'||' +
				'||' +
			/*Fecha de Vencimiento*/
				CONVERT(CHAR(10),@fe_FecVen,103) + '|' +
			/*Campos vacios*/
				'|||' +
			/*Codigo Scop */
				@fe_scop + '|' + 	
			/*Usuario*/
				@fe_CodUsu + '|' + 
			/*Lado*/
				@fe_LadVen + '|' + 
			/*Turno*/
				@fe_TurVen + '|' + 
			/*Placa*/
				(CASE WHEN LEN(@fe_NroPla) BETWEEN 192 AND 250 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64) + ' ' + SUBSTRING(@fe_NroPla, 129, 64)  + ' ' + SUBSTRING(@fe_NroPla, 193, 57) 
			          WHEN LEN(@fe_NroPla) BETWEEN 128 AND 192 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64) + ' ' + SUBSTRING(@fe_NroPla, 129, 64)
			          WHEN LEN(@fe_NroPla) BETWEEN 064 AND 128 THEN SUBSTRING(@fe_NroPla, 1, 64) + ' ' + SUBSTRING(@fe_NroPla, 65, 64)
			          ELSE @fe_NroPla END) + '|' + 
			/*Condición de Pago*/
				@fe_ConPag + '|' + 
			/*Odometro*/
				@fe_NumOdo + '|' + 
			/*Tarjeta de crédito*/
				@fe_NomTar + '|' + 
			/*Licitación*/
				@fe_NroLic + '|' + 
			/*Leyenda Amazonía*/
			    '|' + 
				--(CASE WHEN @fe_MtoImp = 0 THEN 'BIENES TRANSFERIDOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA' ELSE '' END) +
			/*Sucursal-Ubicación*/
                @fe_ProSuc +'|' +
			/*Sucursal-Nombre*/
			   --  @fe_NomSuc + 
			      +'|' +
			 /*NroAutorizacionSUNAT*/
				 @fe_NroAut +				 
		     	 '}'
				AS GLOBALES
		
		UNION ALL
		
		SELECT 6 AS ORDEN, 
				ltrim(rtrim(@fe_ObsVen)) +
				(case when @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' else
             (case when @fe_MtoImp = 0 THEN 'BIENES TRANSFERIDOS EN LA AMAZONÍA REGIÓN SELVA PARA SER CONSUMIDOS EN LA MISMA' ELSE '' END ) end)
				+ '|' +
			/*Glosa de la leyenda*/
			  +'|' +
			--	(CASE WHEN @fe_TipVen = 'T' THEN 'TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE' ELSE @fe_TotTxt END) + '|' +
			/*Correo Receptor*/
				@fe_CorRec +  '||}'
			AS GLOBALES
		UNION ALL
/*******************************************/

		SELECT 7 AS ORDEN, '~' -- FIN DE TABLA
				 AS GLOBALES
		UNION ALL

    	SELECT 8 AS ORDEN, '\'
	    	AS GLOBALES	
	    ORDER BY ORDEN  	
END
