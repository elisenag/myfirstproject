*:******************************************************************************
*:
*: Archivo de procedimientoC:\MAIN6\SIFXXI_FQ\CODIGO\ACTINVEN.PRG
*:
*:	Tcnlgo. Richard Jiménez P.
*:	Abastos 'La Casa del Regalo'
*:	Juana Atabalipa 1-11 y Obispo Mosquera
*:	Ibarra
*:	
*:	
*:	Ecuador
*:	
*:	
*:	
*:	
*:	
*:	
*:
*: Documentado mediante la versión del Asistente para formato de Visual FoxPro  .05
*:******************************************************************************
*:   ACTINVEN
LOCAL cdbnew, cUbicacion, cPeriodo, cPath, wubicacion, serverdb, servertmp, csperiodo, wsperiodo, cserverpath
LOCAL m_costopro, m_unidexist, t_cantart, t_preciounit, t_costounit, t_idtransac, llError

SET MULTILOCKS ON
SET EXCLUSIVE ON
SET delete ON
SET TALK OFF
SET date TO BRITISH
SET CENTURY ON
SET SAFETY OFF
SET EXACT ON
SET LOCK OFF


ctarget = "c:\megaofertas\data"
cDestino = "c:\megaofertas1\data"

IF MESSAGEBOX('Antes de realizar este proceso, asegúrese que'+CHR(13)+;
		'no existan otros usuarios dentro del Sistema.' + CHR(13) +;
		'Desea Continuar?', 32 + 4, 'Actualizar Sistema') = 7
	RETURN
ENDIF

WAIT WINDOW 'Actualizando sistema...' NOWAIT


SET DATABASE TO
CLOSE DATABASES ALL

*** autosri.dbf
DO copiadbf WITH "autosri", "autosri"
DO copiadbf WITH "bancos", "bancos"
DO copiadbf WITH "barras", "barras"
DO copiadbf WITH "bodega", "bodega"
DO copiadbf WITH "caja", "caja"
DO copiadbf WITH "categoria", "categoria"
DO copiadbf WITH "ciudad", "ciudad"
DO copiadbf WITH "clientes", "clientes"
DO copiadbf WITH "configdbf", "configdbf"
DO copiadbf WITH "configurar", "configurar"
DO copiadbf WITH "contacto", "contacto"
DO copiadbf WITH "cretfte", "cretfte"
DO copiadbf WITH "emplea", "emplea"
DO copiadbf WITH "expira", "expira"
DO copiadbf WITH "fabrica", "fabrica"
DO copiadbf WITH "grupo", "grupo"
DO copiadbf WITH "newmnu", "newmnu"
DO copiadbf WITH "oldmnu", "oldmnu"
DO copiadbf WITH "pais", "pais"
DO copiadbf WITH "producp", "producp"
DO copiadbf WITH "producto", "producto"
DO copiadbf WITH "provee", "provee"
DO copiadbf WITH "provincia", "provincia"
DO copiadbf WITH "recibo", "recibo"
DO copiadbf WITH "red", "red"
DO copiadbf WITH "region", "region"
DO copiadbf WITH "saldo_si", "saldo_si"
DO copiadbf WITH "setup", "setup"
DO copiadbf WITH "sifxxi", "sifxxi"
DO copiadbf WITH "tarjcred", "tarjcred"
DO copiadbf WITH "tarjetac", "tarjetac"
DO copiadbf WITH "tbancos", "tbancos"
DO copiadbf WITH "tclientes", "tclientes"
DO copiadbf WITH "tipofac", "tipofac"
DO copiadbf WITH "tipoorg", "tipoorg"
DO copiadbf WITH "trans_b", "trans_b"
DO copiadbf WITH "unidad", "unidad"
DO copiadbf WITH "usuarios", "usuarios"
DO copiadbf WITH "utilidad", "utilidad"
DO copiadbf WITH "vehiculo", "vehiculo"

DO copiadbf WITH "ajuste", "w_ajuste"
DO anexardbf WITH "w_ajuste", "w_ajuste"

DO copiadbf WITH "detaju", "w_detaju"
DO anexardbf WITH "w_detaju", "w_detaju"

DO copiadbf WITH "w_detret", "w_detret"

DO copiadbf WITH "entradas", "w_entradas"
DO anexardbf WITH "w_entradas", "w_entradas"

DO copiadbf WITH "factura", "w_factura"
DO anexardbf WITH "w_factura", "w_factura"

DO copiadbf WITH "pagos", "w_pagos"

DO copiadbf WITH "w_retfte", "w_retfte"

DO copiadbf WITH "kardex", "w_t_kardex"
DO anexardbf WITH "w_t_kardex", "w_t_kardex"

use c:\megaofertas\data\detent in 0 alias detent
SELECT detent
REPLACE unidades with 0 FOR unidades>99

USE c:\megaofertas\data\detfac in 0 alias detfac
select DETFAC
REPLACE unidades with 0 FOR unidades>99

**select * from detfac into TABLE c:\megaofertas\data\misdetfac
**use in misdetfac
use in detent
use in detfac

DO copiadbf WITH "detent", "w_detent"
DO anexardbf WITH "w_detent", "w_detent"


DO copiadbf WITH "misdetfac", "w_detfac"
DO anexardbf WITH "w_detfac", "w_detfac"



CLOSE TABLES ALL
RETURN



PROCEDURE copiadbf
PARAMETERS origen, destino
	WAIT WINDOW NOWAIT "copiando... "+origen+" .. hasta .. "+destino
	USE &ctarget\&origen IN 0 ALIAS old_origen
	USE &cdestino\&destino IN 0 ALIAS new_destino

	SELECT old_origen
	PACK
	REINDEX COMPACT
	SELECT new_destino
	DELETE ALL
	PACK
	REINDEX COMPACT
	APPEND FROM &ctarget\&origen

	USE IN old_origen
	USE IN new_destino
RETURN
ENDPROC

PROCEDURE anexardbf
PARAMETERS origen, destino
	WAIT WINDOW NOWAIT "anexando... "+origen+" .. hasta .. "+destino
	USE &ctarget\&origen IN 0 ALIAS old_origen
	USE &cdestino\&destino IN 0 ALIAS new_destino

	SELECT old_origen
	PACK
	SELECT new_destino
	APPEND FROM &ctarget\&origen

	USE IN old_origen
	USE IN new_destino
RETURN
ENDPROC