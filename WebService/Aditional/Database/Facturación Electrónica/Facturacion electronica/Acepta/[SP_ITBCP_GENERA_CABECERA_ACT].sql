USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_GENERA_CABECERA_ACT]    Script Date: 21/06/2019 15:36:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****Procedimiento ACEPTA UBL2.1 06/05/2019********/

ALTER PROCEDURE [dbo].[SP_ITBCP_GENERA_CABECERA_ACT]
	
	@fe_TipDoc CHAR(2),       @fe_NumDoc VARCHAR(13),  @fe_FecDoc DATETIME,       @fe_TipMon VARCHAR(3), 
	@fe_EmpVen VARCHAR(15),   @fe_TipEmi CHAR(1),      @fe_NomEmi VARCHAR(100),   @fe_CodUbi VARCHAR(6), 
	@fe_DirEmi VARCHAR(100),  @fe_UrbEmi VARCHAR(100), @fe_PrvEmi VARCHAR(20),    @fe_DepEmi VARCHAR(20),
	@fe_DisEmi VARCHAR(30),   @fe_NroDoc VARCHAR(15),  @fe_TipAdq CHAR(1),        @fe_RucRec VARCHAR(15),
	@fe_RazRec VARCHAR(100),  @fe_DirRec VARCHAR(100), @fe_MtoImp NUMERIC(12,2),  @fe_DocRef VARCHAR(13),
	@fe_TipNot VARCHAR(2),    @fe_MotNot VARCHAR(50),  @fe_TipRef VARCHAR(50),    @fe_MtoTot NUMERIC(12,2),
	@fe_TipVen CHAR(1),       @fe_NumGuia VARCHAR(30), @fe_OrdCompra VARCHAR(10), @fe_MtoDsc NUMERIC(12,2),
	@fe_SubTot NUMERIC(12,2), @fe_fecRef datetime,     @fe_tpdRef CHAR(2),        @fe_FecVen DATETIME,
	@fe_Indeco numeric(12,2), @fe_Contig bit

AS


    DECLARE @fe_FacDesc NUMERIC(12,2),@Fe_IndCar varchar(5),@Fe_CodMot  varchar(2)

--El Descuento solo se va a enviar en el detalle, se permite uno Global o Detallado, no al mismo tiempo
  --set @fe_FacDesc = iif(@fe_MtoDsc <>0, (ABS(@fe_MtoDsc) / @fe_SubTot) * 100 , 0)	
  --set @Fe_IndCar  = iif(@fe_MtoDsc <>0, iif(@fe_MtoDsc>0,'false','true'),'') 
  --set @Fe_CodMot  = iif(@fe_MtoDsc <>0, iif(@fe_MtoDsc>0,'00','50'),'') 
  
  set @fe_FacDesc =  0	
  set @Fe_IndCar  = '' 
  set @Fe_CodMot  = '' 
 -- set @fe_MtoDsc  =  0

IF @fe_TipDoc = '01' OR @fe_TipDoc = '03'

BEGIN

