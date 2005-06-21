"======================================================================
|
|   Smalltalk Gtk+ bindings (GType database)
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

!GLib class methodsFor: 'registering GObject types'!

registerAllTypes
    GtkTypes isNil ifTrue: [ GtkTypes := OrderedCollection new ].
    GtkTypes do: [ :each | self register: each forType: each getType ]
!

registerType: aClass
    GtkTypes isNil ifTrue: [ GtkTypes := OrderedCollection new ].
    GtkTypes addLast: aClass
!

update: anObject
    anObject == #returnFromSnapshot
        ifTrue: [ self registerAllTypes ]
! !

ObjectMemory addDependent: GLib!
