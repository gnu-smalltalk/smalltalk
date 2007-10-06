"======================================================================
|
|   Smalltalk command-line parser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
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



Object subclass: Getopt [
    | options longOptions prefixes args currentArg actionBlock errorBlock |
    
    <category: 'Language-Data types'>
    <comment: 'This class is usually not instantiated.  Class methods provide a way
to parse command lines from Smalltalk.'>

    Getopt class >> parse: args with: pattern do: actionBlock [
	"Parse the command-line arguments in args according to the syntax specified in
	 pattern.  For every command-line option found, the two-argument block
	 actionBlock is evaluated passing the option name and the argument.  For
	 file names (or in general, other command-line arguments than options) the
	 block's first argument will be nil.  For options without arguments, or with
	 unspecified optional arguments, the block's second argument will be nil.
	 The option name will be passed as a character object for short options,
	 and as a string for long options.
	 
	 If an error is found, nil is returned.  For more information on the syntax
	 of pattern, see #parse:with:do:ifError:."

	<category: 'instance creation'>
	^(self new)
	    parsePattern: pattern;
	    actionBlock: actionBlock;
	    errorBlock: [^nil];
	    parse: args
    ]

    Getopt class >> parse: args with: pattern do: actionBlock ifError: errorBlock [
	"Parse the command-line arguments in args according to the syntax specified in
	 pattern.  For every command-line option found, the two-argument block
	 actionBlock is evaluated passing the option name and the argument.  For
	 file names (or in general, other command-line arguments than options) the
	 block's first argument will be nil.  For options without arguments, or with
	 unspecified optional arguments, the block's second argument will be nil.
	 The option name will be passed as a character object for short options,
	 and as a string for long options.
	 
	 If an error is found, the parsing is interrupted, errorBlock is evaluated,
	 and the returned value is answered.
	 
	 Every whitespace-separated part (`word') of pattern specifies a command-line
	 option.  If a word ends with a colon, the option will have a mandatory argument.
	 If a word ends with two colons, the option will have an optional argument.
	 Before the colons, multiple option names (either short names like `-l' or
	 long names like `--long') can be specified.  Before passing the option to
	 actionBlock, the name will be canonicalized to the last one.
	 
	 Prefixes of long options are accepted as long as they're unique, and they are
	 canonicalized to the full name before passing it to actionBlock.  Additionally,
	 the full name of an option is accepted even if it is the prefix of a longer
	 option.
	 
	 Mandatory arguments can appear in the next argument, or in the same argument
	 (separated by an = for arguments to long options).  Optional arguments must
	 appear in the same argument."

	<category: 'instance creation'>
	^(self new)
	    parsePattern: pattern;
	    actionBlock: actionBlock;
	    errorBlock: [^errorBlock value];
	    parse: args
    ]

    fullOptionName: aString [
	"Answer the full name of a long option, expanding the prefixes to the
	 complete name.  If the option is invalid, errorBlock is evaluated."

	<category: 'private-parsing options'>
	(prefixes includes: aString) ifFalse: [errorBlock value].
	^longOptions detect: [:k | k startsWith: aString]
    ]

    optionKind: aString [
	"Answer the kind of option for aString.  The result is #noArg,
	 #mandatoryArg, or #optionArg.  If the option is invalid, errorBlock
	 is evaluated."

	<category: 'private-parsing options'>
	| kindOrString |
	kindOrString := options at: aString ifAbsent: errorBlock.
	^kindOrString isSymbol 
	    ifTrue: [kindOrString]
	    ifFalse: [options at: kindOrString]
    ]

    optionName: aString [
	"Answer the canonicalized name of the option for aString.
	 If the option is invalid, errorBlock is evaluated."

	<category: 'private-parsing options'>
	| kindOrString |
	kindOrString := options at: aString ifAbsent: errorBlock.
	^kindOrString isSymbol ifTrue: [aString] ifFalse: [kindOrString]
    ]

    parseRemainingArguments [
	"Parse the remaining arguments as non-options, invoking actionBlock
	 repeatedly."

	<category: 'private-parsing options'>
	[args atEnd] whileFalse: [actionBlock value: nil value: args next]
    ]

    parseOption: name kind: kind with: arg [
	"Look at kind and arg to see if we have to fetch the mandatory argument
	 from args.  Then invoke actionBlock with the given option name."

	<category: 'private-parsing options'>
	| theArg fullName |
	theArg := arg.
	(kind = #mandatoryArg and: [arg isNil]) 
	    ifTrue: 
		[args atEnd ifTrue: [errorBlock value].
		theArg := args next].
	(kind = #noArg and: [theArg notNil]) ifTrue: [errorBlock value].
	fullName := self optionName: name.
	actionBlock value: fullName value: theArg
    ]

    parseLongOption: argStream [
	"Parse the long option found in argStream.  argStream is pointing
	 just after the second minus."

	<category: 'private-parsing options'>
	| name kind haveArg arg |
	name := argStream upTo: $=.
	argStream skip: -1.
	name := self fullOptionName: name.
	kind := self optionKind: name.
	haveArg := argStream nextMatchFor: $=.
	arg := haveArg ifTrue: [argStream upToEnd] ifFalse: [nil].
	self 
	    parseOption: name
	    kind: kind
	    with: arg
    ]

    parseShortOptions: argStream [
	"Parse all the short options found in argStream.  argStream is pointing
	 just after the first minus."

	<category: 'private-parsing options'>
	| ch kind haveArg arg |
	[argStream atEnd] whileFalse: 
		[ch := argStream next.
		kind := self optionKind: ch.
		haveArg := kind ~~ #noArg and: [argStream atEnd not].
		arg := haveArg ifTrue: [argStream upToEnd] ifFalse: [nil].
		self 
		    parseOption: ch
		    kind: kind
		    with: arg]
    ]

    parseOneArgument [
	"Parse one command-line argument.  Actually note that if the argument
	 starts with -, that could be a) many short options for the one
	 argument b) one argument for the options, plus one argument for
	 an option's mandatory argument c) one argument with '--' that is
	 silently eaten, plus an arbitrary number of non-option arguments."

	<category: 'private-parsing options'>
	| arg argStream |
	arg := args next.
	arg = '--' ifTrue: [^self parseRemainingArguments].
	arg ~ '\A(-?$|[^-])' ifTrue: [^actionBlock value: nil value: arg].
	argStream := arg readStream.
	(arg at: 2) = $- 
	    ifTrue: 
		[argStream next: 2.
		self parseLongOption: argStream]
	    ifFalse: 
		[argStream next.
		self parseShortOptions: argStream]
    ]

    parse [
	"Parse all the arguments in the commandline."

	<category: 'private-parsing options'>
	[args atEnd] whileFalse: [self parseOneArgument]
    ]

    addLongOption: option [
	"Add the given long option name.  All the prefixes are kept in the
	 prefixes instance variable, including those that are common to more
	 than one option."

	<category: 'private-parsing patterns'>
	longOptions add: option.
	1 to: option size
	    do: [:length | prefixes add: (option copyFrom: 1 to: length)]
    ]

    rejectBadPrefixes [
	"Remove from prefixes those that are common to more than one long
	 option -- except if they aren't prefixes, but really the full long option
	 names.  Also turn longOptions into a sorted collection, so that when
	 we look for valid long option names, we see --foo before --foobar."

	<category: 'private-parsing patterns'>
	prefixes := prefixes asSet 
		    select: [:each | (prefixes occurrencesOf: each) == 1 or: [longOptions includes: each]].

	"Using this weird sort block would not be absolutely necessary, but it is
	 cool and emphasizes that we care only about seeing shorter options first."
	longOptions := longOptions asSortedCollection: [:a :b | a size <= b size]
    ]

    initialize [
	<category: 'private-parsing patterns'>
	options := Dictionary new.
	longOptions := Set new.
	prefixes := Bag new
    ]

    checkSynonyms: synonyms [
	"Check that the list of synonyms is made of valid options."

	<category: 'private-parsing patterns'>
	(synonyms allSatisfy: [:each | each startsWith: '-']) 
	    ifFalse: [^self error: 'expected -'].
	(synonyms anySatisfy: [:each | each size < 2 or: [each = '--']]) 
	    ifTrue: [^self error: 'expected option name'].
	synonyms do: 
		[:each | 
		((each startsWith: '--') and: [each includes: $=]) 
		    ifTrue: [^self error: 'unexpected = inside long option']]
    ]

    colonsToKind: colons [
	"Make a symbol stored in the options dictionary, based on the number
	 of colons at the end of a pattern."

	<category: 'private-parsing patterns'>
	colons = 0 ifTrue: [^#noArg].
	colons = 1 ifTrue: [^#mandatoryArg].
	colons = 2 ifTrue: [^#optionalArg].
	^self error: 'too many colons, don''t know what to do with them...'
    ]

    atSynonym: synonym put: kindOrName [
	"Store the given option name into the options dictionary. '-B' uses
	 $B as the key, '--long' uses 'long'.  Answer the key."

	<category: 'private-parsing patterns'>
	| key |
	synonym size = 2 
	    ifTrue: [key := synonym at: 2]
	    ifFalse: 
		[key := synonym copyFrom: 3.
		self addLongOption: key].
	(options includes: key) ifTrue: [self error: 'duplicate option'].
	options at: key put: kindOrName.
	^key
    ]

    atAllSynonyms: synonyms put: kind [
	"Associate the list of synonym option names with the given kind.
	 The last synonym is made the canonical name."

	<category: 'private-parsing patterns'>
	"Store the kind (a Symbol) only for the canonical name."

	| last |
	last := self atSynonym: synonyms last put: kind.

	"For the others, store the canonical name (a String)."
	synonyms 
	    from: 1
	    to: synonyms size - 1
	    do: [:each | self atSynonym: each put: last]
    ]

    parseOption: opt [
	"Parse one word of the option description syntax."

	<category: 'private-parsing patterns'>
	"Remove the colons"

	| colons optNames synonyms kind |
	optNames := opt copyWithout: $:.
	colons := opt size - optNames size.

	"Check that they were at the end."
	opt 
	    from: optNames size + 1
	    to: opt size
	    do: [:ch | ch = $: ifFalse: [^self error: 'invalid pattern, colons are hosed']].

	"Now complete the parsing."
	kind := self colonsToKind: colons.
	synonyms := optNames subStrings: $|.
	self checkSynonyms: synonyms.
	self atAllSynonyms: synonyms put: kind
    ]

    parsePattern: pattern [
	"Parse the given option description syntax."

	<category: 'private-parsing patterns'>
	self initialize.
	pattern subStrings do: [:opt | self parseOption: opt].
	self rejectBadPrefixes
    ]

    actionBlock: aBlock [
	<category: 'private-parsing patterns'>
	actionBlock := aBlock
    ]

    errorBlock: aBlock [
	<category: 'private-parsing patterns'>
	errorBlock := aBlock
    ]

    parse: argsArray [
	<category: 'private-parsing patterns'>
	args := argsArray readStream.
	self parse
    ]
]



SystemDictionary extend [

    arguments: pattern do: actionBlock [
	"Parse the command-line arguments according to the syntax specified in
	 pattern.  For every command-line option found, the two-argument block
	 actionBlock is evaluated passing the option name and the argument.  For
	 file names (or in general, other command-line arguments than options) the
	 block's first argument will be nil.  For options without arguments, or with
	 unspecified optional arguments, the block's second argument will be nil.
	 The option name will be passed as a character object for short options,
	 and as a string for long options.
	 
	 If an error is found, nil is returned.  For more information on the syntax
	 of pattern, see #arguments:do:ifError:."

	<category: 'command-line'>
	Getopt 
	    parse: self arguments
	    with: pattern
	    do: actionBlock
	    ifError: [^nil]
    ]

    arguments: pattern do: actionBlock ifError: errorBlock [
	"Parse the command-line arguments according to the syntax specified in
	 pattern.  For every command-line option found, the two-argument block
	 actionBlock is evaluated passing the option name and the argument.  For
	 file names (or in general, other command-line arguments than options) the
	 block's first argument will be nil.  For options without arguments, or with
	 unspecified optional arguments, the block's second argument will be nil.
	 The option name will be passed as a character object for short options,
	 and as a string for long options.
	 
	 If an error is found, the parsing is interrupted, errorBlock is evaluated,
	 and the returned value is answered.
	 
	 Every whitespace-separated part (`word') of pattern specifies a command-line
	 option.  If a word ends with a colon, the option will have a mandatory argument.
	 If a word ends with two colons, the option will have an optional argument.
	 Before the colons, multiple option names (either short names like `-l' or
	 long names like `--long') can be specified.  Before passing the option to
	 actionBlock, the name will be canonicalized to the last one.
	 
	 Prefixes of long options are accepted as long as they're unique, and they are
	 canonicalized to the full name before passing it to actionBlock.  Additionally,
	 the full name of an option is accepted even if it is the prefix of a longer
	 option.
	 
	 Mandatory arguments can appear in the next argument, or in the same argument
	 (separated by an = for arguments to long options).  Optional arguments must
	 appear in the same argument."

	<category: 'command-line'>
	Getopt 
	    parse: self arguments
	    with: pattern
	    do: actionBlock
	    ifError: [^errorBlock value]
    ]

]

