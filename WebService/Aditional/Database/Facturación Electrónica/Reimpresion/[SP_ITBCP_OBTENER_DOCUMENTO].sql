USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_DOCUMENTO]    Script Date: 21/06/2019 15:39:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ITBCP_OBTENER_DOCUMENTO]
@NRODOCUMENTO VARCHAR(10),@CDTIPODOC VARCHAR(5),@NROSERIEMAQ VARCHAR(100),@FECHA VARCHAR(10), @TIPO CHAR(1)
AS

DECLARE @SQL NVARCHAR(MAX)

IF @TIPO = 'G'
	BEGIN
		SELECT NROSERIEMAQ,CDTIPODOC, NRODOCUMENTO,FORMAT(fecdocumento,'yyyyMM') as FECHA FROM VENTAG WHERE NRODOCUMENTO=@NRODOCUMENTO AND cdtipodoc=@CDTIPODOC
	END



IF @TIPO = 'C'
  BEGIN
	SET @SQL='SELECT ISNULL([cliente].[drcliente],'''') AS [drcliente],
			[nroseriemaq],[cdtipodoc],[nrodocumento],
			FORMAT([fecdocumento],''yyyy-MM-dd'') as fechaemision,
			FORMAT([fecdocumento],''hh:mm:ss'')as horaemision,
            [nropos],[mtovueltosol],[mtovueltodol],
			V.[cdcliente],
			V.[ruccliente],
			V.[rscliente],
			[cdmoneda],
            [valorvta],[mtodscto],[mtosubtotal],[mtoimpuesto],[mtototal],
			[nroplaca],[cdusuario],
			CASE WHEN [cdusuanula] IS NULL THEN ''F'' ELSE ''T'' END AS ANULADO,
			ISNULL([tipoventa],'''') AS [tipoventa],

			[observacion],
			[turno],[nrotarjeta],[odometro],
			[nrolicencia],[chkespecial],
			ISNULL([nrocelular],'''') AS [nrocelular],
			ISNULL([PtosGanados],0) AS [PtosGanados],
			0.00 AS [precio_orig],
			ISNULL([cdruta],''''),
			ISNULL([Codes],'''') AS [Codes],
			ISNULL([codeID],'''') AS [codeID],
			[cdhash],[scop],[nroguia],
			[fact_elect],[redondea_indecopi],[cdMedio_pago],
			ISNULL(nrobonus,'''') AS nrobonus ,
			ISNULL(cdtranspor,'''') as cdtranspor,
			ISNULL((STUFF((SELECT '''',''''+ LTRIM(RTRIM(D.cara))
			 FROM 
		   VentaD201903 D 
		   WHERE D.CdLocal = V.CDLOCAL and D.NroSerieMaq = V.NROSERIEMAQ and 
		   D.CdTipoDoc =V.CDTIPODOC and D.NroDocumento=V.NRODOCUMENTO and D.CARA <> '''' and d.cara is not null FOR XML PATH('''')),1,1,'''')),'''') AS lado
	  FROM [dbo].[Venta'+@FECHA+']  V
	  LEFT JOIN [dbo].[cliente]
	  ON [cliente].[cdcliente] = V.[cdcliente]
	  WHERE NRODOCUMENTO='''+@NRODOCUMENTO+''' AND cdtipodoc='''+@CDTIPODOC+''' AND nroseriemaq = '''+@NROSERIEMAQ+''' '

	  EXECUTE SP_EXECUTESQL @SQL
  END
IF @TIPO = 'D'
	BEGIN 
	SET @SQL  ='SELECT 
			   v.[glosa],[cantidad],[precio],[mtototal],v.[cdarticulosunat],ISNULL([articulo].[cdunimed],''ZZ'') AS cdunimed
			   FROM [dbo].[VentaD'+@FECHA+'] v
			   LEFT JOIN ARTICULO
			   ON ARTICULO.cdarticulo = v.cdarticulo
			   WHERE NRODOCUMENTO='''+@NRODOCUMENTO+''' AND cdtipodoc='''+@CDTIPODOC+''' AND nroseriemaq = '''+@NROSERIEMAQ+''' '
	  EXECUTE SP_EXECUTESQL @SQL
	END
IF @TIPO ='P'
	BEGIN
		SET @SQL='SELECT 
				P.CDTPPAGO AS TIPOPAGO,
				CONVERT(DECIMAL(18,2),P.MTOPAGOSOL) AS SOL,
				CONVERT(DECIMAL(18,2),P.MTOPAGODOL) AS DOL,
				ISNULL(P.CDTARJETA,'''') AS CDTARJETA,
				ISNULL(P.NROTARJETA,'''') AS NROTARJETA,
				ISNULL(V.TCAMBIO,0) AS CAMBIO
				FROM VENTAP'+@FECHA+' P
		INNER JOIN VENTA'+@FECHA+' V
		ON    P.CDTIPODOC=V.CDTIPODOC AND 
			  P.NRODOCUMENTO = V.NRODOCUMENTO AND
			  P.CDLOCAL = V.CDLOCAL
		WHERE P.NROSERIEMAQ = '''+@NROSERIEMAQ+''' AND 
			  P.CDTIPODOC = '''+@CDTIPODOC+''' AND
			  P.NRODOCUMENTO = '''+@NRODOCUMENTO+''' '
		EXECUTE SP_EXECUTESQL @SQL
	END