"======================================================================
|
|   Smalltalk Gtk+ bindings (declarations of some CStructs needing fields)
|
 ======================================================================"


"======================================================================
|
| Copyright 2004 Free Software Foundation, Inc.
| Written by Robert Collins.
|
| This file is part of the GNU Smalltalk class library.
| It contains manual struct definitions the automatic logic fails to create
|
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

CStruct subclass: #GTypeClass
    "FIXME autogen"
    declaration: #(
    (#g_type #uLong)
    )
   classVariableNames: ''
   poolDictionaries: ''
   category: 'GTK'
   !

CObject variableWordSubclass: #GtkTreeModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gtk'!


"FIXME: passing #cObjectPtr should be smarter or something"
CStruct subclass: #GtkTreeModelPointer
  declaration: #(
  (#model (#ptr #GtkTreeModel))
  )
  classVariableNames: ''
  poolDictionaries: ''
  category: 'GTK'
  !

CStruct subclass: #GtkRequisition
  declaration: #(
  (#width #int)
  (#height #int)
  )
  classVariableNames: ''
  poolDictionaries: ''
  category: 'GTK'
  !

CStruct subclass: #GSList
  declaration: #(
    (#data (#ptr #CObject))
    (#next (#ptr #GSList))
  )
  classVariableNames: ''
  poolDictionaries: ''
  category: 'GTK'
  !

"FIXME more events needed"
CStruct subclass: #GdkEventButton
  declaration: #(
    (#type #uint)
    (#window (#ptr #CObject))
    (#sendEvent #byte)
    (#time #uint)
    (#x #double)
    (#y #double)
    (#axes (#ptr #double))
    (#state #uint)
    (#button #uint)
    (#device (#ptr #CObject))
    (#xRoot #double)
    (#yRoot #double))
  classVariableNames: ''
  poolDictionaries: ''
  category: 'GTK'!

CStruct subclass: #GdkEventMotion
  declaration: #(
    (#type #uint)
    (#window (#ptr #CObject))
    (#sendEvent #byte)
    (#time #uint)
    (#x #double)
    (#y #double)
    (#axes (#ptr #double))
    (#state #uint)
    (#isHint #short)
    (#device (#ptr #CObject))
    (#xRoot #double)
    (#yRoot #double))
  classVariableNames: ''
  poolDictionaries: ''
  category: 'GTK'!

CStruct subclass: #GdkEventConfigure
  declaration: #(
    (#type #uint)
    (#window (#ptr #CObject))
    (#sendEvent #byte)
    (#x #int)
    (#y #int)
    (#width #int)
    (#height #int))
  classVariableNames: ''
  poolDictionaries: ''
  category: 'GTK'!
