"======================================================================
|
|   BLOX man page viewer
|
|
 ======================================================================"

 
"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

PackageLoader fileInPackage: 'Blox'!
Namespace current: BLOX!

BExtended subclass: #ManViewer
    instanceVariableNames: 'input separator label'
    classVariableNames: 'OpenParenExpansions'
    poolDictionaries: ''
    category: 'Graphics-Examples'!

!ManViewer class methodsFor: 'initializing'!

initialize
    OpenParenExpansions := Dictionary new
	at: 'em' put: ' -- ';
	at: 'en' put: ' - ';
	at: 'lq' put: $` asString;
	at: 'rq' put: $' asString;
	yourself
! !

!ManViewer class methodsFor: 'starting'!

openOn: fileName
    | window text |
    window := BWindow new.
    window width: 560 height: 300.

    text := self new: window.
    [ text parse: (FileStream open: fileName mode: FileStream read) ]
	ifCurtailed: [ window destroy ].

    window label: text label.

    window map.
    Blox idle.
    window activate.
    text activate.

    Blox dispatchEvents: window
! !

!ManViewer methodsFor: 'accessing'!

label
    ^label ifNil: [ 'Man page viewer' ]
!

newPrimitive
    ^(BText new: self parent)
	font: self normal font;
	yourself
!

parse: stream
    input := stream.
    separator := ''.
    [ stream atEnd ] whileFalse: [
	self parseLine: (stream upTo: Character nl)
    ].
    input close.
    input := nil.

    self primitive gotoLine: 1 end: false
!

text: string
    self parse: (ReadStream on: string)
! !

!ManViewer methodsFor: 'private - gui'!

label: string
    label := string
!

insert: line fonts: fonts
    | attributes font |
    font := 2.
    attributes := fonts collect: [ :each | self perform: each ].

    self primitive insertAtEnd: separator.
    separator := ''.
    self breakIntoArguments: line do: [ :each |
	font := 3 - font.
	self primitive
	    insertAtEnd: (each copyWith: Character space)
	    attribute: (attributes at: font)
    ]
!

insertEndSpace: line fonts: fonts
    | attributes font |
    font := 2.
    attributes := fonts collect: [ :each | self perform: each ].

    self primitive insertAtEnd: separator.
    separator := ''.
    self breakIntoArguments: line do: [ :each |
	font := 3 - font.
	self primitive
	    insertAtEnd: each
	    attribute: (attributes at: font)
    ].
    self primitive space
!

nl
    self primitive nl
! !

!ManViewer methodsFor: 'fonts'!

big
    ^BTextAttributes font: 'Courier 9 bold italic'
!

bold
    ^BTextAttributes font: 'Courier 9 bold'
!

italic
    ^BTextAttributes font: 'Courier 9 italic'
!

normal
    ^BTextAttributes font: 'Courier 9'
!

separatePara
    ^(String new: 2) atAllPut: Character nl; yourself
! !

!ManViewer methodsFor: 'parsing'!

dispatch: directive line: line
    "Parse a line in the format `.<directive> <line>' "
    | symbol |
    directive = '\"' ifTrue: [ ^self ].
    symbol := ('parse', directive asUppercase, ':') asSymbol.

    (self class includesSelector: symbol)
	ifTrue: [ self perform: symbol with: line ]
!

parseLine: line
    | directive |
    line isEmpty ifTrue: [ ^self ].

    (line at: 1) = $.
	ifFalse: [
	    self parseQuoted: line.
	]
	ifTrue: [ 
	    line size < 3 ifTrue: [ ^self ].
	    directive := (line at: 3) = Character space
		ifTrue: [ (line copyFrom: 2 to: 2) ]
		ifFalse: [ (line copyFrom: 2 to: 3) ].

	    self dispatch: directive line: line.
	]
!

