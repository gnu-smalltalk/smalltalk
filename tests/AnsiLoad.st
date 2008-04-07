"======================================================================
|
|   Loader for the ANSI-compliancy tests
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2000  Free Software Foundation.
| Written by Paolo Bonzini
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Smalltalk classAt: #Compiler ifAbsent: [
	Object subclass: #Compiler
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: nil
]!

!Compiler class
	methodsFor: 'evaluation'
	ifTrue: (Compiler respondsTo: #evaluate:) not!

evaluate: aBlock
    ^Behavior evaluate: aBlock! !

"-----------------------------------------------------------------"

!Object methodsFor: 'handle #isSomeClass'!

doesNotUnderstand: aMessage
    | class |
    class := nil.
    aMessage selector size > 3 ifTrue: [
	(aMessage selector copyFrom: 1 to: 2) = 'is' ifTrue: [
	    class := Smalltalk
		classAt: (aMessage selector copyFrom: 3)
		ifAbsent: [ nil ]
	]
    ].

    class notNil ifTrue: [ ^self class == class ].
    MessageNotUnderstood new
	message: aMessage receiver: self;
	tag: self;
	signal
! !

"Test the machinery above"
Set new isSet ifFalse: [ self error: 'huh huh - a Set is not a set' ].
1234567 isSet ifTrue: [ self error: 'huh huh - everything is a set' ]!

"-----------------------------------------------------------------"

"Define ANSI required globals."
Smalltalk at: #'DateAndTime' put: (Smalltalk at: #'DateTime')! "???"

"-----------------------------------------------------------------"

PackageLoader fileInPackage: #SUnit!

| ps loaded |
FileStream verbose: true.
Directory working name indexOfSubCollection: 'tests'
	ifAbsent: [ Directory working: Directory kernel / '../tests' ].

ps := Smalltalk at: #ProtocolSpec ifAbsent: [ nil ].
loaded := (ps respondsTo: #includesProtocolNamed:)
    and: [ ps includesProtocolNamed: #Character ].

FileStream fileIn: 'Ansi.st'.

loaded ifFalse: [
    FileStream fileIn: 'AnsiDB.st'.
    FileStream fileIn: 'AnsiInit.st'.
]!

ObjectMemory snapshot!
