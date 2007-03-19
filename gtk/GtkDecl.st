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
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!

GLib class
	instanceVariableNames: 'gtkTypes'!

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

!GLib class methodsFor: 'registering GObject types'!

registerAllTypes
    gtkTypes isNil ifTrue: [ gtkTypes := OrderedCollection new ].
    gtkTypes do: [ :each | self register: each forType: each getType ]
!

registerType: aClass
    gtkTypes isNil ifTrue: [ gtkTypes := OrderedCollection new ].
    gtkTypes addLast: aClass
!

update: anObject
    anObject == #returnFromSnapshot
        ifTrue: [ self registerAllTypes ]
! !

ObjectMemory addDependent: GLib!
