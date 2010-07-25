"======================================================================
|
|   Documentation generator abstract classes.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2007,2008,2009
| Free Software Foundation, Inc.
| Written by Steve Byrne and Paolo Bonzini.
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
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


String extend [
    caseSensitiveCompareTo: aCharacterArray [
	<category: 'private-ClassPublisher extensions'>
        | c1 c2 |
        1 to: (self size min: aCharacterArray size)
            do:
                [:i |
                c1 := (self at: i) value.
                c2 := (aCharacterArray at: i) value.
                c1 = c2 ifFalse: [^c1 - c2]].
        ^self size - aCharacterArray size
    ]
]


Object subclass: ClassPublisher [
    | class destination referenceNamespace |
    
    <category: 'Examples-File out'>
    <comment: nil>

    ClassPublisher class >> basicPublish: aClass on: aFileStream [
	"Publish aClass, in the format supported by the receiver, on aFileStream"

	<category: 'publishing'>
	self new fileOut: aClass on: aFileStream
    ]

    ClassPublisher class >> publish: aClass on: aFileStream [
	"Publish aClass, in the format supported by the receiver, on aFileStream"

	<category: 'publishing'>
	self new fileOut: aClass on: aFileStream
    ]

    ClassPublisher class >> publish: aClass onFile: fileNameString [
	"Publish aClass, in the format supported by the receiver, on a file named
	 fileNameString"

	<category: 'publishing'>
	| file |
	file := FileStream open: fileNameString mode: 'w'.
	[self publish: aClass on: file] ensure: [file close]
    ]

    fileOut: aClass on: aFileStream [
	"File out the given class on aFileStream."

	<category: 'publishing'>
	referenceNamespace := self namespaceFor: aClass.
	class := aClass asClass.
	destination := aFileStream.
	self emitHeader: Date dateAndTimeNow.
	class := class asMetaclass.
	self fileOutMethods.
	class := class asClass.
	self fileOutMethods.
	self emitFooter
    ]

    fileOutMethods [
	"File out the methods in the current method dictionary."

	<category: 'publishing'>
	| categories now |
	categories := Set new.
	self methodDictionary isNil ifTrue: [^self].
	self methodDictionary 
	    do: [:method | categories add: method methodCategory].
	categories asSortedCollection 
	    do: [:category | self emitCategory: category]
    ]

    emitCategory: category [
	"Emit valid output for the given category."

	<category: 'to be subclassed'>
	self subclassResponsibility
    ]

    emitFooter [
	"Emit a valid footer."

	<category: 'to be subclassed'>
	self subclassResponsibility
    ]

    emitHeader: timestamp [
	"Emit a valid header. timestamp contains `Date dateAndTimeNow'."

	<category: 'to be subclassed'>
	self subclassResponsibility
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 for example, <, & and > in HTML"

	<category: 'to be subclassed'>
	^''
    ]

    namespaceFor: aClass [
	"aClass is being published. Answer the namespace to be used when producing
	 names."

	<category: 'to be subclassed'>
	^aClass environment
    ]

    printEscaped: ch [
	"Called by #nextPutText: when a character that must be escaped is
	 encountered. The actual behavior depends on the class - for instance,
	 Postscripts put a \ before it"

	<category: 'to be subclassed'>
	self nextPut: ch
    ]

    currentClass [
	"Answer the class which we are working on"

	<category: 'accessing/delegating'>
	^class
    ]

    classCategory [
	"Answer the category of the class which we are working on"

	<category: 'accessing/delegating'>
	| class |
	class := self currentClass asClass.
	^class category isNil ifTrue: [''] ifFalse: [class category]
    ]

    classComment [
	"Answer the comment of the class which we are working on"

	<category: 'accessing/delegating'>
	| class |
	class := self currentClass asClass.
	^class comment isNil ifTrue: [''] ifFalse: [class comment]
    ]

    className [
	"Answer the name of the class which we are working on"

	<category: 'accessing/delegating'>
	^self currentClass asClass nameIn: referenceNamespace
    ]

    superclassName [
	"Answer the name of the class which we are working on"

	<category: 'accessing/delegating'>
	| superclass |
	superclass := self currentClass asClass superclass.
	superclass isNil ifTrue: [^'none'].
	^superclass nameIn: referenceNamespace
    ]

    nextPut: aCharacter [
	"Append aCharacter on the file-out"

	<category: 'accessing/delegating'>
	destination nextPut: aCharacter
    ]

    nextPutAll: aString [
	"Append aString on the file-out, literally"

	<category: 'accessing/delegating'>
	destination nextPutAll: aString
    ]

    nextPutAllText: aString [
	"Append aCharacter on the file-out, replacing tabs in aString with
	 appropriate number of spaces, and escaping characters appropriately"

	<category: 'accessing/delegating'>
	| hpos prev |
	hpos := 1.
	aString do: 
		[:ch | 
		ch == Character tab 
		    ifTrue: 
			[
			[self nextPut: Character space.
			hpos := hpos + 1.
			hpos \\ 8 = 1] 
				whileFalse: [].
                        prev := Character space]
		    ifFalse: 
			[self nextPutAllChar: ch after: prev.
			hpos := hpos + 1.
                        prev := ch]]
    ]

    nextPutAllChar: ch after: prev [
       (self escaped includes: ch) 
			    ifTrue: [self printEscaped: ch]
			    ifFalse: [self nextPut: ch].
    ]

    nl [
	"Append a new line on the file-out"

	<category: 'accessing/delegating'>
	destination nl
    ]

    space [
	"Append a space on the file-out"

	<category: 'accessing/delegating'>
	destination space
    ]

    print: anObject [
	"Print anObject on the file-out, replacing tabs in aString with
	 appropriate number of spaces, and escaping characters appropriately"

	<category: 'accessing/delegating'>
	self nextPutAllText: anObject printString
    ]

    store: anObject [
	"Store Smalltalk code evaluating to anObject on the file-out, replacing
	 tabs in aString with appropriate number of spaces, and escaping characters
	 appropriately"

	<category: 'accessing/delegating'>
	self nextPutAllText: anObject storeString
    ]

    skip: skip [
	"Move by skip bytes in the file-out"

	<category: 'accessing/delegating'>
	destination skip: skip
    ]

    position [
	"Answer the current position in the file-out"

	<category: 'accessing/delegating'>
	^destination position
    ]

    position: position [
	"Move the pointer in the file-out to the given position"

	<category: 'accessing/delegating'>
	destination position: position
    ]

    methodDictionary [
	"Answer the method dictionary for the class we're working on"

	<category: 'accessing/delegating'>
	^self currentClass methodDictionary
    ]

    selectorAndBody: methodString [
	"Answer a two-element Array containing the selector and the
	 body of the method, as they appear in methodString"

	<category: 'useful parsing'>
	| sel body ch split start pos |
	start := self skipWhite: 1 on: methodString.
	ch := methodString at: start.
	split := ch isAlphaNumeric 
		    ifTrue: [self parseUnaryOrKeyword: methodString from: start]
		    ifFalse: 
			[pos := self skipToWhite: start on: methodString.
			pos := self skipWhite: pos on: methodString.
			pos := self skipIdentifier: pos on: methodString.
			self skipPastNewline: pos on: methodString].
	sel := methodString copyFrom: start to: split - 1.
	body := split > methodString size 
		    ifFalse: [methodString copyFrom: split to: methodString size]
		    ifTrue: [''].
	^Array with: sel trimSeparators with: body
    ]

    skipToWhite: start on: string [
	"Answer the position of the first non-white character in string, starting
	 the scan at position start"

	<category: 'useful parsing'>
	| pos |
	pos := start.
	
	[pos > string size ifTrue: [^pos].
	(string at: pos) isSeparator] 
		whileFalse: [pos := pos + 1].
	^pos
    ]

    skipWhiteExceptNewlines: stream [
	"Skip up to next non-separator or newline.  Answer whether stream
	 is not at end afterwards."

	<category: 'useful parsing'>
	
	[| char |
	stream atEnd ifTrue: [^false].
	char := stream next.
	char isSeparator 
	    and: [(##(
		{Character nl.
		Character cr} asString) includes: char) not]] 
		whileTrue.
	stream skip: -1.
	^true
    ]

    skipWhite: start on: string [
	"Answer the position of the first white character in string, starting
	 the scan at position start"

	<category: 'useful parsing'>
	| pos |
	pos := start.
	
	[pos > string size ifTrue: [^pos].
	(string at: pos) isSeparator] 
		whileTrue: [pos := pos + 1].
	^pos
    ]

    skipWhite: stream [
	"Skip everything up to the first white character in stream. Answer
	 true if a non-white character was found before the end of the stream"

	<category: 'useful parsing'>
	
	[stream atEnd ifTrue: [^false].
	stream next isSeparator] whileTrue: [].
	stream skip: -1.
	^true
    ]

    skipIdentifier: start on: string [
	"Answer the position of the first non-alphanumeric character in string,
	 starting the scan at position start"

	<category: 'useful parsing'>
	| pos |
	pos := start.
	
	[pos > string size ifTrue: [^pos].
	(string at: pos) isAlphaNumeric] 
		whileTrue: [pos := pos + 1].
	^pos
    ]

    skipPastNewline: start on: string [
	"Answer the position of the first white character (not including new-line
	 characters) in string, starting the scan at position start"

	<category: 'useful parsing'>
	| pos ch |
	pos := start.
	
	[ch := string at: pos.
	ch isSeparator and: [ch ~~ Character nl]] 
		whileTrue: [pos := pos + 1].
	ch == Character nl ifTrue: [pos := pos + 1].
	^pos
    ]

    parseUnaryOrKeyword: string from: start [
	"Parse a message selector from string."

	<category: 'useful parsing'>
	| pos ch tempPos |
	pos := self skipIdentifier: start on: string.
	pos > string size ifTrue: [^string size + 1].
	ch := string at: pos.
	ch == $: 
	    ifFalse: 
		["Got a unary selector"

		pos := self skipPastNewline: pos on: string.
		^pos].
	pos := start.
	
	[tempPos := self skipWhite: pos on: string.
	tempPos > string size ifTrue: [^string size + 1].
	ch := string at: tempPos.
	"make sure we have a valid keyword identifier to start"
	ch isLetter ifFalse: [^self skipPastNewline: pos on: string].
	tempPos := self skipIdentifier: tempPos on: string.
	tempPos > string size ifTrue: [^string size + 1].
	ch := string at: tempPos.
	ch == $: ifFalse: [^self skipPastNewline: pos on: string].

	"parsed a keyword, expect an identifier next"
	tempPos := self skipWhite: tempPos + 1 on: string.
	tempPos > string size ifTrue: [^string size + 1].
	ch := string at: tempPos.
	ch isLetter ifFalse: [^self skipPastNewline: pos on: string].
	pos := self skipIdentifier: tempPos on: string.
	pos > string size ifTrue: [^string size + 1].
	true] 
		whileTrue
    ]

    reformatComment: source [
	"I extract a comment from source, which is a stream pointing right after
	 a double quote character."

	<category: 'useful parsing'>
	| comment input |
	input := source upTo: $".
	comment := WriteStream on: (String new: input size).
	input := ReadStream on: input.
	[input atEnd] whileFalse: 
		[comment nextPutAll: (input upTo: Character nl).
		comment nl.
		self skipWhiteExceptNewlines: input].
	^comment contents
    ]

    extractComment: source [
	"I seek a starting comment in source, which is a method's source code.
	 If I cannot find it, I try to guess one, else I answer the comment."

	<category: 'useful parsing'>
	| isCommented comment |
	comment := ReadStream on: source.
	self skipWhite: comment.
	isCommented := comment peekFor: $".

	"Check for new syntax."
	isCommented 
	    ifFalse: 
		[comment peekFor: $[.
		self skipWhite: comment.
		isCommented := comment peekFor: $"].

	"Maybe they put temporaries *before* the method comment..."
	isCommented 
	    ifFalse: 
		[(comment peekFor: $|) 
		    ifTrue: 
			[comment skipTo: $|.
			isCommented := comment atEnd not and: 
					[self skipWhite: comment.
					comment peekFor: $"]]].
	^isCommented 
	    ifTrue: [self reformatComment: comment]
	    ifFalse: [self guessComment: comment contents]
    ]

    guessComment: source [
	"I look at source, which has no starting comment, and try to guess a comment"

	<category: 'useful parsing'>
	| n m start |
	(source indexOfSubCollection: 'shouldNotImplement') > 0 
	    ifTrue: [^'This method should not be called for instances of this class.'].
	(source indexOfSubCollection: 'notYetImplemented') > 0 
	    ifTrue: [^'This method''s functionality has not been implemented yet.'].
	(source indexOfSubCollection: 'subclassResponsibility') > 0 
	    ifTrue: 
		[^'This method''s functionality should be implemented by subclasses of ' 
		    , self currentClass asClass printString].
	n := 1.
	
	[n := self skipWhite: n on: source.
	(n > source size or: [']"' includes: (source at: n)]) 
	    ifTrue: [^'Answer the receiver.'].
	m := self skipToWhite: n on: source.
	start := source copyFrom: n to: m - 1.
	n := self skipWhite: m on: source.
	(start notEmpty and: 
		[(start at: 1) = $^ 
		    and: [n > source size or: [']"' includes: (source at: n)]]]) 
	    ifTrue: 
		[start = '^self' ifTrue: [^'Answer the receiver.'].
		^'Answer `' , (start copyFrom: 2 to: start size) , '''.'].
	n <= source size 
	    ifTrue: 
		[(source at: n) = $< 
		    ifTrue: [n := source indexOf: $> startingAt: n]
		    ifFalse: [(']"' includes: (source at: n)) ifFalse: [^'Not commented.']].
		n := n + 1]] 
		repeat
    ]
]



"----------------------------------------------------------------------"



ClassPublisher subclass: DocPublisher [
    | categories |
    
    <category: 'Examples-File out'>
    <comment: nil>

    DocPublisher class >> printHierarchyOf: classes on: aFileStream [
	"Typeset on aFileStream a full hierarchy tree, starting from the classes
	 in the given Collection"

	<category: 'printing trees'>
	self makeDescendentsDictionary: (self makeFullTree: classes)
	    thenPrintOn: aFileStream
    ]

    DocPublisher class >> printHierarchyOf: dict hierarchy: desc startAt: root on: aFileStream indent: indent [
	"Recursive worker method for #printHierarchyOf:on:
	 dict is the classes Dictionary as obtained by makeFullTree:,
	 desc is the classes Dictionary as passed by makeDescendentsDictionary:thenPrintOn:"

	<category: 'printing trees'>
	| subclasses |
	subclasses := desc at: root.
	subclasses := self sortClasses: subclasses.
	subclasses do: 
		[:each | 
		self 
		    printTreeClass: each
		    shouldLink: (dict at: each)
		    on: aFileStream
		    indent: indent.
		self 
		    printHierarchyOf: dict
		    hierarchy: desc
		    startAt: each
		    on: aFileStream
		    indent: (indent copyWith: $ )]
    ]

    DocPublisher class >> printTreeClass: class shouldLink: aBoolean on: aFileStream indent: indent [
	"Abstract - do nothing by default"

	<category: 'printing trees'>
	
    ]

    DocPublisher class >> sortClasses: collection [
	<category: 'printing trees'>
	^collection asSortedCollection: 
		[:a :b | 
		(a nameIn: Namespace current) <= (b nameIn: Namespace current)]
    ]

    DocPublisher class >> makeFullTree: classes [
	"From the classes collection, create a Dictionary in which we ensure
	 that every key's superclass is also a key.  For example, if
	 classes contained Object and Array, the dictionary would also have
	 Collection, SequenceableCollection and ArrayedCollection as keys.
	 For every key, its value is true if classes includes it, else it is
	 false."

	<category: 'printing trees'>
	| dict newClasses checkClasses |
	dict := LookupTable new: classes size.
	classes do: [:each | dict at: each put: true].
	checkClasses := dict keys.
	
	[newClasses := Set new.
	checkClasses do: 
		[:each | 
		each superclass isNil 
		    ifFalse: 
			[(dict includesKey: each superclass) 
			    ifFalse: [newClasses add: each superclass]]].
	newClasses isEmpty] 
		whileFalse: 
		    [newClasses do: [:each | dict at: each put: false].
		    checkClasses := newClasses].
	^dict
    ]

    DocPublisher class >> makeDescendentsDictionary: dict thenPrintOn: aFileStream [
	"From the dict Dictionary, created by #makeFullTree:, create
	 another with the same keys.  Each key is associated to a set of
	 classes which are all the immediate subclasses which are also
	 keys of dict.  Then this dictionary is passed to the recursive
	 method #printHierarchyOf:hierarchy:startAt:on:"

	<category: 'printing trees'>
	| descendents |
	descendents := dict collect: [:each | Set new].
	descendents at: #none put: Set new.
	dict keysDo: 
		[:each | 
		each superclass isNil 
		    ifTrue: [(descendents at: #none) add: each]
		    ifFalse: [(descendents at: each superclass) add: each]].
	self 
	    printHierarchyOf: dict
	    hierarchy: descendents
	    startAt: #none
	    on: aFileStream
	    indent: ''
    ]

    emitMethod: source [
	<category: 'abstract'>
	
    ]

    emitMethodSelector: source [
	<category: 'abstract'>
	
    ]

    emitSelectorAndMethod: association [
	<category: 'abstract'>
	self emitMethodSelector: association key.
	self emitMethod: association value
    ]

    emitIndexFooter [
	<category: 'abstract'>
	
    ]

    emitLink: category kind: kind [
	<category: 'abstract'>
	
    ]

    emitAfterNode [
	<category: 'abstract'>
	
    ]

    emitNode: index category: category [
	<category: 'abstract'>
	
    ]

    namespaceFor: aClass [
	"aClass is being published. Answer the namespace to be used when producing
	 names; by default, this is the current namespace for documentation
	 publishers."

	<category: 'abstract'>
	^Namespace current
    ]

    categoriesSize [
	<category: 'accessing'>
	^categories size
    ]

    categoryAt: n [
	<category: 'accessing'>
	^(categories at: n) key
    ]

    categoryAt: n ifBadIndex: aString [
	<category: 'accessing'>
	n < 1 ifTrue: [^aString].
	n > categories size ifTrue: [^aString].
	^(categories at: n) key
    ]

    emitCategory: category [
	"I emit a link to the anchor where the category will be, and store
	 enough information so that they'll be able to generate the actual
	 output."

	<category: 'subclassed'>
	| categoryMethods methods kind private |
	private := category indexOfSubCollection: 'private' startingAt: 1.
	private = 0 ifFalse: [^self].
	kind := self currentClass isMetaclass 
		    ifTrue: [' (class)']
		    ifFalse: [' (instance)'].
	methods := self methodDictionary 
		    select: [:each | each methodCategory = category].
	categoryMethods := OrderedCollection new.
	methods associationsDo: 
		[:assoc | 
		assoc value methodSourceString isNil 
		    ifFalse: [categoryMethods add: assoc key -> assoc value methodSourceString]].
	categoryMethods := categoryMethods asSortedCollection: [ :a :b |
	    (a key caseSensitiveCompareTo: b key) <= 0 ].
	categories add: (category , kind) -> categoryMethods.
	self emitLink: category kind: kind
    ]

    emitFooter [
	"In addition to the footer, I emit the actual documentation based on data
	 collected by #emitCategory:."

	<category: 'subclassed'>
	self emitIndexFooter.
	categories doWithIndex: 
		[:each :index | 
		self emitNode: index category: each key.
		each value do: [:assoc | self emitSelectorAndMethod: assoc].
		self emitAfterNode]
    ]
]
