"======================================================================
|
|   Delimited continuations Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
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



BlockClosure extend [
    "MetaContinuation := Kernel.ProcessVariable key: Object new."
    MetaContinuation := ValueHolder new.

    BlockClosure class >> continueWith: anObject [
	"Pass anObject to the metacontinuation."
	| mc |
	mc := MetaContinuation value.
	mc isNil ifTrue: [ self error: 'you forgot the top-level reset...' ].
	mc value: anObject
    ]

    BlockClosure class >> continueAt: cc [
	"Set the metacontinuation to one that restores the old value and
	 restarts cc."
	| mc |
	mc := MetaContinuation value.
	MetaContinuation value: [ :v |
	    MetaContinuation value: mc.
	    cc value: v ].
    ]

    reset [
	^Continuation escapeDo: [ :cc |
	    BlockClosure
	        "Make the metacontinuation pass the result to the invoker
	         of reset, until it is invoked."
		continueAt: cc;

		"Pass the result to the metacontinuation.  The
		 metacontinuation restores the outer metacontinuation, and
		 binds the result by continuing on cc."
		continueWith: self value ]
    ]

    shift [
	^Continuation escapeDo: [ :cc |
	    | escape |
	    "In order to escape, we obviously have to pass v to the
	     continuation cc.  However, because this discards the
	     rest of the `shifted' block, we protect it with reset."
	    escape := [ :v | [cc value: v] reset ].
	
	    BlockClosure continueWith: (self cull: escape) ]
    ]
]
