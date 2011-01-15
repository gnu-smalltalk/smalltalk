"======================================================================
|
|   Smalltalk Gtk+ bindings (loading script).
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


Eval [
    GTK import: GLib
]


Object subclass: Pango [
    
    <category: 'Gtk'>
    <comment: nil>
]



Object subclass: Gdk [
    
    <category: 'Gtk'>
    <comment: nil>
]



Object subclass: Gtk [
    
    <category: 'Gtk'>
    <comment: nil>
]



Object subclass: Atk [
    
    <category: 'Gtk'>
    <comment: nil>
]



CObject subclass: GdkEvent [
    
    <shape: #word>
    <category: 'Gtk'>
    <comment: nil>
]