/*----------- Facturas y Boletas --------------*/

		SELECT 1 AS ORDEN, -- NRO DE DOCUMENTO
				/*Tipo de documento*/
					@fe_TipDoc + '|' +
				/*Número único asignado al documento por el emisor (Serie + Número correlativo)*/
					(CASE WHEN @fe_Contig =  1 THEN '0' + LEFT(@fe_NumDoc,3) + '-0' + RIGHT(@fe_NumDoc,7) 
					      WHEN @fe_TipDoc = '03' THEN 'B' + LEFT(@fe_NumDoc,3) + '-0' + RIGHT(@fe_NumDoc,7) 
						  WHEN @fe_TipDoc = '01' THEN 'F' + LEFT(@fe_NumDoc,3) + '-0' + RIGHT(@fe_NumDoc,7) 
						  ELSE @fe_NumDoc END) + '|' +
				/*Fecha de emisión del documento*/
					CONVERT(CHAR(10),@fe_FecDoc,126) + '|' +
				/*Tipo de moneda en la cual se emite el documento (ISO 4217)*/
					@fe_TipMon +'|'+
				/*Tipo y número de la guía de remisión relacionada con la operación */	
					@fe_NumGuia +'|'+
                /*Código de tipo de guía de remisión relacionada con la operación que se factura*/
				(case when @fe_NumGuia = ''  then '' else '09' end)+'|'+
					'||'+
				/*	Orden de compra */
					@fe_OrdCompra+'|'+
				/*	Fecha de Vencimiento */
					CONVERT(CHAR(10),@fe_FecVen,126)+'||'+
				/*Código de tipo de operación*/	 
					 +'0101|'+ 
					 '|}'
				AS CABECERA 			  			
		UNION ALL

			
		SELECT 2 AS ORDEN, -- DATOS DEL EMISOR			
				/*Identificación de la empresa Proveedora*/
					@fe_EmpVen + '|' +
				/*Tipo de documento de identificación del emisor*/
					'6|' +
				/*Nombre Comercial del emisor*/
					@fe_NomEmi + '|' +
				/*Apellidos y nombres o denominación o razón social del emisor*/
					'|' +  --@fe_NomEmi + '|' +
				/*Código Ubigeo del Domicilio fiscal  del emisor*/
					@fe_CodUbi + '|' +
				/*Dirección completa y detallada del emisor*/
					@fe_DirEmi + '|' +
				/*Urbanizacion o Zona del emisor*/
					'|' +
				/*Provincia del emisor*/
					@fe_PrvEmi + '|' +
				/*Departamento del emisor*/
					@fe_DepEmi + '|' +
				/*Distrito del emisor*/
					@fe_DisEmi + '|' +
				/*Código del País del emisor*/
					'PE|' +
				/*Pagina web*/
				     '|' +
				/*Telefono*/
				     '|' +
				/*Email*/
				     '|' +
				/*Codigo SUNAT*/
				     '0000' + /*------------------------Obligatorio*/
					'}' 
				 AS CABECERA 

		UNION ALL

		SELECT 3 AS ORDEN, -- DATOS DEL RECEPTOR			
				/*Número de documento de identidad del receptor*/
					(CASE WHEN @fe_RucRec <> '' THEN @fe_RucRec WHEN LEN(@fe_NroDoc) = 8 AND @fe_RucRec = '' THEN @fe_NroDoc ELSE '99999999' END) + '|' +
				/*Tipo de documento de identificación del receptor*/
					(CASE WHEN @fe_RucRec <> '' THEN '6' WHEN LEN(@fe_NroDoc) = 8 AND @fe_RucRec = '' THEN '1' ELSE '1' END) + '|' +
				/*apellidos y nombres o denominación o razón social según RUC*/
					(CASE WHEN @fe_RazRec <> '' THEN @fe_RazRec ELSE 'CLIENTES VARIOS' END) + '|' +
					'||' +
				/*Dirección completa y detallada del emisor*/
					 @fe_DirRec + '||||||'+
				/*Codigo SUNAT*/
				     '0000' + /*------------------------Obligatorio*/
					 '}'
				 AS CABECERA
				 
		UNION ALL
		
		SELECT 4 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA
				 
		UNION ALL
		
		/*-Total Valor de Venta - Exportación / Exoneradas / Inafectas*/
		SELECT 5 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				   (case when @fe_MtoImp = 0 and @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_SubTot) else '' end) + '|' +	 
				 /*Importe total de un tributo para la factura.*/
				   (case when @fe_MtoImp = 0  and @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '' end) + '|' +
				 /*Categoría de impuestos*/
			      (case when @fe_MtoImp = 0  and @fe_TipVen <> 'T' then 'E' else '' end) + '|' +
				 /*Importe explícito a tributar.*/
				    (case when @fe_MtoImp = 0 and @fe_TipVen <> 'T' then '9997' else '' end) + '|' +
				/*Código del Tipo de Tributo (UN/ECE 5153)*/
				    (case when @fe_MtoImp = 0 and @fe_TipVen <> 'T' then 'EXO' else '' end)  + '|' +	
				 /*Nombre del Tributo (IGV, IVAP, ISC)*/
				    (case when @fe_MtoImp = 0 and @fe_TipVen <> 'T' then 'VAT' else '' end)  + '}' 
				 AS CABECERA
		UNION ALL

		/*-Total Valor de Venta - Gratuitas*/
		SELECT 6 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				   (case when @fe_TipVen = 'T' then  CONVERT(VARCHAR(14),@fe_MtoTot) else '' end) + '|' +	 
				 /*Importe total de un tributo para la factura.*/
				   (case when @fe_TipVen = 'T' then '0.00' else '' end) + '|' +
				 /*Categoría de impuestos*/
			     (case when @fe_TipVen = 'T' then 'Z' else '' end) + '|' +
				 /*Importe explícito a tributar.*/
				    (case when @fe_TipVen = 'T' then '9996' else '' end) + '|' +
				/*Código del Tipo de Tributo (UN/ECE 5153)*/
				    (case when @fe_TipVen = 'T' then 'GRA' else '' end)  + '|' +	
				 /*Nombre del Tributo (IGV, IVAP, ISC)*/
				    (case when @fe_TipVen = 'T' then 'FRE' else '' end)  + '}' 
				 AS CABECERA
		UNION ALL

		/*-Total Valor de Venta - Gravadas*/
		SELECT 7 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				   (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_SubTot) else '' end) + '|' +	 
				 /*Importe total de un tributo para la factura.*/
				   (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '' end) + '|' +
				 /*Categoría de impuestos*/
					(case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then 'S' else '' end) + '|' +
				 /*Importe explícito a tributar.*/
				    (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then '1000' else '' end) + '|' +
				/*Código del Tipo de Tributo (UN/ECE 5153)*/
				    (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then 'IGV' else '' end)  + '|' +	
				 /*Nombre del Tributo (IGV, IVAP, ISC)*/
				    (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then 'VAT' else '' end)  + '}' 
				 AS CABECERA
		UNION ALL

		/*-Sumatoria ISC / Sumatoria Otros Tributos*/
		SELECT 8 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				    '|' +	 
				 /*Importe total de un tributo para la factura.*/
				    '|' +
				 /*Categoría de impuestos*/
					'|' +
				 /*Importe explícito a tributar.*/
					'|' +
				/*Código del Tipo de Tributo (UN/ECE 5153)*/
					'|' +	
				 /*Nombre del Tributo (IGV, IVAP, ISC)*/
					'}' 
				 AS CABECERA
		UNION ALL

		SELECT 9 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA	
		UNION ALL

		/*-MONTOS TOTALES*/
		SELECT 10 AS ORDEN, -- 
				 /*Total valor de venta*/
				 (case when @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_SubTot) else CONVERT(VARCHAR(14),@fe_MtoTot) end)  + '|' +	 
				 --(case when @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_SubTot) else '0.00' end)  + '|' +	 
				 /*Total precio de venta (incluye impuestos)*/
				  CONVERT(VARCHAR(14),@fe_MtoTot)  + '|' +	 
				 --(case when @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_MtoTot) else '0.00' end)  + '|' +	 
   			     /* Monto total de descuentos globales del comprobante*/
			     (case when @fe_TipVen <> 'T' then (case when @fe_MtoDsc>0 then CONVERT(VARCHAR(14),@fe_MtoDsc) else '0.00' end) else '0.00' end) 	+ '|' +	 
   			     /* Monto total de otros cargos del comprobante*/
				   (case when @fe_TipVen <> 'T' then (case when @fe_MtoDsc<0 then CONVERT(VARCHAR(14),abs(@fe_MtoDsc)) else '0.00' end) else '0.00' end) + '|' +	 
   			     /* Monto total de anticipos del comprobante*/
				    '|' +	
				 /*Importe total de la venta, cesión en uso o del servicio prestado*/
				 (case when @fe_TipVen <> 'T' then   CONVERT(VARCHAR(14),@fe_MtoTot) else '0.00' end)  + '|' +					  
   			     /* Monto para Redondeo del Importe Total*/
				    CONVERT(VARCHAR(14),@fe_Indeco)  +'|' +	
				 /*Importe total de un tributo para la factura.*/
				  (case when @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '0.00' end)   +
                   '}' 
				 AS CABECERA
		UNION ALL		

		SELECT 11 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA	
		UNION ALL	

	
		SELECT 12 AS ORDEN, -- DESCUENTO GLOBAL - FISE (Ley 29852) -PERCEPCIÓN
				/*Indicador del cargo/descuento global*/
					'|' +
				 --@Fe_IndCar + '|' +
                /*Código del motivo del cargo/descuento global*/
				 '|' +
				  -- @Fe_CodMot + '|' +
                /*Factor del cargo/descuento global*/
				 '|' +
				  -- (CASE WHEN @fe_MtoDsc <> 0 THEN CONVERT(VARCHAR(14),@fe_FacDesc) ELSE '' END)+'|' +
				/*Indicador del cargo/descuento global*/
				 '|' +
				  --(CASE WHEN @fe_MtoDsc <> 0 THEN CONVERT(VARCHAR(14),ABS(@fe_MtoDsc)) ELSE '' END) + '|' +
				/*Importe total de la venta, cesión en uso o del servicio prestado*/
                  ''+
				  --(CASE WHEN @fe_MtoDsc <> 0 THEN CONVERT(VARCHAR(14),@fe_SubTot)  ELSE ''  END) + 
					'}' 
				  AS CABECERA
			 
		UNION ALL		  
		SELECT 13 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA	
		UNION ALL
		SELECT 14 AS ORDEN, -- DATOS DEL ANTICIPO
				/*Monto prepagado o anticipado (No incluye impuestos)*/
					'|' +
                /*Código de tipo de moneda del monto prepagado o anticipado*/
				    '|' +
                /*Serie y número de comprobante del anticipo*/
				    '|' +
				/*Código de tipo de documento*/
				    '|' +
				/*Identificador del pago*/
				    '|' +
				/*Fecha de pago*/
					 +'}' 
				  AS CABECERA
				 
		UNION ALL		 
						  
		SELECT 15 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA	
	ORDER BY ORDEN  
