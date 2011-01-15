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

Object subclass: HelloWorldExample [
    
    <category: nil>
    <comment: nil>

    clicked: widget data: data [
	<category: 'event handling'>
	data displayNl
    ]

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    open [
	<category: 'layout'>
	| w b l |
	w := GtkWindow new: Gtk gtkWindowToplevel.
	b := GtkButton new.
	l := GtkLabel 
		    new: '
                Push me and watch stdout!                ' , '
'.
	w add: b.
	b add: l.
	b show.
	l show.
	w setTitle: 'GTK+ bindings demo'.
	b 
	    connectSignal: 'clicked'
	    to: self
	    selector: #clicked:data:
	    userData: 'Hello, world!'.
	w 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	w show
    ]
]

]



Namespace current: GTK [
    HelloWorldExample new open.
    Gtk main
]

