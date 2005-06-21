"======================================================================
|
|   Compute the amount of memory and the number of instances for each
|   class in the GNU Smalltalk system.
|
|
 ======================================================================"

 
"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2002 Free Software Foundation, Inc.
| Written by Steve Byrne.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!ObjectMemory class methodsFor: 'demo'!

memoryUsage
    | t numObjs classObjs totalInstanceSize instVarSize |
    numObjs := t := 0.
    ObjectMemory compact.
    Object withAllSubclasses do: [ :class |
	class printNl.
	totalInstanceSize := classObjs := 0.
	instVarSize := class instSize.
    	(class inheritsFrom: ContextPart) ifFalse: [
	    class allInstancesDo: [ :inst |
		totalInstanceSize := totalInstanceSize +
				     ((Memory at: (ObjectMemory addressOf: inst)) * 4).
		classObjs := classObjs + 1 ] 
	    ].
						    
        Transcript nextPutAll: '  Instances: '. classObjs printNl.
	Transcript nextPutAll: '  Size: '. totalInstanceSize printNl.
	Transcript nl.
	t := t + totalInstanceSize.
	numObjs := numObjs + classObjs ].

    ^numObjs -> t
!

histogram
    | sizes size  |
    ObjectMemory compact.
    sizes := Bag new.
    Object withAllSubclasses do: [ :class |
	(class inheritsFrom: ContextPart)
	    ifFalse: [
		class allInstancesDo: [ :inst |
		    size := (Memory at: (ObjectMemory addressOf: inst)).
		    sizes add: size ] 
	    ].
    ].

    sizes printNl.
! !

ObjectMemory memoryUsage printNl!
ObjectMemory histogram printNl!
