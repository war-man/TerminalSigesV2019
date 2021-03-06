USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_GENERA_PAGO_ACT]    Script Date: 21/06/2019 15:37:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****Procedimiento ACEPTA UBL2.1 06/05/2019********/

ALTER PROCEDURE [dbo].[SP_ITBCP_GENERA_PAGO_ACT]

	@fe_ConPag VARCHAR(60), @fe_MtoPag numeric(12,2),@fe_TipVen CHAR(1)

AS

	SELECT 1 AS ORDEN,
   /*Descripcion del medio de pago*/
	(case when @fe_TipVen <> 'T' then rtrim(@fe_ConPag) else '' end) + '|' +
   /*Monto del medio de pago*/
	(case when @fe_TipVen <> 'T' then CONVERT(VARCHAR(14),@fe_MtoPag) else '' end) +
      '}' 
	AS PAGO
		ORDER BY ORDEN  

/*
UNION ALL
	SELECT 2 AS ORDEN, '~' -- FIN DE TABLA
		 AS PAGO
	UNION ALL

	SELECT 3 AS ORDEN, '\'
		AS PAGO	
	ORDER BY ORDEN  
	*/