*:******************************************************************************
*:
*: Archivo de procedimientoC:\MAIN6\SIFXXI_FQ\CODIGO\COMPRAS.PRG
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
*:   COMPRAS
*-- Reporte de Compras de Productos
LOCAL saldos, cTipoDesde, cTipoHasta


*-- Abre las tablas necesarias para el informe


LOCAL cdbnew, cUbicacion, cPeriodo, cPath, wubicacion, serverdb, servertmp, csperiodo, wsperiodo, cserverpath
LOCAL dirreport
SET MULTILOCKS ON
SET EXCLUSIVE OFF
SET delete ON
SET TALK OFF
SET date TO BRITISH
SET CENTURY ON
SET SAFETY OFF
SET EXACT ON
SET LOCK OFF

dirreport = oApp.dirreport
serverdb = oApp.serverdb

USE &serverdb\transac IN 0 AGAIN ALIAS lTransac
USE &serverdb\KARDEX IN 0 AGAIN ALIAS LKardex
USE &serverdb\producto IN 0 AGAIN ALIAS lproducto

saldos = CREATEOBJECT('inputpro1')
saldos.Caption = 'Listado de Movimientos de Inventario'

*-- Combo Tipo de documento
saldos.CboTipoFrom.RowSource = 'Entradas'
saldos.CboTipoFrom.RowSourceType = 1
saldos.CboTipoFrom.REQUERY()
saldos.CboTipoFrom.Listindex = 1

saldos.CboTipoTo.RowSource = 'Entradas'
saldos.CboTipoTo.RowSourceType = 1
saldos.CboTipoTo.REQUERY()
saldos.CboTipoTo.Listindex = 1

*-- Activa la ventana de busqueda
saldos.SHOW(1)

*-- Poner los tipos en variables de memoria
cTipoDesde = 'EC'
cTipoHasta = 'EN'

IF saldos.eleccion=0
	USE IN LKardex
	USE IN lTransac
	USE IN lproducto
	RETURN
ENDIF

WAIT WINDOW NOWAIT "Seleccionando registros... espere un momento!!"

SELECT LKardex.fechatrans, LKardex.idtransac, lTransac.numref, ;
	lproducto.nombprod, LKardex.cantart, LKardex.preciounit, ;
	LKardex.Costounit, lproducto.unidexist, lproducto.costopro, ;
	lproducto.bodega, lproducto.unidadmed, lproducto.unidmeduni, ;
	lproducto.idproducto, lproducto.unidades ;
	FROM LKardex, lproducto, lTransac ;
	WHERE LKardex.idtransac>=cTipoDesde AND LKardex.idtransac<=cTipoHasta AND LKardex.idproducto=lproducto.idproducto AND ;
	LKardex.numtrans=lTransac.numtrans ;
	ORDER BY nombprod, LKardex.fechatrans ;
	INTO CURSOR cLismovim

SELECT cLismovim

DO CASE
	*-- ENVIAR A LA IMPRESORA
CASE saldos.eleccion=1

	DO CASE
		*-- Filtrar por Fecha, Producto y Tipo de Documento
	CASE saldos.OptFecha.value=1 AND saldos.OptNombre.value=1 AND saldos.OptTipo.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND ;
				fechatrans<=saldos.hasta AND ;
				nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
				idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
					idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR fechatrans<=saldos.hasta AND nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
						idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT
				ELSE
					REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
						idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT
				ENDIF
			ENDIF
		ENDIF

		*-- Filtrar por Fecha y Producto
	CASE saldos.OptFecha.value=1 AND saldos.OptNombre.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND ;
				fechatrans<=saldos.hasta AND ;
				nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta TO PRINTER NOCONSOLE NOEJECT
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta TO PRINTER NOCONSOLE NOEJECT
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND fechatrans<=saldos.hasta TO PRINTER NOCONSOLE NOEJECT
				ELSE
					REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND fechatrans>=saldos.desde TO PRINTER NOCONSOLE NOEJECT
				ENDIF
			ENDIF
		ENDIF

		*-- Filtrar por Fecha y Tipo
	CASE saldos.OptFecha.value=1 AND saldos.OptTipo.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND ;
				fechatrans<=saldos.hasta AND ;
				idtransac>=cTipoDesde AND idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta AND fechatrans<=saldos.hasta TO PRINTER NOCONSOLE NOEJECT
				ELSE
					REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta AND fechatrans>=saldos.desde TO PRINTER NOCONSOLE NOEJECT
				ENDIF
			ENDIF
		ENDIF

		*-- Filtrar por Tipo y Nombre del Producto
	CASE saldos.OptNombre.value=1 AND saldos.OptTipo.value=1
		REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND ;
			idtransac>=cTipoDesde AND idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT


		*-- Por nombre del Producto
	CASE saldos.OptNombre.value=1
		REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta TO PRINTER NOCONSOLE NOEJECT

		*-- Por Tipo de Documento
	CASE saldos.OptTipo.value=1
		REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta TO PRINTER NOCONSOLE NOEJECT

	CASE saldos.OptFecha.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND fechatrans<=saldos.hasta TO PRINTER NOCONSOLE NOEJECT
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX TO PRINTER NOCONSOLE NOEJECT
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR fechatrans<=saldos.hasta TO PRINTER NOCONSOLE NOEJECT
				ELSE
					REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde TO PRINTER NOCONSOLE NOEJECT
				ENDIF
			ENDIF
		ENDIF
	OTHERWISE
		REPORT form &dirreport\KARDEX TO PRINTER NOCONSOLE NOEJECT
	ENDCASE


	*-- PRESENTACION PRELIMINAR
