USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_GENERA_DETALLE_ACT]    Script Date: 21/06/2019 15:36:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****Procedimiento ACEPTA UBL2.1 06/05/2019********/

ALTER PROCEDURE [dbo].[SP_ITBCP_GENERA_DETALLE_ACT]

	@fe_DesIte VARCHAR(60), @fe_CodPro VARCHAR(20), @fe_LinDet INT, @fe_UniMed VARCHAR(3), 
	@fe_CanVen NUMERIC(12,3), @fe_MonIte NUMERIC(12,2), @fe_ValUni NUMERIC(12,5), @fe_ImpIte NUMERIC(12,2),
	@fe_TipVen CHAR(1), @fe_DesRec NUMERIC(12,2), @fe_TipDoc CHAR(2),@Fe_cmdMon char(5),@fe_MonDes NUMERIC(12,2),
	@fe_MonTot NUMERIC(12,2),@fe_ArtSunat varchar(20)

AS

DECLARE @fe_PorIgv NUMERIC(6,2), @fe_MtoImp NUMERIC(6,2),@fe_PreSigv NUMERIC(12,5),@fe_FacDesc NUMERIC(12,2),
        @Fe_TipAfec varchar(2),@Fe_CatImp varchar(1),@Fe_CodTri varchar(4),@Fe_NomTri varchar(3),@Fe_CodInt  VARCHAR(3),
		@Fe_IndCar varchar(5), @Fe_CodMot varchar(2),@fe_DesSigv NUMERIC(12,5)

SET @fe_MtoImp = CASE WHEN @fe_ImpIte>0 THEN (SELECT TOP 1 impuesto FROM parametro) ELSE 0 END
SET @fe_PorIgv = (CONVERT(NUMERIC(6,2),ISNULL((@fe_MtoImp),0))/100+1)
set @fe_PreSigv = @fe_ValUni / @fe_PorIgv
set @fe_DesSigv = abs(@fe_MonDes) / @fe_PorIgv
--set @fe_FacDesc = @fe_MonIte / iif(ABS(@fe_MonDes)=0,1,ABS(@fe_MonDes))	
set @fe_FacDesc = case when @fe_MonDes<>0 then (ABS(@fe_MonDes) / @fe_MonIte) * 100 else 0 end
set @Fe_TipAfec = case when @fe_TipVen = 'T' then '21'else (case when @fe_ImpIte <>0 then '10' else '20' end) end
Set @Fe_CatImp  = case when @fe_MtoImp = 0 and @fe_TipVen <>'T' then 'E' else (case when @fe_TipVen = 'T' then 'Z' else 'S' end) end
Set @Fe_CodTri  = case when @fe_MtoImp = 0 and @fe_TipVen <>'T' then '9997' else (case when @fe_TipVen = 'T' then '9996' else '1000' end) end
Set @Fe_NomTri  = case when @fe_MtoImp = 0 and @fe_TipVen <>'T' then 'EXO' else (case when  @fe_TipVen = 'T' then 'GRA' else 'IGV' end) end
Set @Fe_CodInt  = case when @fe_TipVen = 'T' then 'FRE' else 'VAT' end
set @Fe_IndCar  = case when @fe_MonDes <>0 then (case when @fe_MonDes>0 then 'false' else 'true' end) else '' end 
set @Fe_CodMot  = case when @fe_MonDes <>0 then ( case when @fe_MonDes>0 then '00' else '50' end) else '' end 




