USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_DOCUMENTO_ULTIMO]    Script Date: 21/06/2019 15:39:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ITBCP_OBTENER_DOCUMENTO_ULTIMO]
@NROPOS VARCHAR(15),@NROSERIEMAQ VARCHAR(15),@CDTIPODOC VARCHAR(5),@NRODOCUMENTO VARCHAR(10), @TIPO CHAR(1)
AS
-- OBSERVACIONES
-- @SQL CONTENDRA LAS CONSULTAS A EJECUTAR
-- @TIPO VARIA LA CONSULTA SEGUN LA LETRA
-- R (DOCUMENTO) OBTIENE SOLAMENTE EL ULTIMO DOCUMENTO IMPRESO POR NUMERO POR REQUIERE SOLAMENTE @NROPOS
-- C ( CABECERA) OBTIENE LA CABECERA DEL DOCUMENTO QUE SE NECESITE DE VENTA REQUIERE @NROSERIEMAQ , @CDTIPODOC , @NRODOCUMENTO
-- D ( DETALLE ) OBTIENE EL DETALLE DEL DOCUMENTO QUE SE NECESITE DE VENTAD REQUIERE @NROSERIEMAQ , @CDTIPODOC , @NRODOCUMENTO
-- P (   PAGO  ) OBTIENE EL PAGO DEL DOCUMENTO QUE SE NECESITE DE VENTAP REQUIERE @NROSERIEMAQ , @CDTIPODOC , @NRODOCUMENTO
-- E ( EMPRESA ) OBTIENE LOS DETALLES DE LA EMPRESA

DECLARE @SQL NVARCHAR(MAX) 

IF @TIPO = 'R'--OBTIENE EL ULTIMO DOCUMENTO IMPRESO EN EL NUMERO POS
BEGIN
	SET @SQL='SELECT TOP 1 nroseriemaq, cdtipodoc, nrodocumento FROM  venta WHERE (flgcierrez=0 or flgcierrez IS NULL) AND ltrim(rtrim('''+@NROPOS+''')) = nropos ORDER BY fecsistema DESC'
	EXECUTE SP_EXECUTESQL @SQL
END

IF @TIPO = 'C' --OBTIENE CABECERA DEL ULTIMO DOCUMENTO REGISTRADO EN VENTA
  BEGIN
			SELECT [cliente].[drcliente],
			[nroseriemaq],[cdtipodoc],[nrodocumento],
			FORMAT([fecdocumento],'yyyy-MM-dd') as fechaemision,
			FORMAT([fecdocumento],'hh:mm:ss')as horaemision,
            [nropos],[mtovueltosol],[mtovueltodol],
			V.[cdcliente],
			V.[ruccliente],
			V.[rscliente],
			[cdmoneda],
            [valorvta],[mtodscto],[mtosubtotal],[mtoimpuesto],[mtototal],
			[nroplaca],[cdusuario],
			CASE WHEN [cdusuanula] IS NULL THEN 'F' ELSE 'T' END AS ANULADO,
			ISNULL([tipoventa],'') AS [tipoventa],

			[observacion],
			[turno],[nrotarjeta],[odometro],
			[nrolicencia],[chkespecial],
			ISNULL([nrocelular],'') AS [nrocelular],
			ISNULL([PtosGanados],0) AS [PtosGanados],
			ISNULL([precio_orig],0.00) AS [precio_orig],
			ISNULL([cdruta],''),
			ISNULL([Codes],'') AS [Codes],
			ISNULL([codeID],'') AS [codeID],
			[cdhash],[scop],[nroguia],
			[fact_elect],[redondea_indecopi],[cdMedio_pago],
			ISNULL(nrobonus,'') AS nrobonus ,
			ISNULL(cdtranspor,'') as cdtranspor,
			(STUFF((SELECT ','+ LTRIM(RTRIM(D.cara))
			 FROM 
		   VentaD D 
		   WHERE D.CdLocal = V.CDLOCAL and D.NroSerieMaq = V.NROSERIEMAQ and 
		   D.CdTipoDoc =V.CDTIPODOC and D.NroDocumento=V.NRODOCUMENTO and D.CARA <> '' and d.cara is not null FOR XML PATH('')),1,1,'')) AS lado

			FROM [dbo].[venta] V
			LEFT JOIN [dbo].[cliente]
			ON [cliente].[cdcliente] = V.[cdcliente]
			WHERE 
			[nroseriemaq]=@NROSERIEMAQ AND
			[cdtipodoc]=@CDTIPODOC AND
			[nrodocumento]=@NRODOCUMENTO
  END
IF @TIPO = 'D' -- OBTIENDE DETALLE DEL ULTIMO DOCUMENTO IMPRESO EN VENTAD
	BEGIN 
				SELECT 
				v.[glosa],[cantidad],[precio],[mtototal],v.[cdarticulosunat],ISNULL([articulo].[cdunimed],'ZZ') AS cdunimed
				FROM [dbo].[ventad] v
				LEFT JOIN ARTICULO
				ON ARTICULO.cdarticulo = v.cdarticulo
				WHERE 
				[nroseriemaq]=@NROSERIEMAQ AND
				[cdtipodoc]=@CDTIPODOC AND
				[nrodocumento]=@NRODOCUMENTO
	END
IF @TIPO ='P' -- OBTIENE EL PAGO DEL ULTIMO DOCUMENTO IMPRESO EN VENTAP
	BEGIN
			SELECT 
				VENTAP.CDTPPAGO AS TIPOPAGO,
				CONVERT(DECIMAL(18,2),VENTAP.MTOPAGOSOL) AS SOL,
				CONVERT(DECIMAL(18,2),VENTAP.MTOPAGODOL) AS DOL,
				ISNULL(VENTAP.CDTARJETA,'') AS CDTARJETA,
				ISNULL(VENTAP.NROTARJETA,'') AS NROTARJETA,
				ISNULL(VENTA.TCAMBIO,0) AS CAMBIO
				FROM VENTAP
		INNER JOIN VENTA
		ON    VENTAP.CDTIPODOC=VENTA.CDTIPODOC AND 
			  VENTAP.NRODOCUMENTO = VENTA.NRODOCUMENTO AND
			  VENTAP.CDLOCAL = VENTA.CDLOCAL
		WHERE VENTA.NROSERIEMAQ = @NROSERIEMAQ AND 
			  VENTA.CDTIPODOC = @CDTIPODOC AND
			  VENTA.NRODOCUMENTO = @NRODOCUMENTO


	END
IF @TIPO = 'E'
BEGIN 

	SELECT top 1 REPLACE(REPLACE((STUFF((SELECT ''+ CASE WHEN LEN(LTRIM(RTRIM(t.TEXTO))) = 0 THEN ' ' ELSE LTRIM(RTRIM(t.TEXTO)) +'|' END FROM 
       ticket T
       WHERE t.DOCUMENTO = 'TICKET' AND t.TIPO = 'C' and T.documento = V.DOCUMENTO 
	   AND T.tipo = V.tipo 
	    FOR XML PATH('')),1,1,'')),'#x20;',''),'&','') as TEXTO FROM TICKET V WHERE V.DOCUMENTO = 'TICKET' AND V.TIPO = 'C'

	
END