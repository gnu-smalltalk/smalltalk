"======================================================================
|
|   Smalltalk Gtk+ bindings (functions in gst-gtk.c)
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

"These differ from the standard implementation in that they run
 until all events are done.  We also need to redefine them so that
 they are asynchronous"

!Gtk class methodsFor: 'C call-outs'!

mainIteration
    <asyncCCall: 'gstGtkMainIteration' args: #()>!

mainIterationDo: blocking
    <asyncCCall: 'gstGtkMainIterationDo' args: #(#boolean )>!

main: aSemaphore
    <asyncCCall: 'gstGtkMain' args: #(#smalltalk )>!

shouldQuit
    <cCall: 'gstGtkShouldQuit' returning: #boolean args: #()>!

gstGtkInit
    <cCall: 'gstGtkInit' returning: #void args: #()>! !

!GLib class methodsFor: 'C call-outs'!

register: anObject forType: gType
    <cCall: 'gstGtkRegisterForType' returning: #void
	args: #(#smalltalk #unknown )>!

!GObject methodsFor: 'C call-outs'!

connectSignal: name to: handler selector: sel userData: userData
    <cCall: 'gstGtkConnectSignal' returning: #void
	args: #(#selfSmalltalk #string #smalltalk #smalltalk #smalltalk )>!

narrow
    <cCall: 'gstGtkNarrowGObjectOOP' returning: #smalltalk
	args: #(#self #selfSmalltalk )>!

free
    <cCall: 'gstGtkFreeGObjectOOP' returning: #void args: #(#self )>!

propertiesAt: name
    <cCall: 'gstGtkGetProperty' returning: #smalltalk args: #(#self #string )>!

propertiesAt: name put: anObject
    <cCall: 'gstGtkSetProperty' returning: #void
	args: #(#self #string #smalltalk )>! !

!GtkWidget methodsFor: 'C call-outs'!

getAllocation
    <cCall: 'gstGtkWidgetGetAllocation' returning: GtkAllocation type
	args: #(#self )>!

getWindow
    <cCall: 'gstGtkGetWindow' returning: GdkWindow type args: #(#self )>!

getState
    <cCall: 'gstGtkGetState' returning: #int args: #(#self )>!

getFlags
    <cCall: 'gstGtkGetFlags' returning: #int args: #(#self )>!

setFlags: flags
    <cCall: 'gstGtkSetFlags' returning: #void args: #(#self #int )>!

unsetFlags: flags
    <cCall: 'gstGtkUnsetFlags' returning: #void args: #(#self #int )>! !

!GtkContainer methodsFor: 'C call-outs'!

child: widget propertiesAt: name
    <cCall: 'gstGtkGetChildProperty' returning: #smalltalk
	args: #(#self #cObject #string )>!

child: widget propertiesAt: name put: anObject
    <cCall: 'gstGtkSetChildProperty' returning: #void
	args: #(#self #cObject #string #smalltalk )>! !

!GValue class methodsFor: 'C call-outs'!

typeFromName: aName
    <cCall: 'g_type_from_name' returning: #int args: #(#string )>!

!GtkTreeModel methodsFor: 'C call-outs'!

getOop: iter column: aColumn
    <cCall: 'gstGtkTreeModelGetOOP' returning: #smalltalk
	args: #(#self #cObject #int )>!

!GtkTreeStore methodsFor: 'C call-outs'!

setOop: iter column: aColumn value: aValue
    <cCall: 'gstGtkTreeStoreSetOOP' returning: #void
	args: #(#self #cObject #int #smalltalk )>!

!GtkListStore methodsFor: 'C call-outs'!

setOop: iter column: aColumn value: aValue
    <cCall: 'gstGtkListStoreSetOOP' returning: #void
	args: #(#self #cObject #int #smalltalk )>!

!GtkDialog methodsFor: 'C call-outs'!

getVBox
    <cCall: 'gstGtkDialogGetVBox' returning: GtkWidget type args: #(#self )>!

getActionArea
    <cCall: 'gstGtkDialogGetActionArea' returning: GtkWidget type
	args: #(#self )>! !

!GtkScrolledWindow methodsFor: 'C call-outs'!

getHscrollbarVisible
    <cCall: 'gstGtkGetHscrollbarVisible' returning: #boolean args: #(#self )>!

getVscrollbarVisible
    <cCall: 'gstGtkGetVscrollbarVisible' returning: #boolean args: #(#self )>! !

!GtkAdjustment methodsFor: 'C call-outs'!

getLower
    <cCall: 'gstGtkAdjustmentGetLower' returning: #int args: #(#self )>!

getUpper
    <cCall: 'gstGtkAdjustmentGetUpper' returning: #int args: #(#self )>!

getPageSize
    <cCall: 'gstGtkAdjustmentGetPageSize' returning: #int args: #(#self )>! !

!GdkPixbufLoader methodsFor: 'C call-outs'!

write: buf count: count error: error
    "FIXME: funcs.awk is broken for this."
    <cCall: 'gdk_pixbuf_loader_write' returning: #boolean
	args: #(#self #byteArray #int #cObject )>! !

GtkTreeStore superclass: GtkTreeModel!
GtkListStore superclass: GtkTreeModel!
