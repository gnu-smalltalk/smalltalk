"======================================================================
|
|   Experimental Debugger (mostly obsolete)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Object subclass: #Debugger
       instanceVariableNames: 'curContext receiver method ip ipAdjust stopType'
       classVariableNames: 'Breakpoints BytecodeSelectors ReturnBlock'
       poolDictionaries: ''
       category: 'Language-Implementation'
!

Debugger comment:
'I am a rewrite for the GNU Smalltalk VM. In addition I provide a simple
breakpoint facility for GNU Smalltalk.'!


!Debugger class methodsFor: 'simulation'!

simulate: aBlockClosure
    ^self new
	initialize: (aBlockClosure asContext: nil)
	dispatchBytecodes
! !

!Debugger class methodsFor: 'lightweight classes'!

subclass: anObject
    | class |
    anObject class isClass ifFalse: [ ^anObject class ].
    class := Behavior new superclass: anObject class.
    anObject changeClassTo: class.
    ^class
!

unsubclass: anObject
    anObject class isClass
	ifFalse: [ anObject changeClassTo: anObject class superclass ].
!

breakpointOn: aSymbol for: anObject
    | method class |
    class := self subclass: anObject.
    (class includesSelector: aSymbol) ifTrue: [ ^self ].
    method := (class superclass >> aSymbol) shallowCopy.
    method breakpointAt: 1.
    class addSelector: aSymbol withMethod: method.
! !

!Debugger class methodsFor: 'breakpoints'!

recordOldByte: byte atIndex: anIndex forMethod: aMethod
    "Preserve the original byte code from a compiled method, for restoration
    after the breakpoint is removed.  The implementation does not notice if
    the compiled method is shared; so a breakpoint in a compiled method will 
    cause a break in whichever classes share this method.  This does not occur
    at all in practice, so it's probably not an issue."
    | breakpointDict |
    byte == self debugByte
	ifTrue: [ ^self ].
    breakpointDict := Breakpoints at: aMethod
				 ifAbsent: [ Dictionary new ].
    breakpointDict at: anIndex put: byte
!

origByteAt: anIndex forMethod: aMethod
    "I return the original byte code at the given index for the given method.
    If there is no breakpoint for that method at that index, I return nil."
    | breakpointDict |
    breakpointDict := Breakpoints at: aMethod
				 ifAbsent: [ ^nil ].
    ^breakpointDict at: anIndex
		    ifAbsent: [ ^nil ]
! !



!Debugger class methodsFor: 'private'!

