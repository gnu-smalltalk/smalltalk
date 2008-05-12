"======================================================================
|
|   Case syntax for Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Written by Ulf Dambacher.
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

Object subclass: #Case
	  instanceVariableNames: 'test found result'
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Examples-Useful tools'
!

Case comment:
'A nice class for switch-like tests. Slower than cascaded ifs but clearer.
#case:do: uses identity for testing (useful since you''ll likely use Case
with symbols, integers, characters, and the like), #ifEqualTo:do: uses
equality.

e.g.

Case new test: myObject;
    case: 5				   do: [ ''got five''	    printNl ];
    when: [ :testVal | testVal isInteger ] do: [ ''an integer''     printNl ];
    else: 				       [ :testVal | testVal printNl ]

You can use (Case test: myObject) instead of the first line above. Which of
the two possibilities is clearer, it is a matter of taste.'!

!Case class methodsFor: 'instance creation'!

test: anObject
    ^self new test: anObject
! !

!Case methodsFor: 'testing'!

test: anObject
    test := anObject.
    found := false.
!

reset
    found := false
!

else: aBlock
    ^found
	ifFalse: [ self do: aBlock ]
	ifTrue: [ result ].
!

case: anObject do: aBlock
    ^(found not and: [test == anObject])
	ifTrue: [ self do: aBlock ]
	ifFalse: [ result ].
!

ifEqualTo: anObject do: aBlock
    ^(found not and: [test = anObject])
	ifTrue: [ self do: aBlock ]
	ifFalse: [ result ].
!

when: aBlock do: aBlock2
    ^(found not and: [aBlock value: test])
	ifTrue: [ self do: aBlock ]
	ifFalse: [ result ].
! !

!Case methodsFor: 'private'!

do: aBlock
    found := true.
    ^result := (aBlock cull: test)
! !


Object subclass: #Switch
	  instanceVariableNames: 'values defaultBlock'
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Examples-Useful tools'
!

Object subclass: #SwitchCase
	  instanceVariableNames: 'secondParameter evaluationBlock actionBlock result'
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Examples-Useful tools'
!

Switch comment:
'Another class for switch-like tests.  This is reusable, i.e. an instance
stores its case-do pairs.

e.g.

(Switch new)
    case: "value or Block" do: [...];
    ...
    default: [...];
    on: value.         "#= equality matching of cases"

(Switch new)
    case: "value or Block" do: [...];
    ...
    default: [...];
    exactlyOn: value.  "#== identity matching of cases"
'!

!Switch class methodsFor: 'instance creation'!

new
    ^self basicNew values: (ReadWriteStream on: Array new: 5)
! !

!Switch methodsFor: 'initialization'!

values: aStream
    values := aStream
!

default: aBlock
    defaultBlock := aBlock
!

case: anObjectOrBlock do: aBlock
    | block |
    block := anObjectOrBlock class == BlockClosure
	ifTrue: [
	    [ :object :block :identity | block value: object ]
	ifFalse: [
	    [ :object :comparison :identity |
		identity
		    ifTrue: [ object == comparison ]
		    ifFalse: [ object = comparison ]
	    ]
    ].
    values nextPut: (SwitchCase new
	secondParameter: anObjectOrBlock
	evaluationBlock: block
	actionBlock: aBlock)
! !

!Switch methodsFor: 'evaluation'!

on: anObject
    | done case |
    done := false.
    values reset.
    [ values atEnd ] whileFalse: [
	case := values next.
	(case evaluateIfEqualTo: anObject) ifTrue: [ ^case result ].
    ].
    ^defaultBlock value! !

exactlyOn: anObject
    | done case |
    done := false.
    values reset.
    [ values atEnd ] whileFalse: [
	case := values next.
	(case evaluateIfIdenticalTo: anObject) ifTrue: [ ^case result ].
    ].
    ^defaultBlock value! !

identityOn: anObject
    | done case |
    done := false.
    values reset.
    [ values atEnd ] whileFalse: [
	case := values next.
	(case evaluateIfIdenticalTo: anObject) ifTrue: [ ^case result ].
    ].
    ^defaultBlock value! !

!SwitchCase methodsFor: 'evaluation'!

evaluateIfEqualTo: object
    ^(evaluationBlock value: object value: secondParameter value: false)
	ifTrue: [ result := actionBlock value ];
	yourself
!

evaluateIfIdenticalTo: object
    ^(evaluationBlock value: object value: secondParameter value: true)
	ifTrue: [ result := actionBlock value ];
	yourself
!

result
    | answer |
    answer := result.
    result := nil.
    ^answer
! !

!SwitchCase methodsFor: 'initialization'!

secondParameter: sP evaluationBlock: eB actionBlock: aB
    secondParameter := sP.
    evaluationBlock := eB.
    actionBlock := aB
! !

