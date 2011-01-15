"======================================================================
|
|   Smalltalk Gtk+ bindings examples
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2009 Free Software Foundation, Inc.
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


PackageLoader fileInPackage: 'GTK'.


Namespace current: GTK [

Object subclass: AspectFrameExample [
    
    <category: nil>
    <comment: nil>

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    open [
	<category: 'layout'>
	| window aspectFrame drawingArea |
	window := GtkWindow new: Gtk gtkWindowToplevel.
	window 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	window setTitle: 'Aspect Frame'.
	window setBorderWidth: 10.
	aspectFrame := GtkAspectFrame 
		    new: '2x1'
		    xalign: 0.5
		    yalign: 0.5
		    ratio: 2
		    obeyChild: false.
	window add: aspectFrame.

	"We ask for a 200x200 drawing area, but we are forcing a 2x1 ratio so
	 the AspectFrame will give us a 200x100 area."
	drawingArea := GtkDrawingArea new.
	drawingArea setSizeRequest: 200 height: 200.
	aspectFrame add: drawingArea.
	drawingArea show.
	aspectFrame show.
	window show
    ]
]

]



Namespace current: GTK [
    AspectFrameExample new open.
    Gtk main
]