CASE saldos.eleccion=2
	DO CASE
		*-- Filtrar por Fecha, Producto y Tipo de Documento
	CASE saldos.OptFecha.value=1 AND saldos.OptNombre.value=1 AND saldos.OptTipo.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND ;
				fechatrans<=saldos.hasta AND ;
				nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
				idtransac<=cTipoHasta PREVIEW
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
					idtransac<=cTipoHasta PREVIEW
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR fechatrans<=saldos.hasta AND nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
						idtransac<=cTipoHasta PREVIEW
				ELSE
					REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND idtransac>=cTipoDesde AND ;
						idtransac<=cTipoHasta PREVIEW
				ENDIF
			ENDIF
		ENDIF

		*-- Filtrar por Fecha y Nombre del Producto
	CASE saldos.OptFecha.value=1 AND saldos.OptNombre.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND ;
				fechatrans<=saldos.hasta AND ;
				nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta PREVIEW
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta PREVIEW
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND fechatrans<=saldos.hasta PREVIEW
				ELSE
					REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND fechatrans>=saldos.desde PREVIEW
				ENDIF
			ENDIF
		ENDIF

		*-- Filtrar por Fecha y Tipo
	CASE saldos.OptFecha.value=1 AND saldos.OptTipo.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND ;
				fechatrans<=saldos.hasta AND ;
				idtransac>=cTipoDesde AND idtransac<=cTipoHasta PREVIEW
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta PREVIEW
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta AND fechatrans<=saldos.hasta PREVIEW
				ELSE
					REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta AND fechatrans>=saldos.desde PREVIEW
				ENDIF
			ENDIF
		ENDIF

		*-- Filtrar por Tipo y Producto
	CASE saldos.OptNombre.value=1 AND saldos.OptTipo.value=1
		REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta AND ;
			idtransac>=cTipoDesde AND idtransac<=cTipoHasta PREVIEW

		*-- Por nombre del producto
	CASE saldos.OptNombre.value=1
		REPORT form &dirreport\KARDEX FOR nombprod>=saldos.proddesde AND nombprod<=saldos.prodhasta PREVIEW

		*-- Por Tipo de Documento
	CASE saldos.OptTipo.value=1
		REPORT form &dirreport\KARDEX FOR idtransac>=cTipoDesde AND idtransac<=cTipoHasta PREVIEW

	CASE saldos.OptFecha.value=1
		IF !EMPTY(saldos.desde) AND !EMPTY(saldos.hasta)
			REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde AND fechatrans<=saldos.hasta PREVIEW
		ELSE
			IF EMPTY(saldos.desde) AND EMPTY(saldos.hasta)
				REPORT form &dirreport\KARDEX PREVIEW
			ELSE
				IF EMPTY(saldos.desde)
					REPORT form &dirreport\KARDEX FOR fechatrans<=saldos.hasta PREVIEW
				ELSE
					REPORT form &dirreport\KARDEX FOR fechatrans>=saldos.desde PREVIEW
				ENDIF
			ENDIF
		ENDIF
	OTHERWISE
		REPORT form &dirreport\KARDEX PREVIEW
	ENDCASE
ENDCASE
saldos = .NULL.
USE IN LKardex
USE IN lTransac
USE IN cLismovim
USE IN lproducto
