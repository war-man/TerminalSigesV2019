USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_PARAMETROS_CIERRE]    Script Date: 10/06/2019 15:23:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[SP_ITBCP_OBTENER_PARAMETROS_CIERRE] 
    @TIPO char(1)
AS 
	SELECT [cdcierre],[flggrupo01],[flggrupo02],[flggrupo03],[flggrupo04],[flggrupo05],
		   [flgvendedor],[flgarticulo],[flgpago],[flgcara],[flgdocmanual],[flgusuario],
		   [FLGCANJEARTICULO],[flgdesc],[flgarticulodesc],[flgdepositogrifero],
		   [flgconsolidarlados],[flggastogrifero],[flgstknegativo]
	  FROM [dbo].[cierre] WHERE cdcierre=@TIPO
