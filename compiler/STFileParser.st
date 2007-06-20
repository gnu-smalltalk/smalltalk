"======================================================================
|
|   Smalltalk in Smalltalk file-in driver
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2006,2007 Free Software Foundation, Inc.
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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


RBParser subclass: #STFileParser
    instanceVariableNames: 'driver'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

Object subclass: #STParsingDriver
    instanceVariableNames: 'parser'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

STFileParser subclass: #STFileInParser
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!




!STFileParser methodsFor: 'accessing'!

driver
    ^driver!

driver: aSTParsingDriver
    driver := aSTParsingDriver.
    driver parser: self!

parseSmalltalk
    self subclassResponsibility!

!STFileParser methodsFor: 'overridable - parsing file-ins'!

compile: node
    driver compile: node
!

endMethodList
    driver endMethodList
!

evaluate: node
    "This should be overridden because its result affects the parsing
     process: true means 'start parsing methods', false means 'keep
     evaluating'. By default, always answer false."
    ^driver evaluate: node
! !

!STFileParser methodsFor: 'utility'!

parseStatements
    ^self parseDoit: [ self parseStatements: false ]!

parseDoit: aBlock
    | node method start stop comments source |
    comments := scanner getComments.
    start := comments isNil
	    	ifTrue: [ currentToken start - 1 ]
	    	ifFalse: [ comments first first - 1 ].
	
    tags := nil.
    node := aBlock value.
    node comments isNil
	ifTrue: [ node comments: comments ]
	ifFalse: [
	    comments isNil ifFalse: [ node comments: node comments, comments ] ].

    "One -1 accounts for base-1 vs. base-0 (as above), the
     other drops the bang because we have a one-token lookahead."
    stop := currentToken start - 2.

    method := RBMethodNode selectorParts: #() arguments: #().
    source := scanner stream copyFrom: start to: stop.
    source := MappedCollection collection: source map: (1 - start to: stop).
    method source: source.
    node parent: method.
    ^node! !

!STFileParser class methodsFor: 'accessing'!

parseSmalltalk: aString with: aDriver
    ^self parseSmalltalk: aString with: aDriver onError: nil!

parseSmalltalk: aString with: aDriver onError: aBlock 
    | parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWith: aString type: #on:errorBlock:.
    parser driver: aDriver.
    ^parser parseSmalltalk!

parseSmalltalkStream: aStream with: aDriver
    ^self parseSmalltalkStream: aStream with: aDriver onError: nil!

parseSmalltalkStream: aStream with: aDriver onError: aBlock 
    | parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWithStream: aStream type: #on:errorBlock:.
    parser driver: aDriver.
    ^parser parseSmalltalk! !

!STFileInParser methodsFor: 'private-parsing'!

parseSmalltalk
    [ self parseDoits ]
        whileTrue: [ self parseMethodDefinitionList ].

    ^driver result!

scannerClass
    ^STFileScanner! !

!STFileInParser methodsFor: 'private-parsing'!

parseDoits
    " Parses the stuff to be executed until a
        ! <class expression> methodsFor: <category string> ! "

    | node |
    [
	self atEnd ifTrue: [ ^false ].
	node := self parseStatements.
        scanner stripSeparators.           "gobble doit terminating bang"
        self step.           "gobble doit terminating bang"
	node statements size > 0 and: [ self evaluate: node ]
    ] whileFalse.
    ^true
!

parseMethodDefinitionList
    "Called after first !, expecting a set of bang terminated
     method definitions, followed by a bang"

    | node source start stop |
    [ scanner atEnd or: [ currentToken isSpecial
	   and: [ currentToken value == $! ] ] ] whileFalse: [

	start := currentToken start - 1.
        tags := nil.
        node := self parseMethod.

        "One -1 accounts for base-1 vs. base-0 (as above), the
         other drops the bang because we have a one-token lookahead."
	stop := currentToken start - 2.
        source := scanner stream copyFrom: start to: stop.
	source := MappedCollection collection: source map: (1 - start to: stop).
        node source: source.

        scanner stripSeparators.
        self step.           "gobble method terminating bang"
        self compile: node
    ].
    scanner stripSeparators.
    self step.
    self endMethodList
! !

!STParsingDriver methodsFor: 'starting the parsing'!

parseSmalltalk: aString with: aParserClass
    ^aParserClass parseSmalltalk: aString with: self!

parseSmalltalk: aString with: aParserClass onError: aBlock 
    ^aParserClass parseSmalltalk: aString with: self onError: aBlock!

parseSmalltalkStream: aStream with: aParserClass
    ^aParserClass parseSmalltalkStream: aStream with: self!

parseSmalltalkStream: aStream with: aParserClass onError: aBlock 
    ^aParserClass parseSmalltalkStream: aStream with: self onError: aBlock!

parseSmalltalkFileIn: aFilename with: aParserClass
    ^self parseSmalltalkFileIn: aFilename with: aParserClass onError: nil!

parseSmalltalkFileIn: aFilename with: aParserClass onError: aBlock 
    | parser file |
    file := FileStream open: aFilename mode: FileStream read.
    [ self parseSmalltalkStream: file with: aParserClass onError: aBlock ]
	ensure: [ file close ]! !

!STParsingDriver methodsFor: 'accessing'!

errorBlock
    ^parser errorBlock
!

parserWarning: aString
    parser parserWarning: aString
!

parserError: aString
    parser parserError: aString
!

parser
    ^parser!

parser: aSTFileParser
    parser := aSTFileParser! !

!STParsingDriver methodsFor: 'overridable - parsing file-ins'!

result
    "return self by default"
    ^self
!

compile: node
    "do nothing by default"
!

endMethodList
    "do nothing by default"
!

evaluate: node
    "This should be overridden because its result affects the parsing
     process: true means 'start parsing methods', false means 'keep
     evaluating'. By default, always answer false."
    ^false
! !

RBScanner subclass: #STFileScanner
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!STFileScanner methodsFor: 'accessing'!

next
    | token |
    buffer reset.
    tokenStart := stream position.
    characterType == #eof ifTrue: [^RBToken start: tokenStart + 1].    "The EOF token should occur after the end of input"
    token := self scanToken.
    (token isSpecial and: [ token value == $! ])
	 ifFalse: [ self stripSeparators ].
    ^token!



!PositionableStream methodsFor: 'compiling'!

name
    "Answer a string that represents what the receiver is streaming on"
    ^'(%1 %2)' bindWith: self species article with: self species name
!

segmentFrom: startPos to: endPos
    "Answer an object that, when sent #asString, will yield the result
     of sending `copyFrom: startPos to: endPos' to the receiver"
    ^self copyFrom: startPos to: endPos
! !

!FileStream methodsFor: 'compiling'!

segmentFrom: startPos to: endPos
    "Answer an object that, when sent #asString, will yield the result
     of sending `copyFrom: startPos to: endPos' to the receiver"
    ^FileSegment
	on: self name
	startingAt: startPos
	for: endPos - startPos + 1.
! !

