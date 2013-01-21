"======================================================================
|
|   ANSI exception handling classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Exception subclass: Notification [
    
    <category: 'Language-Exceptions'>
    <comment: 'Notification represents a resumable, exceptional yet non-erroneous,
situation.  Signaling a notification in absence of an handler simply
returns nil.'>

    description [
	"Answer a textual description of the exception."

	<category: 'exception description'>
	^'An exceptional condition has occurred, but it is not to be considered
an error.'
    ]

    isResumable [
	"Answer true.  Notification exceptions are by default resumable."

	<category: 'exception description'>
	^true
    ]

    defaultAction [
	"Do the default action for notifications, which is to resume execution
	 of the context which signaled the exception."

	<category: 'exception description'>
	self resume: nil
    ]
]
