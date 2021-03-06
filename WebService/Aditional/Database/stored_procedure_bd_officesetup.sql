USE [BACKOFFICESETUP]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_USUARIO_SISTEMA]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_OBTENER_USUARIO_SISTEMA]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_INFORMACION_MONEDA]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_OBTENER_INFORMACION_MONEDA]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_INFORMACION_EMRPESA]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_OBTENER_INFORMACION_EMPRESA]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_INFOMACION_VENDEDOR]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_OBTENER_INFOMACION_VENDEDOR]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_TIPO_TARJETA]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_LISTAR_TIPO_TARJETA]
GO
DROP PROCEDURE [SP_ITBCP_OBTENER_TIPO_TARJETA]
GO

/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_DISTRITOS]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_LISTAR_DISTRITOS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_DEPARTAMENTOS]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_LISTAR_DEPARTAMENTOS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_CONFIGURACION]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_LISTAR_CONFIGURACION]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_BANCO]    Script Date: 1/28/2019 2:30:41 PM ******/
DROP PROCEDURE [dbo].[SP_ITBCP_LISTAR_BANCO]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_BANCO]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ITBCP_LISTAR_BANCO]
@cdbanco CHAR(4)
AS
Select dsbanco from tab0s07 Where @cdbanco=cdbanco
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_CONFIGURACION]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ITBCP_LISTAR_CONFIGURACION]
AS
	select * from Tab0s00
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_DEPARTAMENTOS]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ITBCP_LISTAR_DEPARTAMENTOS]
AS
	Select * from tab0s09
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_DISTRITOS]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ITBCP_LISTAR_DISTRITOS]
AS
	Select cddistrito, dsdistrito from tab0s10
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_LISTAR_TIPO_TARJETA]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ITBCP_LISTAR_TIPO_TARJETA]
 
AS
Select * from tab0s08 
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_INFOMACION_VENDEDOR]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ITBCP_OBTENER_TIPO_TARJETA]
	@cdtarjeta CHAR(2)
AS
Select * from tab0s08 Where @cdtarjeta=cdtarjeta
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_INFOMACION_VENDEDOR]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ITBCP_OBTENER_INFOMACION_VENDEDOR]
	@cdempresa char(2)
AS

	select Tab0s05.cdvendedor, substring(Tab0s05.dsvendedor,1,35) as dsvendedor
	from tab0s05 INNER JOIN tab1s99 ON Tab0s05.cdvendedor = Tab1s99.codigo 
	Where Tab1s99.tipo = 'VEN' and Tab1s99.cdempresa = @cdempresa ORDER BY Tab0s05.cdvendedor
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_INFORMACION_EMRPESA]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ITBCP_OBTENER_INFORMACION_EMPRESA]
	@cdempresa char(3)
AS
	Select * from tab0s01 where cdempresa = @cdempresa
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_INFORMACION_MONEDA]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ITBCP_OBTENER_INFORMACION_MONEDA]
AS
	Select cdmoneda, substring(dsmoneda,1,18) as dsmoneda, smbmoneda from tab0s14
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_USUARIO_SISTEMA]    Script Date: 1/28/2019 2:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ITBCP_OBTENER_USUARIO_SISTEMA]
	@cdempresa char(2)
AS
	Select Tab0s02.cdusuario, Tab0s02.dsusuario, Tab0s02.Password, Tab0s02.flgdscto, Tab0s02.flgborraritem,
	 Tab0s02.flganular FROM tab0s02 LEFT OUTER JOIN tab1s99 ON Tab0s02.cdusuario = Tab1s99.codigo
	 Where cdempresa = @cdempresa
GO
