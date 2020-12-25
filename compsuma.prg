*:******************************************************************************
*:
*: Archivo de procedimientoC:\MAIN6\SIFXXI_FQ\CODIGO\COMPSUMA.PRG
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
*:   COMPSUMA
*-- Listado Detallado de Facturas
LOCAL saldos
LOCAL cArchName
LOCAL myidfacturai, myidfacturaf, myfechemii, myfechemif, myidclientei, myidclientef
LOCAL myhorai, myhoraf

STORE SPACE(15) TO myidfacturai, myidfacturaf, myidclientei, myidclientef
STORE date() TO myfechemii, myfechemif

SET MULTILOCKS ON
SET EXCLUSIVE OFF
SET delete ON
SET TALK OFF
SET date TO BRITISH
SET CENTURY ON
SET SAFETY OFF
SET EXACT ON
SET LOCK OFF

serverdb = dirbase

SET DATABASE TO
CLOSE DATABASES
CLOSE TABLES ALL
open DATABASE &serverdb\PSIFXXI
open DATABASE &serverdb\TSIFXXI
open DATABASE &serverdb\SIFXXI

USE PSIFXXI!entradas IN 0 ALIAS entradas
USE PSIFXXI!detent IN 0 ALIAS detent
USE SIFXXI!producto IN 0 ALIAS producto
USE SIFXXI!Contacto IN 0 ALIAS Contacto
USE TSIFXXI!w_Retfte IN 0 ALIAS w_Retfte
USE TSIFXXI!w_Detret IN 0 ALIAS w_Detret

**
** Selecciona proveedores
**

USE PSIFXXI!sql_proent IN 0 ALIAS myidcliente

**
** Establece limites
**

USE PSIFXXI!sql_entlim IN 0 ALIAS myresult

IF _TALLY>0
	SELECT myresult
	GO TOP
	myidfacturai=myresult.minimoid
	myidfacturaf=myresult.maximoid
	myfechemii=myresult.minimof
	myfechemif=myresult.maximof
	myidclientei=myresult.minimoc
	myidclientef=myresult.maximoc
ENDIF

saldos = CREATEOBJECT('fbtransdet')

saldos.Caption = 'Listado Sumarizado de Compras'

saldos.Combo1.BoundColumn = 1
saldos.Combo1.RowSourceType = 3
saldos.Combo1.RowSource = [SELECT DISTINC IIF(!EMPTY(nomborg), nomborg, nombcont) as nombre, idcont FROM contacto, myidcliente WHERE contacto.idcont=myidcliente.idprov ORDER BY nombre INTO CURSOR mynombre]

saldos.Combo2.BoundColumn = 1
saldos.Combo2.RowSourceType = 3
saldos.Combo2.RowSource = [SELECT DISTINC IIF(!EMPTY(nomborg), nomborg, nombcont) as nombre, idcont FROM contacto, myidcliente WHERE contacto.idcont=myidcliente.idprov ORDER BY nombre INTO CURSOR mynombre1]

saldos.desde = myresult.minimof
saldos.hasta = myresult.maximof
saldos.nrodesde = myresult.minimoid
saldos.nrohasta = myresult.maximoid

saldos.cliente = myresult.minimoc
saldos.clientef = myresult.maximoc

IF saldos.Combo1.Listcount >0
	saldos.Combo1.Listindex = 1
ENDIF

IF saldos.Combo2.Listcount >0
	saldos.Combo2.Listindex = saldos.Combo2.Listcount
ENDIF


**

saldos.SHOW(1)

IF saldos.eleccion = 0
	RETURN
ENDIF

cArchName = '"' + ALLTRI(saldos.Caption) + '"'

WAIT WINDOW NOWAIT [Recopilando información... Espere un momento.]

IF saldos.Optgorden.OptFecha.value=1
	myfechemii=saldos.desde
	myfechemif=saldos.hasta
ELSE
	myidfacturai=saldos.nrodesde
	myidfacturaf=saldos.nrohasta
ENDIF

myidclientei=saldos.cliente
myidclientef=saldos.clientef

SELECT entradas.identrada, entradas.idprov, entradas.idtransac, entradas.fechfac AS fechemi, ;
	entradas.impentrada, entradas.tarifa0, entradas.tarifai, ;
	entradas.impiva, entradas.cargoserv, entradas.numref, ;
	Left(ALLTRIM(entradas.numref),6) AS serie, RIGHT(ALLTRIM(entradas.numref),7) AS numfac, entradas.autosri, ;
	IIF(EMPTY(Contacto.nomborg), Contacto.Nombcont,Contacto.nomborg) AS nombre, Contacto.ruc ;
	FROM entradas, Contacto ;
	WHERE BETWEEN(entradas.identrada, myidfacturai, myidfacturaf) AND ;
	BETWEEN(entradas.fechfac, myfechemii, myfechemif) AND ;
	BETWEEN(IIF(EMPTY(Contacto.nomborg), Contacto.Nombcont,Contacto.nomborg), myidclientei, myidclientef) AND ;
	entradas.idprov==Contacto.idcont ;
	ORDER BY entradas.fechfac ;
	INTO CURSOR r_detfac

SELECT DISTINC w_Retfte.*, w_Detret.* FROM w_Retfte, w_Detret ;
	WHERE w_Retfte.idretfte=w_Detret.idretfte ;
	INTO CURSOR myRetfte
SELECT myRetfte

SELECT r_detfac.*, myRetfte.* FROM r_detfac, myRetfte ;
	WHERE ALLTRIM(r_detfac.numref) = RIGHT(ALLTRIM(myRetfte.detalle),13) ;
	INTO CURSOR r_detfac

SELECT r_detfac


SELECT r_detfac
COPY TO misentradas TYPE XL5
GO TOP

DO CASE
	*-- ENVIAR A LA IMPRESORA
CASE saldos.eleccion=1

	REPORT form &dirreport\COMPSUMA TO PRINTER NOCONSOLE NOEJECT

	*-- PRESENTACION PRELIMINAR
CASE saldos.eleccion=2
	REPORT form &dirreport\COMPSUMA PREVIEW

	*-- Exportando archivos a Excel
CASE saldos.eleccion=3
	COPY TO &cArchName TYPE XLS

	=MESSAGEBOX('Los resultados se han exportado al Archivo: ' + CHR(13) + ;
		cArchName, 0+64, 'Exportar archivos a Excel')
ENDCASE

CLOSE TABLES ALL
CLOSE DATABASES ALL
SET DATABASE TO
saldos = .NULL.