IF @fe_TipDoc = '01' OR @fe_TipDoc = '03'
/*----------- Facturas y boletas -----------*/
BEGIN

	SELECT 1 AS ORDEN,
		   /*Número de línea*/
				CONVERT(VARCHAR(14),@fe_LinDet)  + '|' +
		   /*Cantidad de item.*/
				CONVERT(VARCHAR(14),@fe_CanVen) + '|' +
		   /*Unidad de medida por ítem.*/
				@fe_UniMed + '|' +
		   /*Valor de venta por ítem.*/
             (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else CONVERT(VARCHAR(14),@fe_MonTot) end)+ '|' +
             --(case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else '0.00' end)+ '|' +

		   /*Monto de IGV de la línea.*/
             (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_DesRec) else '0.00' end)  + '|' +
		   /*Precio de venta unitario por item y código.*/
		    (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else CONVERT(VARCHAR(14),@fe_MonTot) end) + '|' +
		    -- (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else '0.00' end) + '|' +

			/*Código de tipo de moneda */
			   '01|' +
			--(case when @fe_ImpIte <>0 then '01' else '02' end) +'|' +
			--   Rtrim(@Fe_cmdMon) + '|' +
		   /*Indicador del cargo/descuento del ítem*/
		      @Fe_IndCar + '|' +
		   /*Código del motivo del cargo/descuento del ítem*/
		      @Fe_CodMot + '|' +
	        /*Factor del cargo/descuento global*/
			  --(CASE WHEN @fe_MonDes <> 0 THEN  CONVERT(VARCHAR(14),@fe_FacDesc) ELSE '' END) +'|' +
			  (CASE WHEN @fe_MonDes > 0 THEN  CONVERT(VARCHAR(14),@fe_FacDesc) ELSE '0.00' END) +'|' +
			/*Indicador del cargo/descuento global*/
			 -- (CASE WHEN @fe_MonDes <> 0 THEN CONVERT(VARCHAR(14),ABS(@fe_MonDes)) ELSE '' END) + '|' +
			 --(CASE WHEN @fe_MonDes <> 0 THEN CONVERT(VARCHAR(14),convert(decimal(12,2),@fe_DesSigv)) ELSE '' END) + '|' +
			 (CASE WHEN @fe_MonDes > 0 THEN CONVERT(VARCHAR(14),convert(decimal(12,2),@fe_DesSigv)) ELSE '0.00' END) + '|' +
			/*Importe total de la venta, cesión en uso o del servicio prestado*/
			  (CASE WHEN @fe_MonDes <> 0 THEN CONVERT(VARCHAR(14),@fe_MonIte)  ELSE ''  END) + '|' +	   
 		   /*Monto de la operación | Afectación al IGV por ítem*/
              (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else '0.00' end)  + '|' +
		   /*Monto IGV por ítem*/
              (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_ImpIte) else '0.00' end)  + '|' +
            /*Categoría de impuestos*/
			   @Fe_CatImp+'|'+
		   /*Porcentaje del impuesto*/
            (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '0.00' end)  + '|' +
            /*Código de tipo de afectación del IGV*/
			   @Fe_TipAfec+'|'+
            /*Código de tributo*/
			   @Fe_CodTri+'|'+
            /*Nombre de tributo*/
			   @Fe_NomTri +'|'+
            /*Código internacional tributo*/
			   @Fe_CodInt+'|'+
			   '|||||||||||||||' +
		   /*Descripción detallada del servicio prestado.*/
		        @fe_DesIte+'|' +
           /*Información adicional*/
		        '|' +
		   /*Código del producto.*/
				@fe_CodPro + '|' +
           /*Código de producto (SUNAT) */
		        @fe_ArtSunat+ '|' +
           /*Código de producto GS1 */
		         '|' +
		   /*Valor unitario por ítem sin IGV*/
              (case when @fe_TipVen <>'T' then  CONVERT(VARCHAR(14),@fe_PreSigv) else CONVERT(VARCHAR(14),@fe_ValUni) end)  + '|' 
        as DETALLE
	  UNION ALL

		/*-CONCEPTO TRIBUTARIO */
		SELECT 2 AS ORDEN, 
		         '|||||'+
					'}' 
				 AS DETALLE
		ORDER BY ORDEN 

END

ELSE

BEGIN

/*----------- Notas de credito y debito -----------*/
	SELECT 1 AS ORDEN,
		   /*Número de línea*/
				CONVERT(VARCHAR(14),@fe_LinDet)  + '|' +
		   /*Cantidad de item.*/
				CONVERT(VARCHAR(14),@fe_CanVen) + '|' +
		   /*Unidad de medida por ítem.*/
		     	@fe_UniMed + '|' +
		   /*Valor de venta por ítem.*/
		      (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else CONVERT(VARCHAR(14),@fe_MonTot) end)+ '|' +
		      --(case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else '0.00' end)+ '|' +

		   /*Monto de IGV de la línea.*/
             (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_ImpIte) else '0.00' end)  + '|' +
		   /*Precio de venta unitario por item y código.*/
		     (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else CONVERT(VARCHAR(14),@fe_MonTot) end) + '|' +
		     --(case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else '0.00' end) + '|' +
		       --CONVERT(VARCHAR(14),@fe_ValUni) + '|' +
			/*Código de tipo de moneda */
			    '01|' +
			   ---(case when @fe_ImpIte<>0 then '01' else '02' end) +'|' +
			---   Rtrim(@Fe_cmdMon) + '|' +
    	   /*Monto de la operación | Afectación al IGV por ítem*/
              (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MonIte) else '0.00' end)  + '|' +
		   /*Monto IGV por ítem*/
              (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_ImpIte) else '0.00' end) + '|' +
            /*Categoría de impuestos*/
			   @Fe_CatImp+'|'+
		   /*Porcentaje del impuesto*/
              (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_MtoImp) else '0.00' end)  + '|' +
            /*Código de tipo de afectación del IGV*/
			  @Fe_TipAfec+ '|'+
            /*Código de tributo*/
			   @Fe_CodTri+'|'+
            /*Nombre de tributo*/
			   @Fe_NomTri+'|'+
            /*Código internacional tributo*/
			   @Fe_CodInt+'|'+
			   '|||||||||||||||' +
		   /*Descripción detallada del servicio prestado.*/
		        @fe_DesIte+'|' +
           /*Información adicional*/
		        '|' +
		   /*Código del producto.*/
				@fe_CodPro + '|' +
           /*Código de producto (SUNAT) */
		        @fe_ArtSunat+ '|' +
           /*Código de producto GS1 */
		         '|' +
		   /*Valor unitario por ítem sin IGV*/
             (case when @fe_TipVen <>'T' then CONVERT(VARCHAR(14),@fe_PreSigv) else CONVERT(VARCHAR(14),@fe_ValUni)  end)  + '|' 
        as DETALLE
	  UNION ALL

		/*-CONCEPTO TRIBUTARIO */
		SELECT 2 AS ORDEN, 
		         '|||||'+
					'}' 
				 AS DETALLE
		ORDER BY ORDEN

/*		
		SELECT 3 AS ORDEN, '~' -- FIN DE TABLA
				 AS DETALLE
        ORDER BY ORDEN
*/

END