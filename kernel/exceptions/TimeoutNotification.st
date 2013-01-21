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



Namespace current: Kernel [

Notification subclass: TimeoutNotification [
    | delay |
    <category: 'Language-Implementation'>
    <comment: 'I get send by the timeout handling of a Delay
and I am the indication that the time is up and that one should come
to an end.'>

    TimeoutNotification class >> on: aDelay [
        <category: 'creation'>
        ^ self new
            delay: aDelay; yourself
    ]

    delay: aDelay [
        <category: 'private'>
        delay := aDelay
    ]

    delay [
        <category: 'private'>
        ^ delay
    ]

    isResumable [
        <category: 'private'>
        ^ false
    ]

    defaultAction [
	"We are not resumable, so do nothing.  This should really never happen."

	<category: 'exception description'>
    ]
]

]

