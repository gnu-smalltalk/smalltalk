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

Object subclass: ButtonBoxExample [
    
    <category: nil>
    <comment: nil>

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    open [
	<category: 'layout'>
	| window mainVBox hbox vbox frameHorz frameVert |
	window := GtkWindow new: Gtk gtkWindowToplevel.
	window setTitle: 'Button Boxes'.
	window 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	window setBorderWidth: 10.
	mainVBox := GtkVBox new: false spacing: 0.
	window add: mainVBox.
	frameHorz := GtkFrame new: 'Horizontal Button Boxes'.
	mainVBox 
	    packStart: frameHorz
	    expand: true
	    fill: true
	    padding: 10.
	vbox := GtkVBox new: false spacing: 0.
	vbox setBorderWidth: 10.
	frameHorz add: vbox.
	vbox 
	    packStart: (GtkHButtonBox 
		    createButtonBox: 'Spread (spacing 40)'
		    spacing: 40
		    layout: Gtk gtkButtonboxSpread)
	    expand: true
	    fill: true
	    padding: 0.
	vbox 
	    packStart: (GtkHButtonBox 
		    createButtonBox: 'Edge (spacing 30)'
		    spacing: 30
		    layout: Gtk gtkButtonboxEdge)
	    expand: true
	    fill: true
	    padding: 0.
	vbox 
	    packStart: (GtkHButtonBox 
		    createButtonBox: 'Start (spacing 20)'
		    spacing: 20
		    layout: Gtk gtkButtonboxStart)
	    expand: true
	    fill: true
	    padding: 0.
	vbox 
	    packStart: (GtkHButtonBox 
		    createButtonBox: 'End (spacing 10)'
		    spacing: 10
		    layout: Gtk gtkButtonboxEnd)
	    expand: true
	    fill: true
	    padding: 0.
	frameVert := GtkFrame new: 'Vertical Button Boxes'.
	mainVBox 
	    packStart: frameVert
	    expand: true
	    fill: true
	    padding: 10.
	hbox := GtkHBox new: false spacing: 0.
	hbox setBorderWidth: 10.
	frameVert add: hbox.
	hbox 
	    packStart: (GtkVButtonBox 
		    createButtonBox: 'Spread (spacing 5)'
		    spacing: 5
		    layout: Gtk gtkButtonboxSpread)
	    expand: true
	    fill: true
	    padding: 0.
	hbox 
	    packStart: (GtkVButtonBox 
		    createButtonBox: 'Edge (spacing 30)'
		    spacing: 30
		    layout: Gtk gtkButtonboxEdge)
	    expand: true
	    fill: true
	    padding: 0.
	hbox 
	    packStart: (GtkVButtonBox 
		    createButtonBox: 'Start (spacing 20)'
		    spacing: 20
		    layout: Gtk gtkButtonboxStart)
	    expand: true
	    fill: true
	    padding: 0.
	hbox 
	    packStart: (GtkVButtonBox 
		    createButtonBox: 'End (spacing 20)'
		    spacing: 20
		    layout: Gtk gtkButtonboxEnd)
	    expand: true
	    fill: true
	    padding: 0.
	window showAll
    ]
]

]



GTK.GtkButtonBox class extend [

    createButtonBox: title spacing: spacing layout: layout [
	<category: 'creating button boxes'>
	| box frame button |
	frame := GtkFrame new: title.

	"Note the use of polymorphism here: we are extending the Gtk binding
	 itself!  The original C example had an extra parameter to specify
	 whether to create an horizontal or vertical button box."
	box := self new.
	box setBorderWidth: 5.
	frame add: box.
	box setLayout: layout.
	box setSpacing: spacing.
	button := GtkButton newFromStock: Gtk gtkStockOk.
	box add: button.
	button := GtkButton newFromStock: Gtk gtkStockCancel.
	box add: button.
	button := GtkButton newFromStock: Gtk gtkStockHelp.
	box add: button.
	^frame
    ]

]



Namespace current: GTK [
    ButtonBoxExample new open.
    Gtk main
]

