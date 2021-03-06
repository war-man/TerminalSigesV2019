USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_DOCUMENTO]    Script Date: 10/06/2019 15:25:30 ******/
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
		SET @SQL='SELECT cdlocal,nroseriemaq,cdtipodoc,nrodocumento,CAST (FORMAT(fecdocumento,''yyyyMM'') AS VARCHAR(10)) as fecdocumento FROM VENTAG WHERE NRODOCUMENTO='''+@NRODOCUMENTO+''' AND cdtipodoc='''+@CDTIPODOC+''''
		EXECUTE SP_EXECUTESQL @SQL
	END



IF @TIPO = 'C'
  BEGIN
	SET @SQL='SELECT 

		   [cdlocal],[nroseriemaq],[cdtipodoc],[nrodocumento],[fecdocumento],[fecproceso],
		   [fecsistema],[nropos],[mtovueltosol],[mtovueltodol],[cdalmacen],[cdcliente],
		   [ruccliente],[rscliente],[nroproforma],[cdprecio],[cdmoneda],[porservicio],
		   [pordscto1],[pordscto2],[pordscto3],[pordsctoeq],[mtonoafecto],[valorvta]
		   [mtodscto],[mtosubtotal],[mtoservicio],[mtoimpuesto],[mtototal],[cdtranspor]
		   [ructranspor],[nroplaca],[drpartida],[MarcaVehic],[drdestino],[cdusuario],
		   [cdvendedor],[cdusuanula],[fecanula],[fecanulasis],[tipofactura],[flgmanual]
		   [tcambio],[nroocompra],[flgcierrez],[observacion],[flgmovimiento],[referencia]
		   [nroserie1],[nroserie2],[turno],[nrobonus],[nrotarjeta],[odometro],[archturno]
		   [mtorecaudo],[inscripcion],[chofer],[nrolicencia],[chkespecial],[tipoventa]
		   [nrocelular],[PtosGanados],[TipoAcumula],[ValorAcumula],[c_centralizacion]
		   [cantcupon],[mtocanje],[MtoPercepcion],[cdruta],[Codes],[codeID],[mensaje1]
		   [mensaje2],[pdf417],[cdhash],[scop],[nroguia],[mtodetraccion],[porcdetraccion]
		   [ctadetraccion],[fact_elect],[redondea_indecopi],[cdMedio_Pago]
	  FROM [dbo].[Venta'+@FECHA+']  
	  WHERE NRODOCUMENTO='''+@NRODOCUMENTO+''' AND cdtipodoc='''+@CDTIPODOC+''' AND nroseriemaq = '''+@NROSERIEMAQ+''' '
	  EXECUTE SP_EXECUTESQL @SQL
  END
IF @TIPO = 'D'
	BEGIN 
	SET @SQL  = 'SELECT 
			   [cdlocal],[nroseriemaq],[nropos],[cdtipodoc],[nrodocumento],[fecdocumento],[fecproceso],[nroitem],
			   [cdarticulo],[cdalterna],[talla],[cdvendedor],[impuesto],[pordscto1],[pordscto2],[pordscto3],
			   [pordsctoeq],[cantidad],[cant_ncredito],[precio],[mtonoafecto],[valorvta],[mtodscto]
			   [mtosubtotal],[mtoservicio],[mtoimpuesto],[mtototal],[flgcierrez],[cara],[nrogasboy],
			   [turno],[nroguia],[nroproforma],[moverstock],[glosa],[manguera],[costo],[precio_orig],
			   [precioafiliacion],[PtosGanados],[TipoAcumula],[ValorAcumula],[TipoSuma],[Costo_Venta],
			   [MtoPercepcion],[cdpack],[mtodetraccion],[porcdetraccion],[redondea_indecopi],[cdarticulosunat]
			   FROM [dbo].[VentaD'+@FECHA+']
			   WHERE NRODOCUMENTO='''+@NRODOCUMENTO+''' AND cdtipodoc='''+@CDTIPODOC+''' AND nroseriemaq = '''+@NROSERIEMAQ+''' '
	  EXECUTE SP_EXECUTESQL @SQL
	END
IF @TIPO ='P'
	BEGIN
		SET @SQL='SELECT [cdlocal],[nroseriemaq],[nropos],[cdtipodoc],[nrodocumento],[dbo].[VentaP'+@FECHA+'].[cdtppago],[dstppago],
        [fecdocumento],[fecproceso],[cdbanco],[nrocuenta],[nrocheque],[cdtarjeta],[nrotarjeta],[mtopagosol],[mtopagodol],
        [flgcierrez],[turno],[nroncredito]
		FROM [dbo].[VentaP'+@FECHA+'] 
		INNER JOIN [dbo].[tipopago]
		ON [dbo].[VentaP'+@FECHA+'].cdtppago = [dbo].[tipopago].cdtppago
		WHERE NRODOCUMENTO='''+@NRODOCUMENTO+''' AND cdtipodoc='''+@CDTIPODOC+''' AND nroseriemaq = '''+@NROSERIEMAQ+''' '
		EXECUTE SP_EXECUTESQL @SQL
	END