breakIntoArguments: line do: aBlock
    | stream argument |
    stream := ReadStream on: line.
    [ stream atEnd ifTrue: [ ^self ]. stream peek isSeparator ]
	 whileFalse: [ stream next ].

    [
	[ stream atEnd ifTrue: [ ^self ]. stream peek isSeparator ]
	    whileTrue: [ stream next ].
	stream atEnd
    ]   whileFalse: [
	argument := (stream peekFor: $")
	    ifTrue: [ self upToQuote: stream ]
	    ifFalse: [ self nextWord: stream ].

	aBlock value: argument
    ].
!

nextWord: line
    | ws ch |
    ws := WriteStream on: (String new: 10).
    [ line atEnd or: [ (ch := line next) isSeparator ] ] whileFalse: [
	ch = $\
	    ifTrue: [ self parseQuoted: line on: ws ]
	    ifFalse: [ ws nextPut: ch ]
    ].
    ^ws contents
!

upToQuote: line
    | ws ch |
    ws := WriteStream on: (String new: 10).
    [ line atEnd or: [ (ch := line next) == $" ] ] whileFalse: [
	ch = $\
	    ifTrue: [ self parseQuoted: line on: ws ]
	    ifFalse: [ ws nextPut: ch ]
    ].
    ^ws contents
!

parseQuoted: line
    | stream |
    self primitive insertAtEnd: separator.
    stream := ReadStream on: line.
    [ stream atEnd ifTrue: [ ^self ].
      stream next isSeparator ] whileTrue: [ ].
    
    stream skip: -1.
    self parseQuotedStream: stream size: line size.
    separator := ' '.
!

parseQuotedStream: stream size: size
    | ws ch newFont font |
    font := self normal.
    ws := WriteStream on: (String new: size).

    [ stream atEnd ] whileFalse: [
	ch := stream next.
	ch = $\
	    ifFalse: [ ws nextPut: ch ]
	    ifTrue: [
		newFont := self parseQuoted: stream on: ws.
		newFont isNil ifFalse: [
		    self primitive
			insertAtEnd: ws contents
	 		attribute: font.
		    font := self perform: newFont.
	  	    ws reset.
		]
	    ]
    ].
    self primitive
	insertAtEnd: (self rtrimSeparators: ws contents)
	attribute: font
!

parseQuoted: line on: ws 
    | ch s |
    line atEnd ifTrue: [ ^nil ].
    ch := line next.

    ch == $* ifTrue: [
	line atEnd ifTrue: [ ^nil ].
	ch := line next
    ].
    ch == $& ifTrue: [ ws nextPut: line next. ^nil ].
    ch == $( ifTrue: [
	line atEnd ifTrue: [ ^nil ].
	s := String with: line next.
	line atEnd ifTrue: [ ^nil ].
	s := s copyWith: line next.
	s := OpenParenExpansions at: s ifAbsent: [ ^nil ].
	ws nextPutAll: s.
	^nil
    ].
    ch == $c ifTrue: [ ^nil ].
    ch == $d ifTrue: [ ^nil ].
    ch == $^ ifTrue: [ ^nil ].
    ch == $| ifTrue: [ ^nil ].
    ch == $e ifTrue: [ ws nextPut: $\. ^nil ].

    ch == $f ifTrue: [
	line atEnd ifTrue: [ ^nil ].
	ch := line next.
	ch == $B ifTrue: [ ^#bold ].
	ch == $I ifTrue: [ ^#italic ].
	ch == $P ifTrue: [ ^#normal ].
	ch == $R ifTrue: [ ^#normal ].
    ].
    (ch == $s) ifFalse: [ ws nextPut: ch. ^nil ].

    [ line atEnd ifTrue: [ ^nil ]. line peek isDigit ]
	whileFalse: [ line next ].
    [ line atEnd ifTrue: [ ^nil ]. line peek isDigit ]
	whileTrue: [ line next ].
    ^nil
!

rtrimSeparators: line
    | size last |
    size := line size.
    last := line findLast: [ :each | each isSeparator not ].
    
    ^last = 0
	ifTrue: [ line ]
	ifFalse: [ line copyFrom: 1 to: last ]
! !

!ManViewer methodsFor: 'man macros'!

parseTH: line
    | first second |
    self breakIntoArguments: line do: [ :each |
	second isNil ifFalse: [
	    self label: 'Viewing ', first, '(', second, ') man page'.
	    ^self
	].
	first isNil
	    ifTrue: [ first := each asLowercase ]
	    ifFalse: [ second := each ]
    ].
!

parseSH: line
    separator := self separatePara.
    self insert: line fonts: #(#big #big).
    separator := Character nl asString.
!

parseSS: line
    self nl; insert: line fonts: #(#bold #bold); nl
!

parseBI: line
    self insertEndSpace: line fonts: #(#bold #italic)
!

parseB: line
    self insert: line fonts: #(#bold #bold)
!

parseBR: line
    self insertEndSpace: line fonts: #(#bold #normal)
!

parseSP: line
    separator := Character nl asString.
!

parseNL: line
    separator := Character nl asString.
!

parseBR: line
    separator := Character nl asString.
!

parsePD: line
    "not supported"
!

parsePP: line
    separator := self separatePara.
!

parseLP: line
    separator := self separatePara.
!

parseTP: line
    separator := Character nl asString.
!

parseIP: line
    separator := Character nl asString.
    self insert: line, '   ' fonts: #(#bold #bold)
!

parseI: line
    self insert: line fonts: #(#italic #italic)
!

parseIB: line
    self insertEndSpace: line fonts: #(#italic #bold)
!

parseIR: line
    self insertEndSpace: line fonts: #(#italic #normal)
!

parseRI: line
    self insertEndSpace: line fonts: #(#normal #italic)
!

parseRB: line
    self insertEndSpace: line fonts: #(#normal #bold)
!

parseSB: line
    self insertEndSpace: line fonts: #(#normal #bold)
!

parseNormal: line
    self insert: line fonts: #(#normal #normal)
!

parseSM: line
    self insert: line fonts: #(#normal #normal)
! !

ManViewer initialize!

Namespace current: Smalltalk!
