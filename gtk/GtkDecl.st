"======================================================================
|
|   Smalltalk Gtk+ bindings (loading script).
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

Object subclass: #Pango
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

Object subclass: #Gdk
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

Object subclass: #Gnome
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gnome'!

Object subclass: #GnomeVFS
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gnome'!

Object subclass: #Gtk
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

Object subclass: #Atk
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

Object subclass: #GLib
	instanceVariableNames: ''
	classVariableNames: 'GtkTypes'
	poolDictionaries: ''
	category: 'Gtk'!

Object subclass: #GQuark
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

CObject variableWordSubclass: #GList
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

CObject variableWordSubclass: #GSList
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

CObject variableWordSubclass: #GdkEvent
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

FileStream fileIn: 'Libs.st'!
FileStream fileIn: 'Types.st'!
FileStream fileIn: 'Structs.st'!
FileStream fileIn: 'MoreStructs.st'!
FileStream fileIn: 'Enums.st'!
FileStream fileIn: 'Funcs.st'!
FileStream fileIn: 'MoreFuncs.st'!
FileStream fileIn: 'GtkImpl.st'!

GLib registerAllTypes!
