USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_DOCUMENTO_ULTIMO]    Script Date: 10/06/2019 15:25:40 ******/
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
--

DECLARE @SQL NVARCHAR(MAX) 

IF @TIPO = 'R'--OBTIENE EL ULTIMO DOCUMENTO IMPRESO EN EL NUMERO POS
BEGIN
	SET @SQL='SELECT TOP 1 nroseriemaq, cdtipodoc, nrodocumento FROM  venta WHERE (flgcierrez=0 or flgcierrez IS NULL) AND ltrim(rtrim('''+@NROPOS+''')) = nropos ORDER BY fecsistema DESC'
	EXECUTE SP_EXECUTESQL @SQL
END

IF @TIPO = 'C' --OBTIENE CABECERA DEL ULTIMO DOCUMENTO REGISTRADO EN VENTA
  BEGIN
	SET @SQL='SELECT 
			[cdlocal],[nroseriemaq],[cdtipodoc],[nrodocumento],[fecdocumento],[fecproceso],[fecsistema],
            [nropos],[mtovueltosol],[mtovueltodol],[cdalmacen],[cdcliente],[ruccliente],[rscliente],
			[nroproforma],[cdprecio],[cdmoneda],[porservicio],[pordscto1],[pordscto2],[pordscto3],[pordsctoeq],
            [mtonoafecto],[valorvta],[mtodscto],[mtosubtotal],[mtoservicio],[mtoimpuesto],[mtototal],[cdtranspor],
			[nroplaca],[drpartida],[drdestino],[cdusuario],[cdvendedor],[cdusuanula],[fecanula],[fecanulasis]
			[tipofactura],[flgmanual],[tcambio],[nroocompra],[flgcierrez],[observacion],[flgmovimiento],[referencia],
			[nroserie1],[nroserie2],[turno],[nrobonus],[nrotarjeta],[odometro],[archturno],[marcavehic],[mtorecaudo],
			[inscripcion],[chofer],[nrolicencia],[chkespecial],[tipoventa],[nrocelular],[PtosGanados],[precio_orig],
            [rucinvalido],[usadecimales],[tipoacumula],[valoracumula],[cantcupon],[c_centralizacion],[mtocanje],
			[mtopercepcion],[cdruta],[Codes],[codeID],[mensaje1],[mensaje2],[pdf417],[cdhash],[scop],[nroguia],
			[porcdetraccion],[mtodetraccion],[ctadetraccion],[fact_elect],[redondea_indecopi],[cdMedio_pago]
			FROM [dbo].[venta]
			WHERE 
			[nroseriemaq]='''+@NROSERIEMAQ+'''  AND
			[cdtipodoc]='''+@CDTIPODOC+''' AND
			[nrodocumento]='''+@NRODOCUMENTO+'''  '
	  EXECUTE SP_EXECUTESQL @SQL
  END
IF @TIPO = 'D' -- OBTIENDE DETALLE DEL ULTIMO DOCUMENTO IMPRESO EN VENTAD
	BEGIN 
	SET @SQL  = 'SELECT 
				[cdlocal],[nroseriemaq],[nropos],[cdtipodoc],[nrodocumento],[fecdocumento],[fecproceso],
				[nroitem],[cdarticulo],[cdalterna],[talla],[cdvendedor],[impuesto],[pordscto1],[pordscto2],
				[pordscto3],[pordsctoeq],[cantidad],[cant_ncredito],[precio],[mtonoafecto],[valorvta],[mtodscto],
				[mtosubtotal],[mtoservicio],[mtoimpuesto],[mtototal],[flgcierrez],[cara],[nrogasboy],[turno],
				[nroguia],[nroproforma],[moverstock],[glosa],[archturno],[manguera],[costo],[precio_orig],
				[PtosGanados],[precioafiliacion],[tipoacumula],[valoracumula],[Costo_Venta],[TipoSuma],
				[trfgratuita],[mtopercepcion],[Cdpack],[porcdetraccion],[mtodetraccion],[redondea_indecopi]
				[cdarticulosunat]
				FROM [dbo].[ventad]
				WHERE 
				[nroseriemaq]='''+@NROSERIEMAQ+'''  AND
				[cdtipodoc]='''+@CDTIPODOC+''' AND
				[nrodocumento]='''+@NRODOCUMENTO+'''  '
	  EXECUTE SP_EXECUTESQL @SQL
	END
IF @TIPO ='P' -- OBTIENE EL PAGO DEL ULTIMO DOCUMENTO IMPRESO EN VENTAP
	BEGIN
		SET @SQL='SELECT 
				   [cdlocal],[nroseriemaq],[nropos],[cdtipodoc],[nrodocumento],[dbo].[ventap].[cdtppago],[dstppago],
				   [fecdocumento],[fecproceso],[cdbanco],[nrocuenta],[nrocheque],[cdtarjeta],[nrotarjeta],[mtopagosol],
				   [mtopagodol],[flgcierrez],[turno],[nroncredito],[valoracumula]
				   FROM [dbo].[ventap]
				   INNER JOIN [dbo].[tipopago]
				   ON [dbo].[ventap].[cdtppago]=[dbo].[tipopago].[cdtppago]
				   WHERE 
				   [nroseriemaq]='''+@NROSERIEMAQ+'''  AND
				   [cdtipodoc]='''+@CDTIPODOC+''' AND
				   [nrodocumento]='''+@NRODOCUMENTO+'''  '
		EXECUTE SP_EXECUTESQL @SQL
	END