END

ELSE

BEGIN

/*----------- Notas de credito y debito --------------*/
		SELECT 1 AS ORDEN, -- NRO DE DOCUMENTO
				/*Tipo de documento*/
					@fe_TipDoc + '|' +
				/*Serie y número del comprobante*/
					LEFT(@fe_DocRef,1) + LEFT(@fe_NumDoc,3) + '-0' + RIGHT(@fe_NumDoc,7) + '|' +
				/*Fecha de emisión del documento*/
					CONVERT(CHAR(10),@fe_FecDoc,126) + '|' +
				/*Tipo de moneda en la cual se emite el documento (ISO 4217)*/
					@fe_TipMon +'|'+
				/*Tipo y número de la guía de remisión relacionada con la operación */	
					@fe_NumGuia +'|'+
                /*Código de tipo de guía de remisión relacionada con la operación que se factura*/
				(case when @fe_NumGuia = ''  then '' else '09' end)+'|'+
				/*Número de cualquier otro documento relacionado con la operación que se factura*/
				     @fe_DocRef+ '|'+
				/*Código de tipo de  cualquier otro documento relacionado con la operación que se factura*/
				    (case when @fe_TipDoc = '07' then @fe_tpdRef else '99' end) +'|'+
				 /*Número de la orden de compra*/
					  '|'+
				 /*Hora de emisión*/
					CASE WHEN FORMAT(@fe_FecDoc,'yyyyMMdd') = +  FORMAT(GETDATE(),'yyyyMMdd')  THEN FORMAT(GETDATE(),'hh:mm:ss') else '' end +'|'+

					/*Código de tipo de operación*/	 
					 '0101'+
					 '}'
				AS CABECERA 			  			
		UNION ALL
					
		SELECT 2 AS ORDEN, -- DATOS DEL EMISOR			
				/*Identificación de la empresa Proveedora*/
					@fe_EmpVen + '|' +
				/*Tipo de documento de identificación del emisor*/
					'6|' +
				/*Nombre Comercial del emisor*/
					@fe_NomEmi + '|' +
				/*Apellidos y nombres o denominación o razón social del emisor*/
					@fe_NomEmi + '|' +  --@fe_NomEmi + '|' +
				/*Código Ubigeo del Domicilio fiscal  del emisor*/
					@fe_CodUbi + '|' +
				/*Dirección completa y detallada del emisor*/
					@fe_DirEmi + '|' +
				/*Urbanizacion o Zona del emisor*/
					+'|' +
				/*Provincia del emisor*/
					@fe_PrvEmi + '|' +
				/*Departamento del emisor*/
					@fe_DepEmi + '|' +
				/*Distrito del emisor*/
					@fe_DisEmi + '|' +
				/*Código del País del emisor*/
					'PE|' +
				/*Pagina web*/
				     '|' +
				/*Telefono*/
				     '|' +
				/*Email*/
				     '|' +
				/*Codigo SUNAT*/
				     '0000' + /*------------------------Obligatorio*/
					'}' 
				 AS CABECERA 

		UNION ALL

		SELECT 3 AS ORDEN, -- DATOS DEL RECEPTOR			
				/*Número de documento de identidad del receptor*/
					(CASE WHEN @fe_RucRec <> '' THEN @fe_RucRec WHEN LEN(@fe_NroDoc) = 8 AND @fe_RucRec = '' THEN @fe_NroDoc ELSE '99999999' END) + '|' +
				/*Tipo de documento de identificación del receptor*/
					(CASE WHEN @fe_RucRec <> '' THEN '6' WHEN LEN(@fe_NroDoc) = 8 AND @fe_RucRec = '' THEN '1' ELSE '1' END) + '|' +
				/*apellidos y nombres o denominación o razón social según RUC*/
					(CASE WHEN @fe_RazRec <> '' THEN @fe_RazRec ELSE 'CLIENTES VARIOS' END) + '|' +
					'||' +
				/*Dirección completa y detallada del emisor*/
					 @fe_DirRec + '||||||'+
				/*Codigo SUNAT*/
				     '0000' + /*------------------------Obligatorio*/
					 '}'
				 AS CABECERA
				 
		UNION ALL
		
		SELECT 4 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA
				 
		UNION ALL

		SELECT 5 AS ORDEN, -- DATOS DE COMPROBANTE DE REFERENCIA			
				/*Código de tipo de nota de crédito*/
					(case when  @fe_TipDoc = '07' then '07' else '02' end) + '|' +
				/*Motivo o sustento*/
					@fe_MotNot + '|' +
				/*Serie y número del comprobante que modifica*/
					@fe_DocRef + '|' +
				/*Fecha de emisión del documento de referencia*/
					CONVERT(CHAR(10),@fe_fecRef,126)  + '|'+
				/*Código de tipo de comprobante que modifica */
				     @fe_tpdRef  + /*------------------------Obligatorio*/
					 '}'
				 AS CABECERA
		UNION ALL

		SELECT 6 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA
				 
		UNION ALL

	/*IMPUESTOS - TOTALES POR OPERACIÓN*/	
		/*-Total Valor de Venta - Exportación / Exoneradas / Inafectas*/
		SELECT 7 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				   (case when @fe_MtoImp = 0 then CONVERT(VARCHAR(14),@fe_SubTot) else '' end) + '|' +	 
				 /*Importe total de un tributo para la factura.*/
				   (case when @fe_MtoImp = 0  then CONVERT(VARCHAR(14),@fe_MtoImp) else '' end) + '|' +
				 /*Categoría de impuestos*/
			      (case when @fe_MtoImp = 0  then 'E' else '' end) + '|' +
				 /*Importe explícito a tributar.*/
				    (case when @fe_MtoImp = 0  then '9997' else '' end) + '|' +
				/*Código del Tipo de Tributo (UN/ECE 5153)*/
				    (case when @fe_MtoImp = 0  then 'EXO' else '' end)  + '|' +	
				 /*Nombre del Tributo (IGV, IVAP, ISC)*/
				    (case when @fe_MtoImp = 0  then 'VAT' else '' end)  + '}' 
				 AS CABECERA
		UNION ALL

		/*-Total Valor de Venta - Gratuitas*/
		SELECT 8 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				   (case when @fe_TipVen = 'T' then CONVERT(VARCHAR(14),@fe_SubTot) else '' end) + '|' +	 
				 /*Importe total de un tributo para la factura.*/
				   (case when @fe_TipVen = 'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '' end) + '|' +
				 /*Categoría de impuestos*/
			     (case when @fe_TipVen = 'T' then 'Z' else '' end) + '|' +
				 /*Importe explícito a tributar.*/
				    (case when @fe_TipVen = 'T' then '9996' else '' end) + '|' +
				/*Código del Tipo de Tributo (UN/ECE 5153)*/
				    (case when @fe_TipVen = 'T' then 'GRA' else '' end)  + '|' +	
				 /*Nombre del Tributo (IGV, IVAP, ISC)*/
				    (case when @fe_TipVen = 'T' then 'FRE' else '' end)  + '}' 
				 AS CABECERA
		UNION ALL

		/*-Total Valor de Venta - Gravadas*/
		SELECT 9 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				   (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_SubTot) else '' end) + '|' +	 
				 /*Importe total de un tributo para la factura.*/
				   (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '' end) + '|' +
				 /*Categoría de impuestos*/
					(case when @fe_MtoImp > 0 and @fe_TipVen <> 'T'  then 'S' else '' end) + '|' +
				 /*Código de tributo*/
				    (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then '1000' else '' end) + '|' +
				/*Nombre de tributo*/
				    (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then 'IGV' else '' end)  + '|' +	
				 /*Código internacional tributo*/
				    (case when @fe_MtoImp > 0 and @fe_TipVen <> 'T' then 'VAT' else '' end)  + '}' 
				 AS CABECERA
		UNION ALL

		/*-Sumatoria ISC / Sumatoria Otros Tributos*/
		SELECT 10 AS ORDEN, -- TOTALES(Sumarotia IGV)
				 /*Total valor de venta*/
				    '|' +	 
				 /*Importe total de un tributo para la factura.*/
				    '|' +
				 /*Categoría de impuestos*/
					'|' +
				 /*Importe explícito a tributar.*/
					'|' +
				/*Código del Tipo de Tributo (UN/ECE 5153)*/
					'|' +	
				 /*Nombre del Tributo (IGV, IVAP, ISC)*/
					'}' 
				 AS CABECERA
		UNION ALL

		SELECT 11 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA	
		UNION ALL

		/*-MONTOS TOTALES*/
		SELECT 12 AS ORDEN, -- 
				 /*Total valor de venta*/
				 (case when @fe_TipVen <> 'T' then  CONVERT(VARCHAR(14),@fe_SubTot) else  CONVERT(VARCHAR(14),@fe_MtoTot) end)  + '|' +	 
				 /*Total precio de venta (incluye impuestos)*/
				  CONVERT(VARCHAR(14),@fe_MtoTot)   + '|' +	 
   			     /* Monto total de otros cargos del comprobante*/
				   '0.00'+ '|' +	 
				 /*Importe total de la venta, cesión en uso o del servicio prestado*/
				 (case when @fe_TipVen <> 'T' then  CONVERT(VARCHAR(14),@fe_MtoTot)  else '0.00' end) + '|' +					  
   			     /* Monto para Redondeo del Importe Total*/
				    CONVERT(VARCHAR(14),@fe_Indeco)  +'|' +		
				 /*Sumatoria de impuestos*/
				   (case when @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '0.00' end)  +
                   '}' 
				 AS CABECERA
		UNION ALL		

		SELECT 13 AS ORDEN, '~' -- FIN DE TABLA
				 AS CABECERA	
	ORDER BY ORDEN  

END


