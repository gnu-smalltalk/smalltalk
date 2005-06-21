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
Gtk class
	defineAsyncCFunc: 'gstGtkMainIteration'
	withSelectorArgs: 'mainIteration'
	args: #( )!

Gtk class
	defineAsyncCFunc: 'gstGtkMainIterationDo'
	withSelectorArgs: 'mainIterationDo: blocking'
	args: #( #boolean )!

Gtk class
	defineAsyncCFunc: 'gstGtkMain'
	withSelectorArgs: 'main: aSemaphore'
	args: #( #smalltalk )!

Gtk class
	defineCFunc: 'gstGtkShouldQuit'
	withSelectorArgs: 'shouldQuit'
	returning: #boolean
	args: #( )!



GLib class
	defineCFunc: 'gstGtkRegisterForType'
	withSelectorArgs: 'register: anObject forType: gType'
	returning: #void
	args: #( #smalltalk #unknown )!

Gtk class defineCFunc: 'gstGtkInit'
        withSelectorArgs: 'gstGtkInit'
        returning: #void
        args: #()!

GObject
	defineCFunc: 'gstGtkConnectSignal'
	withSelectorArgs: 'connectSignal: name to: handler selector: sel userData: userData'
	returning: #void
	args: #( #selfSmalltalk #string #smalltalk #smalltalk #smalltalk )!

GObject
	defineCFunc: 'gstGtkNarrowGObjectOOP'
	withSelectorArgs: 'narrow'
	returning: #smalltalk
	args: #(#self #selfSmalltalk)!

GObject
	defineCFunc: 'gstGtkFreeGObjectOOP'
	withSelectorArgs: 'free'
	returning: #void
	args: #(#self)!

GObject
	defineCFunc: 'gstGtkGetProperty'
	withSelectorArgs: 'propertiesAt: name'
	returning: #smalltalk
	args: #( #self #string )!

GObject
	defineCFunc: 'gstGtkSetProperty'
	withSelectorArgs: 'propertiesAt: name put: anObject'
	returning: #void
	args: #( #self #string #smalltalk )!

GtkWidget
	defineCFunc: 'gstGtkGetWindow'
	withSelectorArgs: 'getWindow'
	returning: GdkWindow type
	args: #( #self )!

GtkWidget
	defineCFunc: 'gstGtkGetState'
	withSelectorArgs: 'getState'
	returning: #int
	args: #( #self )!

GtkWidget
	defineCFunc: 'gstGtkGetFlags'
	withSelectorArgs: 'getFlags'
	returning: #int
	args: #( #self )!

GtkWidget
	defineCFunc: 'gstGtkSetFlags'
	withSelectorArgs: 'setFlags: flags'
	returning: #void
	args: #( #self #int )!

GtkWidget
	defineCFunc: 'gstGtkUnsetFlags'
	withSelectorArgs: 'unsetFlags: flags'
	returning: #void
	args: #( #self #int )!

GtkContainer
	defineCFunc: 'gstGtkGetChildProperty'
	withSelectorArgs: 'child: widget propertiesAt: name'
	returning: #smalltalk
	args: #( #self #cObject #string )!

GtkContainer
	defineCFunc: 'gstGtkSetChildProperty'
	withSelectorArgs: 'child: widget propertiesAt: name put: anObject'
	returning: #void
	args: #( #self #cObject #string #smalltalk )!

GtkTreeStore superclass: GtkTreeModel!

GtkListStore superclass: GtkTreeModel!

GValue class
	defineCFunc: 'g_type_from_name'
	withSelectorArgs: 'typeFromName: aName'
	returning: #int
	args: #( #string )!

GtkTreeModel 
	defineCFunc: 'gstGtkTreeModelGetOOP'
	withSelectorArgs: 'getOop: iter column: aColumn'
	returning: #smalltalk
	args: #( #self #cObject #int )!

GtkTreeStore
	defineCFunc: 'gstGtkTreeStoreSetOOP'
	withSelectorArgs: 'setOop: iter column: aColumn value: aValue'
	returning: #void
	args: #( #self #cObject #int #smalltalk)!

GtkListStore
	defineCFunc: 'gstGtkListStoreSetOOP'
	withSelectorArgs: 'setOop: iter column: aColumn value: aValue'
	returning: #void
	args: #( #self #cObject #int #smalltalk )!

GtkWidget
	defineCFunc: 'gstGtkWidgetGetAllocation'
	withSelectorArgs: 'getAllocation'
	returning: GtkAllocation type
	args: #( #self )!

GtkDialog
	defineCFunc: 'gstGtkDialogGetVBox'
	withSelectorArgs: 'getVBox'
	returning: GtkWidget type
	args: #( #self )!

GtkDialog
	defineCFunc: 'gstGtkDialogGetActionArea'
	withSelectorArgs: 'getActionArea'
	returning: GtkWidget type
	args: #( #self )!

GtkScrolledWindow
	defineCFunc: 'gstGtkGetHscrollbarVisible'
	withSelectorArgs: 'getHscrollbarVisible'
	returning: #boolean
	args: #( #self )!

GtkScrolledWindow
	defineCFunc: 'gstGtkGetVscrollbarVisible'
	withSelectorArgs: 'getVscrollbarVisible'
	returning: #boolean
	args: #( #self )!

GtkAdjustment
	defineCFunc: 'gstGtkAdjustmentGetLower'
	withSelectorArgs: 'getLower'
	returning: #int
	args: #( #self )!

GtkAdjustment
	defineCFunc: 'gstGtkAdjustmentGetUpper'
	withSelectorArgs: 'getUpper'
	returning: #int
	args: #( #self )!

GtkAdjustment
	defineCFunc: 'gstGtkAdjustmentGetPageSize'
	withSelectorArgs: 'getPageSize'
	returning: #int
	args: #( #self )!

GdkPixbufLoader
        "FIXME: funcs.awk is broken for this."
	defineCFunc: 'gdk_pixbuf_loader_write'
	withSelectorArgs: 'write: buf count: count error: error'
	returning: #boolean
	args: #( #self #byteArray #int #cObject )!

	
