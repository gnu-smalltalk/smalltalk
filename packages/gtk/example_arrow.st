"======================================================================
|
|   Smalltalk Gtk+ bindings examples
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2008, 2009 Free Software Foundation, Inc.
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

Object subclass: ArrowExample [
    
    <category: nil>
    <comment: nil>

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    open [
	<category: 'layout'>
	| window button box |
	window := GtkWindow new: Gtk gtkWindowToplevel.
	window setTitle: 'Arrow Buttons'.
	window 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	window setBorderWidth: 10.
	box := GtkHBox new: false spacing: 0.
	box setBorderWidth: 2.
	window add: box.
	button := GtkButton createArrowButton: Gtk gtkArrowUp
		    shadowType: Gtk gtkShadowIn.
	box 
	    packStart: button
	    expand: false
	    fill: false
	    padding: 3.
	button := GtkButton createArrowButton: Gtk gtkArrowDown
		    shadowType: Gtk gtkShadowOut.
	box 
	    packStart: button
	    expand: false
	    fill: false
	    padding: 3.
	button := GtkButton createArrowButton: Gtk gtkArrowLeft
		    shadowType: Gtk gtkShadowEtchedIn.
	box 
	    packStart: button
	    expand: false
	    fill: false
	    padding: 3.
	button := GtkButton createArrowButton: Gtk gtkArrowRight
		    shadowType: Gtk gtkShadowEtchedOut.
	box 
	    packStart: button
	    expand: false
	    fill: false
	    padding: 3.
	box show.
	window show
    ]
]

]



GTK.GtkButton class extend [

    createArrowButton: arrowType shadowType: shadowType [
	<category: 'creating arrow buttons'>
	| button arrow |
	button := self new.
	arrow := GtkArrow new: arrowType shadowType: shadowType.
	button add: arrow.
	button show.
	arrow show.
	^button
    ]

]



Namespace current: GTK [
    ArrowExample new open.
    Gtk main
]