initialize
    Breakpoints := IdentityDictionary new.

    BytecodeSelectors := #(
	#pushRecVar: 1		"bytecode 0"
	#pushRecVar: 2		"bytecode 1"
	#pushRecVar: 3		"bytecode 2"
	#pushRecVar: 4		"bytecode 3"
	#pushRecVar: 5		"bytecode 4"
	#pushRecVar: 6		"bytecode 5"
	#pushRecVar: 7		"bytecode 6"
	#pushRecVar: 8		"bytecode 7"
	#pushRecVar: 9		"bytecode 8"
	#pushRecVar: 10		"bytecode 9"
	#pushRecVar: 11		"bytecode 10"
	#pushRecVar: 12		"bytecode 11"
	#pushRecVar: 13		"bytecode 12"
	#pushRecVar: 14		"bytecode 13"
	#pushRecVar: 15		"bytecode 14"
	#pushRecVar: 16		"bytecode 15"

	#pushTemp: 1		"bytecode 16"
	#pushTemp: 2		"bytecode 17"
	#pushTemp: 3		"bytecode 18"
	#pushTemp: 4		"bytecode 19"
	#pushTemp: 5		"bytecode 20"
	#pushTemp: 6		"bytecode 21"
	#pushTemp: 7		"bytecode 22"
	#pushTemp: 8		"bytecode 23"
	#pushTemp: 9		"bytecode 24"
	#pushTemp: 10		"bytecode 25"
	#pushTemp: 11		"bytecode 26"
	#pushTemp: 12		"bytecode 27"
	#pushTemp: 13		"bytecode 28"
	#pushTemp: 14		"bytecode 29"
	#pushTemp: 15		"bytecode 30"
	#pushTemp: 16		"bytecode 31"

	#pushLit: 1		"bytecode 32"
	#pushLit: 2		"bytecode 33"
	#pushLit: 3		"bytecode 34"
	#pushLit: 4		"bytecode 35"
	#pushLit: 5		"bytecode 36"
	#pushLit: 6		"bytecode 37"
	#pushLit: 7		"bytecode 38"
	#pushLit: 8		"bytecode 39"
	#pushLit: 9		"bytecode 40"
	#pushLit: 10		"bytecode 41"
	#pushLit: 11		"bytecode 42"
	#pushLit: 12		"bytecode 43"
	#pushLit: 13		"bytecode 44"
	#pushLit: 14		"bytecode 45"
	#pushLit: 15		"bytecode 46"
	#pushLit: 16		"bytecode 47"
	#pushLit: 17		"bytecode 48"
	#pushLit: 18		"bytecode 49"
	#pushLit: 19		"bytecode 50"
	#pushLit: 20		"bytecode 51"
	#pushLit: 21		"bytecode 52"
	#pushLit: 22		"bytecode 53"
	#pushLit: 23		"bytecode 54"
	#pushLit: 24		"bytecode 55"
	#pushLit: 25		"bytecode 56"
	#pushLit: 26		"bytecode 57"
	#pushLit: 27		"bytecode 58"
	#pushLit: 28		"bytecode 59"
	#pushLit: 29		"bytecode 60"
	#pushLit: 30		"bytecode 61"
	#pushLit: 31		"bytecode 62"
	#pushLit: 32		"bytecode 63"

	#pushVar: 1		"bytecode 64"
	#pushVar: 2		"bytecode 65"
	#pushVar: 3		"bytecode 66"
	#pushVar: 4		"bytecode 67"
	#pushVar: 5		"bytecode 68"
	#pushVar: 6		"bytecode 69"
	#pushVar: 7		"bytecode 70"
	#pushVar: 8		"bytecode 71"
	#pushVar: 9		"bytecode 72"
	#pushVar: 10		"bytecode 73"
	#pushVar: 11		"bytecode 74"
	#pushVar: 12		"bytecode 75"
	#pushVar: 13		"bytecode 76"
	#pushVar: 14		"bytecode 77"
	#pushVar: 15		"bytecode 78"
	#pushVar: 16		"bytecode 79"
	#pushVar: 17		"bytecode 80"
	#pushVar: 18		"bytecode 81"
	#pushVar: 19		"bytecode 82"
	#pushVar: 20		"bytecode 83"
	#pushVar: 21		"bytecode 84"
	#pushVar: 22		"bytecode 85"
	#pushVar: 23		"bytecode 86"
	#pushVar: 24		"bytecode 87"
	#pushVar: 25		"bytecode 88"
	#pushVar: 26		"bytecode 89"
	#pushVar: 27		"bytecode 90"
	#pushVar: 28		"bytecode 91"
	#pushVar: 29		"bytecode 92"
	#pushVar: 30		"bytecode 93"
	#pushVar: 31		"bytecode 94"
	#pushVar: 32		"bytecode 95"

	#stRecVar: 1		"bytecode 96"
	#stRecVar: 2		"bytecode 97"
	#stRecVar: 3		"bytecode 98"
	#stRecVar: 4		"bytecode 99"
	#stRecVar: 5		"bytecode 100"
	#stRecVar: 6		"bytecode 101"
	#stRecVar: 7		"bytecode 102"
	#stRecVar: 8		"bytecode 103"

	#stTemp: 1		"bytecode 104"
	#stTemp: 2		"bytecode 105"
	#stTemp: 3		"bytecode 106"
	#stTemp: 4		"bytecode 107"
	#stTemp: 5		"bytecode 108"
	#stTemp: 6		"bytecode 109"
	#stTemp: 7		"bytecode 110"
	#stTemp: 8		"bytecode 111"

	#pushSelf: #nil		"bytecode 112"
	#pushTrue: #nil		"bytecode 113"
	#pushFalse: #nil	"bytecode 114"
	#pushNil: #nil		"bytecode 115"
	#push: -1		"bytecode 116"
	#push: 0		"bytecode 117"
	#push: 1		"bytecode 118"
	#push: 2		"bytecode 119"

	#explicitRet: #pushSelf:"bytecode 120"
	#explicitRet: #pushTrue:"bytecode 121"
	#explicitRet: #pushFalse:"bytecode 122"
	#explicitRet: #pushNil:	"bytecode 123"

	#explicitRet: 0		"bytecode 124"
	#retStackTop: #nil	"bytecode 125"

	#bigLiterals: #nil	"bytecode 126"
	#breakpoint: #nil   	"bytecode 127"

	#pushIndexedVal: 0	"bytecode 128"
	#popAndStoreStackTop: 0	"bytecode 129"
	#popAndStoreStackTop: 1	"bytecode 130"

	#sendShort: #nil	"bytecode 131"
	#sendLong: #nil		"bytecode 132"
	#supSendShort: #nil	"bytecode 133"
	#supSendLong: #nil	"bytecode 134"

	#popStack: 1		"bytecode 135"
	#dupStack: #nil		"bytecode 136"
	
	#pushThisContext: #nil	"bytecode 137"

	#outerVars: #nil	"bytecode 138"
	#shJmp: 0		"bytecode 139 - nop"

	#replaceSelf: #nil	"bytecode 140"
	#replace: 1		"bytecode 141"
	#pushIndexedVal: 1	"bytecode 142"
	#unused: 143		"bytecode 143"

	#shJmp: 1		"bytecode 144"
	#shJmp: 2		"bytecode 145"
	#shJmp: 3		"bytecode 146"
	#shJmp: 4		"bytecode 147"
	#shJmp: 5		"bytecode 148"
	#shJmp: 6		"bytecode 149"
	#shJmp: 7		"bytecode 150"
	#shJmp: 8		"bytecode 151"

	#shJmpFalse: 1		"bytecode 152"
	#shJmpFalse: 2		"bytecode 153"
	#shJmpFalse: 3 		"bytecode 154"
	#shJmpFalse: 4		"bytecode 155"
	#shJmpFalse: 5		"bytecode 156"
	#shJmpFalse: 6		"bytecode 157"
	#shJmpFalse: 7		"bytecode 158"
	#shJmpFalse: 8		"bytecode 159"

	#longJmp: -1024		"bytecode 160"
	#longJmp: -768		"bytecode 161"
	#longJmp: -512		"bytecode 162"
	#longJmp: -256		"bytecode 163"
	#longJmp: 0		"bytecode 164"
	#longJmp: 256		"bytecode 165"
	#longJmp: 512		"bytecode 166"
	#longJmp: 768		"bytecode 167"

	#popJmpTrue: 0		"bytecode 168"
	#popJmpTrue: 256	"bytecode 169"
	#popJmpTrue: 512	"bytecode 170"
	#popJmpTrue: 768	"bytecode 171"

	#popJmpFalse: 0		"bytecode 172"
	#popJmpFalse: 256	"bytecode 173"
	#popJmpFalse: 512	"bytecode 174"
	#popJmpFalse: 768	"bytecode 175"

	#send1: #+		"bytecode 176"
	#send1: #-		"bytecode 177"
	#send1: #<		"bytecode 178"
	#send1: #>		"bytecode 179"
	#send1: #<=		"bytecode 180"
	#send1: #>=		"bytecode 181"
	#send1: #=		"bytecode 182"
	#send1: #~=		"bytecode 183"
	#send1: #*		"bytecode 184"
	#send1: #/		"bytecode 185"
	#send1: #\\		"bytecode 186"
	#send1: #@		"bytecode 187"
	#send1: #bitShift:	"bytecode 188"
	#send1: #//		"bytecode 189"
	#send1: #bitAnd:	"bytecode 190"
	#send1: #bitOr:		"bytecode 191"

	#send1: #at:		"bytecode 192"
	#send2: #at:put:	"bytecode 193"
	#send0: #size		"bytecode 194"
	#send0: #next		"bytecode 195"
	#send1: #nextPut:	"bytecode 196"
	#send0: #atEnd		"bytecode 197"
	#send1: #==		"bytecode 198"
	#send0: #class		"bytecode 199"
	#doBlockCopy: #nil	"bytecode 200"
	#send0: #value		"bytecode 201"
	#send1: #value:		"bytecode 202"
	#send0: #do:		"bytecode 203"
	#send0: #new		"bytecode 204"
	#send1: #new:		"bytecode 205"
	#send0: #isNil		"bytecode 206"
	#send0: #notNil	   	"bytecode 207"

	#sendLit0: 1		"bytecode 208"
	#sendLit0: 2		"bytecode 209"
	#sendLit0: 3		"bytecode 210"
	#sendLit0: 4		"bytecode 211"
	#sendLit0: 5		"bytecode 212"
	#sendLit0: 6		"bytecode 213"
	#sendLit0: 7		"bytecode 214"
	#sendLit0: 8		"bytecode 215"
	#sendLit0: 9		"bytecode 216"
	#sendLit0: 10		"bytecode 217"
	#sendLit0: 11		"bytecode 218"
	#sendLit0: 12		"bytecode 219"
	#sendLit0: 13		"bytecode 220"
	#sendLit0: 14		"bytecode 221"
	#sendLit0: 15		"bytecode 222"
	#sendLit0: 16		"bytecode 223"

	#sendLit1: 1		"bytecode 224"
	#sendLit1: 2		"bytecode 225"
	#sendLit1: 3		"bytecode 226"
	#sendLit1: 4		"bytecode 227"
	#sendLit1: 5		"bytecode 228"
	#sendLit1: 6		"bytecode 229"
	#sendLit1: 7		"bytecode 230"
	#sendLit1: 8		"bytecode 231"
	#sendLit1: 9		"bytecode 232"
	#sendLit1: 10		"bytecode 233"
	#sendLit1: 11		"bytecode 234"
	#sendLit1: 12		"bytecode 235"
	#sendLit1: 13		"bytecode 236"
	#sendLit1: 14		"bytecode 237"
	#sendLit1: 15		"bytecode 238"
	#sendLit1: 16		"bytecode 239"

	#sendLit2: 1		"bytecode 240"
	#sendLit2: 2		"bytecode 241"
	#sendLit2: 3		"bytecode 242"
	#sendLit2: 4		"bytecode 243"
	#sendLit2: 5		"bytecode 244"
	#sendLit2: 6		"bytecode 245"
	#sendLit2: 7		"bytecode 246"
	#sendLit2: 8		"bytecode 247"
	#sendLit2: 9		"bytecode 248"
	#sendLit2: 10		"bytecode 249"
	#sendLit2: 11		"bytecode 250"
	#sendLit2: 12		"bytecode 251"
	#sendLit2: 13		"bytecode 252"
	#sendLit2: 14		"bytecode 253"
	#sendLit2: 15		"bytecode 254"
	#sendLit2: 16		"bytecode 255"
    )
