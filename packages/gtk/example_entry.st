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

Object subclass: EntryExample [
    | entry window |
    
    <category: nil>
    <comment: nil>

    activate: object data: data [
	<category: 'event handling'>
	entry getText displayNl
    ]

    clicked: object data: data [
	<category: 'event handling'>
	window destroy
    ]

    toggled: object data: selector [
	<category: 'event handling'>
	entry perform: selector with: object getActive
    ]

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    delete: object event: event data: data [
	<category: 'event handling'>
	window destroy
    ]

    open [
	<category: 'layout'>
	| vbox hbox button check pos |
	window := GtkWindow new: Gtk gtkWindowToplevel.
	window setSizeRequest: 200 height: 100.
	window setTitle: 'GTK Entry'.
	window 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	window 
	    connectSignal: 'delete_event'
	    to: self
	    selector: #delete:event:data:
	    userData: nil.
	vbox := GtkVBox new: false spacing: 0.
	window add: vbox.
	vbox show.
	entry := GtkEntry new.
	entry setMaxLength: 50.
	entry 
	    connectSignal: 'activate'
	    to: self
	    selector: #activate:data:
	    userData: nil.
	entry setText: 'hello'.

	"This function needs an int* as the last parameter."
	entry 
	    insertText: ' world'
	    newTextLength: -1
	    position: (CInt gcValue: entry getText size).
	entry selectRegion: 0 endPos: entry getText size.
	vbox 
	    packStart: entry
	    expand: true
	    fill: true
	    padding: 0.
	entry show.
	hbox := GtkHBox new: false spacing: 0.
	vbox add: hbox.
	hbox show.
	check := GtkCheckButton newWithLabel: 'Editable'.
	hbox 
	    packStart: check
	    expand: true
	    fill: true
	    padding: 0.
	check 
	    connectSignal: 'toggled'
	    to: self
	    selector: #toggled:data:
	    userData: #setEditable:.
	check setActive: true.
	check show.
	check := GtkCheckButton newWithLabel: 'Visible'.
	hbox 
	    packStart: check
	    expand: true
	    fill: true
	    padding: 0.
	check 
	    connectSignal: 'toggled'
	    to: self
	    selector: #toggled:data:
	    userData: #setVisibility:.
	check setActive: true.
	check show.
	button := GtkButton newFromStock: 'gtk-close'.
	button 
	    connectSignal: 'clicked'
	    to: self
	    selector: #clicked:data:
	    userData: nil.
	vbox 
	    packStart: button
	    expand: true
	    fill: true
	    padding: 0.
	button setFlags: Gtk gtkCanDefault.
	button grabDefault.
	button show.
	window show
    ]
]

]



Namespace current: GTK [
    EntryExample new open.
    Gtk main
]

