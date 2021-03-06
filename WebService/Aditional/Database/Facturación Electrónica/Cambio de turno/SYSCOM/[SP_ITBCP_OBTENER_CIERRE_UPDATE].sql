USE [BACKOFFICE]
GO
/****** Object:  StoredProcedure [dbo].[SP_ITBCP_OBTENER_CIERRE_UPDATE]    Script Date: 21/06/2019 15:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_ITBCP_OBTENER_CIERRE_UPDATE]  
@Tipo CHAR(1)
AS  
  
DECLARE @Fecha AS VARCHAR(50), @Hora VARCHAR(50), @FechaReal SMALLDATETIME,
        @TipoControl VARCHAR(20)

SET @TipoControl = (SELECT LTRIM(RTRIM(TipoControl)) FROM Parametro) 
SET @FechaReal   = (SELECT GETDATE())  
SET @Fecha       =  RIGHT(CONVERT(VARCHAR(8),@FechaReal,112),2) + SUBSTRING(CONVERT(VARCHAR(8),@FechaReal,112),5,2) + RIGHT(CONVERT(VARCHAR(4),@FechaReal,112),2)  
SET @Hora        =  CONVERT(VARCHAR(2),@FechaReal,108) + RIGHT(CONVERT(VARCHAR(5),@FechaReal,108),2)  
  
BEGIN TRANSACTION TRANX  
  
  IF UPPER(@TipoControl) = 'VOX'
  BEGIN  
    UPDATE CIERRE_PAMPC  
    SET    tipo = @Tipo, fecha = CONVERT(VARCHAR(8),@FechaReal,112), hora = CONVERT(VARCHAR(10),@FechaReal,108), ESTADO = '1'
    WHERE  CODIGO = 1 
  END
  ELSE
  BEGIN
    UPDATE CIERRE_PAMPC  
    SET    tipo = @Tipo, fecha = CONVERT(VARCHAR(8),@FechaReal,112), hora = CONVERT(VARCHAR(10),@FechaReal,108), ESTADO = '1'
    WHERE  CODIGO = 1  
  END
  
IF @@ERROR <> 0  
BEGIN  
  ROLLBACK TRANSACTION TRANX  
  RETURN -1  
END  
ELSE  
BEGIN  
  COMMIT TRANSACTION TRANX  
END  