!

returnBlock
    ^ReturnBlock
!

debugByte
    "Answer the byte code that the debugger uses for breakpoints"
    ^127
! !


!Debugger methodsFor: 'virtual machine'!

dispatchBytecodesUntil: stopTypeSymbol
    stopType := stopTypeSymbol.
    self dispatchBytecodes
!

dispatchBytecodes
    | byte type |
    receiver := curContext receiver.
    method := curContext method.
    ipAdjust := curContext method bytecodeStart.
    ip := curContext ip + ipAdjust.

    [
	byte := method at: ip.
	ip := ip + 1.
	curContext
	    perform: (BytecodeSelectors at: byte + byte + 1)
	    with:    (BytecodeSelectors at: byte + byte + 2).

	type isSymbol and: [ type == stopType ]
    ] whileFalse.

    curContext ip: ip - ipAdjust.
    ^type isSymbol ifTrue: [ nil ] ifFalse: [ type value ].

! !      

!Debugger methodsFor: 'bytecodes'!

pushRecVar: index
    ^self push: (receiver instVarAt: index).
!

pushTemp: index
    ^self push: (curContext at: index).
!

pushLit: index
    ^self push: (method literalAt: index).
!

pushVar: index
    ^self push: (method literalAt: index) value.
!

stRecVar: index
    receiver instVarAt: index put: (curContext at: curContext sp).
    curContext sp: curContext sp - 1.
    ^#store
!

stTemp: index
    curContext at: index put: (curContext at: curContext sp).
    curContext sp: curContext sp - 1.
    ^#store
!

stVar: index
    (curContext at: index)
	value: (curContext at: curContext sp).
    curContext sp: curContext sp - 1.
    ^#store
!

pushSelf: unused
    ^self push: receiver
!

pushTrue: unused
    ^self push: true
!

pushFalse: unused
    ^self push: false
!

pushNil: unused
    ^self push: nil
!

replaceSelf: unused
    curContext basicAt: curContext sp put: receiver.
    ^#push
!

replace: anObject
    curContext basicAt: curContext sp put: anObject.
    ^#push
!

push: anObject
    | sp |
    curContext
	sp: (sp := curContext sp + 1);
	basicAt: sp put: anObject.
    ^#push
!

explicitRet: selector
    | home stackTop bad |
    selector isInteger			"push self/true/false/etc."
	ifFalse: [ self perform: selector with: #nil ].

    stackTop := curContext at: curContext sp.
    curContext isBlock ifFalse: [
	curContext := curContext parentContext.
	^self doReturn: stackTop
    ].

    bad := false.
    [ (home := curContext home) parentContext isNil ] whileTrue: [
	"Walk down until we do find a valid context"
	bad := true.
	curContext := curContext parentContext
	curContext isNil ifTrue: [ ^#bad ].
    ].
    
    curContext := home.

    self doReturn: stackTop.
    bad ifFalse: [ ^#return ].	"99%"

    self send: 0 selector: #badReturnError super: false.
    ^#return
!

retStackTop: unused
    | stackTop |
    stackTop := curContext at: curContext sp.
    curContext := curContext parentContext.
    ^self doReturn: stackTop
!

doBlockCopy: unused
    | closure outer sp |
    sp := curContext sp.
    outer := curContext at: sp.
    closure := curContext at: (sp := sp - 1).

    closure class == BlockClosure ifFalse: [ ^self send1: #blockCopy: ].
    curContext sp: sp.
    curContext at: sp put: (closure blockCopy: outer;
	receiver: receiver;
	yourself).
!

doReturn: stackTop
    curContext isNil ifTrue: [ ^#endSimulation -> stackTop ].
    self push: stackTop.
    receiver := curContext receiver.
    method := curContext method.
    ipAdjust := curContext method bytecodeStart.
    ip := curContext ip + ipAdjust.

    ^#return
!

breakpoint: unused
    receiver breakpoint: curContext return: nil.
    ip := ip - 1.
    ^#breakpoint
!

pushIndexedVal: adjust
    | byte type |
    curContext sp: curContext sp - adjust.
    byte := method at: ip. ip := ip + 1.
    type := byte bitShift: -6.
    byte := byte bitAnd: 63.
    ^self
	perform: ( #(#pushRecVar: #pushTemp: #pushLit: #pushVar:) at: type + 1)
	with: byte + 1
!

popAndStoreStackTop: adjust
    | byte type return |
    byte := method at: ip. ip := ip + 1.
    type := byte bitShift: -6.
    byte := byte bitAnd: 63.
    return := self
	perform: ( #(#stRecVar: #stTemp: #unused: #stVar:) at: type + 1)
	with: byte + 1.

    curContext sp: curContext sp - adjust.
    ^return
!

sendShort: unused
    | byte |
    byte := method at: ip. ip := ip + 1.
    ^self
	send: (byte bitShift: -5)
	selector: (method literalAt: (byte bitAnd: 31) + 1)
	super: false
!

sendLong: unused
    | byte1 byte2 |
    byte1 := method at: ip. ip := ip + 1.
    byte2 := method at: ip. ip := ip + 1.
    ^self
	send: byte1
	selector: byte2
	super: false
!

supSendShort: unused
    | byte |
    byte := method at: ip. ip := ip + 1.
    ^self
	send: (byte bitShift: -5)
	selector: (method literalAt: (byte bitAnd: 31) + 1)
	super: true
!

supSendLong: unused
    | byte1 byte2 |
    byte1 := method at: ip. ip := ip + 1.
    byte2 := method at: ip. ip := ip + 1.
    ^self
	send: byte1
	selector: byte2
	super: true
!

popStack: howMany
    curContext sp: curContext sp - howMany.
    ^#pop
!

dupStack: unused
    ^self push: (curContext at: curContext sp)
!

pushThisContext: unused
    ^self push: curContext
!

bigLiterals: unused
    | byte1 byte2 object |
    byte1 := method at: ip. ip := ip + 1.
    byte2 := method at: ip. ip := ip + 1.
    byte1 := byte1 * 256 + byte2.
    byte2 := byte1 bitShift: -14.

    object := self literalAt: byte1 + 1.
    byte2 = 0 ifTrue: [ ^self push: object ].
    byte2 = 64 ifTrue: [ ^self push: object value ].
    
    object value: (curContext at: curContext sp).
    byte2 = 128 ifTrue: [ curContext sp: curContext sp - 1 ].
    ^#store
!

outerVars: unused
    | byte1 byte2 ctx object |
    byte1 := method at: ip. ip := ip + 1.
    byte2 := method at: ip. ip := ip + 1.
    ctx := curContext outerContext: byte2.

    byte2 := byte1 bitAnd: 192.
    byte1 := (byte1 bitAnd: 63) + 1.
    byte2 = 64 ifTrue: [ ^self push: (ctx at: byte1) ].

    object := curContext at: byte1.
    byte2 = 128 ifTrue: [ curContext sp: curContext sp - 1 ].
    byte2 = 0 ifFalse: [ ctx at: byte2 + 1 put: object. ^#store ].
    ^#bad
!

unused: bytecode
    ^#bad
!

shJmp: index
    ip := ip + index.
    ^#jump
!

shJmpFalse: index
    | top |
    (top := curContext at: curContext sp) == false
	ifTrue: [ ip := ip + index ]
	ifFalse: [ top == true ifFalse: [ ^self sendMustBeBoolean ] ].

    curContext sp: curContext sp - 1.
    ^#jump
!

longJmp: adjust
    | index | 
    index := method at: ip. ip := ip + 1.
    ip := ip + index + adjust.
    ^#jump
!

popJmpFalse: adjust
    | index top | 
    index := (method at: ip) + adjust. ip := ip + 1.
    (top := curContext at: curContext sp) == false
	ifTrue: [ ip := ip + index ]
	ifFalse: [ top == true ifFalse: [ ^self sendMustBeBoolean ] ].

    curContext sp: curContext sp - 1.
    ^#jump
!

popJmpTrue: adjust
    | index top |
    index := (method at: ip) + adjust. ip := ip + 1.
    (top := curContext at: curContext sp) == true
	ifTrue: [ ip := ip + index ]
	ifFalse: [ top == false ifFalse: [ ^self sendMustBeBoolean ] ].

    curContext sp: curContext sp - 1.
    ^#jump
!

sendMustBeBoolean
    ^self send: 0 selector: #mustBeBoolean super: false
!

send0: msg
    ^self send: 0 selector: msg super: false
!

send1: msg
    ^self send: 1 selector: msg super: false
!

send2: msg
    ^self send: 2 selector: msg super: false
!

sendLit0: index
    ^self
	send: 0
	selector: (method literalAt: index)
	super: false
!

sendLit1: index
    ^self
	send: 1
	selector: (method literalAt: index)
	super: false
!

sendLit2: index
    ^self
	send: 2
	selector: (method literalAt: index)
	super: false
! !

!Debugger methodsFor: 'private'!

initialize: context
    curContext := context.
!

send: numArgs selector: selector super: superBoolean
    | args receiver sp arg class |
    sp := curContext sp - numArgs.
    args := Array new: numArgs.
    0 to: numArgs do: [ :i |
	arg := curContext at: sp + i.
	i = 0
	    ifTrue: [ receiver := arg ]
	    ifFalse: [ args at: i put: arg ].

	arg class == BlockClosure ifTrue: [
	    arg outerContext method breakpointAt: arg initialIP
	]
    ].
    curContext sp: curContext sp - numArgs.
    class := superBoolean
	ifTrue: [ curContext methodClass superclass ]
	ifFalse: [ receiver class perform: class ].

    selector = #perform:	       ifTrue: [ ^self sendPerform: args to: receiver class: class ].
    selector = #perform:with:	       ifTrue: [ ^self sendPerformWith: args to: receiver class: class ].
    selector = #perform:with:with:     ifTrue: [ ^self sendPerformWith: args to: receiver class: class ].
    selector = #perform:withArguments: ifTrue: [ ^self sendPerformWithArguments: args to: receiver class: class ].

    ^self sendMessage: selector to: receiver args: args class: class
!

sendMessage: theSelector to: receiver args: theArgs class: theClass
    | newMethod oldRetBlock return sp args selector class |
    args := theArgs.
    selector := theSelector.
    class := theClass.
    sp := curContext sp.
    [   class isNil ifTrue: [
	    "Create a #doesNotUnderstand: frame"
	    args := Array with:
		(Message selector: selector arguments: args).

	    (selector == #doesNotUnderstand:) ifTrue: [ ^#bad ].
	    selector := #doesNotUnderstand: .
	    class := receiver class
	].
	class includesSelector: selector
    ]   whileFalse: [ class := class superclass ].

    newMethod := class >> selector.
    newMethod breakpointAt: 1.

    oldRetBlock := ReturnBlock.
    ReturnBlock := [ :context :returnValue |
	"It was not a primitive, or it was a primitive but it failed.
	 We can steal the current VM status from the passed context
	 and run the simulation"

	ReturnBlock := oldRetBlock.
	curContext := context.
	receiver := curContext receiver.
	method := newMethod.
	ipAdjust := newMethod bytecodeStart.
	ip := curContext ip + ipAdjust.
	self push: returnValue.
	^#send
    ].

    return := receiver
	perform: selector
	withArguments: args.

    "It was a primitive and it succeeded. Push the return value and leave"
    ReturnBlock := oldRetBlock.
    newMethod removeBreakpointAt: 1.
    self push: return.
    ^#send
!

sendPerform: args to: receiver class: class 
    ^self
       sendMessage: (args at: 1)
       to: receiver
       args: #()
       class: class
!

sendPerformWith: args to: receiver class: class 
    ^self
       sendMessage: (args at: 1)
       to: receiver
       args: (args copyFrom: 2 to: args size)
       class: class
!

sendPerformWithArguments: args to: receiver class: class 
    ^self
       sendMessage: (args at: 1)
       to: receiver
       args: (args at: 2)
       class: class
! !

!Object methodsFor: 'debugging'!

breakpoint: context return: return
    context method removeBreakpointAt: context ip.
    Debugger returnBlock value: context value: return.
    ^return
! !

Debugger initialize!

