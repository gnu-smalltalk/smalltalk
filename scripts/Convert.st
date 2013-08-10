"======================================================================
|
|   Smalltalk syntax conversion tool
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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

PackageLoader fileInPackage: #STTools.

STInST.OldSyntaxExporter class extend [
    emitEval: aBlock to: aStream for: namespace [
        namespace isNil
            ifFalse: [ aStream nextPutAll: 'Namespace current: ';
		       store: namespace; nextPut: $!; nl ].

	aBlock value.
        aStream nextPut: $!; nl; nl.
    ]
]

STInST.SqueakSyntaxExporter class extend [
    emitEval: aBlock to: aStream for: namespace [
	aBlock value.
	aStream nextPut: $!; nl; nl.
    ]
]

STInST.NewSyntaxExporter class extend [
    emitEval: aBlock to: aStream for: namespace [
        namespace isNil
            ifTrue: [ aStream nextPutAll: 'Eval' ]
            ifFalse: [ aStream nextPutAll: 'Namespace current: ';
		       store: namespace ].

	    aStream nextPutAll: ' ['.
	    aBlock value.
            aStream nl; nextPut: $]; nl; nl.
    ]
]

String extend [
   asFilterOn: aBlock through: valueBlock [
	| regex |
	self first = $+ ifTrue: [
	    regex := self allButFirst asRegex.
	    ^[ :obj | (aBlock value: obj)
			 or: [ (valueBlock value: obj) ~ regex ] ] ].

	self first = $- ifTrue: [
	    regex := self allButFirst asRegex.
	    ^[ :obj | (aBlock value: obj)
			 and: [ ((valueBlock value: obj) ~ regex) not ] ] ].

	regex := self asRegex.
	^[ :obj | (aBlock value: obj) and: [ (valueBlock value: obj) ~ regex ] ]
    ]
]


STTools.Loader subclass: SyntaxConverter [
    <category: 'Converter'>

    SyntaxConverter class >> fixComment: aClass [
        | comment result readStream |
        "Fixes for carriage return in Pharo comments."
        comment := aClass comment.
        comment ifNil: [^self].

        result := WriteStream on: String new.
        readStream := comment readStream.

        "Replace \r with \n but only if there is no \r\n"
        [readStream atEnd] whileFalse: [
            | char |
            char := readStream next.
            (char = Character cr and: [(readStream peek = Character nl) not])
                ifTrue: [char := Character nl].
            result nextPut: char].

        "Update the comment"
        aClass comment: result contents.
    ]

    doEmitStuff [
        classesToEmit keysAndValuesDo: [:key :value |
            self class fixComment: key].
        super doEmitStuff.
    ]
]

Eval [ 
    | helpString inFile outFile quiet verbose converter filter parser
	args inFormats outFormats rules |

    args := OrderedCollection new.
    parser := STInST.STFileInParser.
    quiet := false.
    verbose := false.
    outFile := nil.
    filter := [ :class | true ].
    converter := SyntaxConverter new.
    STInST.FileOutExporter defaultExporter: STInST.FormattingExporter.
    outFormats := Dictionary from: {
	'gst2' -> STInST.OldSyntaxExporter.
	'gst' -> STInST.FormattingExporter.
	'squeak' -> STInST.SqueakSyntaxExporter.
    }.
    inFormats := Dictionary from: {
	'gst2' -> STInST.STFileInParser.
	'gst' -> STInST.GSTFileInParser.
	'squeak' -> STInST.SqueakFileInParser.
	'sif' -> STInST.SIFFileInParser
    }.
    rules := OrderedCollection new.
    
    helpString :=
'Usage:
    gst-convert [OPTION]... [INFILE [OUTFILE]]
    gst-convert [OPTION]... -o|--output OUTFILE INFILES

Options:
    -q, --quiet               don''t show any message
    -v, --verbose             print extra information while processing
    -f, --format=FORMAT       convert from given input format (supported
                              formats are %1)
    -F, --output-format=FORMAT convert to given output format (supported
                              formats are %2)
    -C, --class=REGEX         convert only classes matching REGEX
    -C, --class=+REGEX        in addition, convert classes matching REGEX
    -C, --class=-REGEX        do not convert classes matching REGEX
    -c, --category=REGEX      convert only classes whose category matches REGEX
    -c, --category=+REGEX     in addition, convert those whose category
                              matches REGEX
    -c, --category=-REGEX     do not convert classes whose category
                              matches REGEX
    -r, --rule=''CODE->REPL''   look for CODE and replace it with REPL

    -o, --output OUTFILE      concatenate multiple input files into a single
                              converted output file
        --help                display this message and exit
        --version             print version information and exit

' % {inFormats keys asSortedCollection fold: [ :a :b | a, ', ', b ].
     outFormats keys asSortedCollection fold: [ :a :b | a, ', ', b ]}.

    Smalltalk
        arguments: '-h|--help --version -q|--quiet -v|-V|--verbose -r|--rule:
		    -C|--class: -c|--category: -f|--format: -o|--output:
		    -F|--output-format: -I|--image-file: --kernel-directory:'
        do: [ :opt :arg |
	    opt = 'help' ifTrue: [
	        helpString displayOn: stdout.
	        ObjectMemory quit: 0 ].

	    opt = 'version' ifTrue: [
	        ('gst-convert - %1' % {Smalltalk version}) displayNl.
	        ObjectMemory quit: 0 ].

	    opt = 'quiet' ifTrue: [
		quiet := true.
		verbose := false ].

	    opt = 'verbose' ifTrue: [
		quiet := false.
		verbose := true ].

	    opt = 'output' ifTrue: [
		outFile isNil ifFalse: [
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ].
		outFile := arg ]. 

	    opt = 'rule' ifTrue: [
		rules add: arg].

	    opt = 'class' ifTrue: [
		[ 'a' ~ arg ] on: Error do: [ :ex |
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ].

		filter := arg
		    asFilterOn: filter
		    through: [ :class | class asClass nameIn: Smalltalk ] ].

	    opt = 'category' ifTrue: [
		[ 'a' ~ arg ] on: Error do: [ :ex |
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ].

		filter := arg
		    asFilterOn: filter
		    through: [ :class | class category ifNil: [ '' ] ] ].

	    opt = 'output-format' ifTrue: [
		STInST.FileOutExporter defaultExporter:
		    (outFormats at: arg ifAbsent: [
		        helpString displayOn: stderr.
		        ObjectMemory quit: 1 ]) ].

	    opt = 'format' ifTrue: [
		parser := inFormats at: arg ifAbsent: [
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ] ].

	    opt isNil ifTrue: [
		args addLast: arg ].
        ]

        ifError: [
            helpString displayOn: stderr.
            ObjectMemory quit: 1 ].

    "Post process the rules now we know the target."
    rules do: [:rule |
	converter addRule: rule parser: parser].

    [
        outFile isNil
	    ifTrue: [
	        args size > 2 ifTrue: [
	            helpString displayOn: stderr.
	            ObjectMemory quit: 1 ].

	        inFile := (args size = 0 or: [ args first = '-' ])
		    ifTrue: [ stdin ]
		    ifFalse: [ FileStream open: args first mode: FileStream read ].
	        outFile := (args size <= 1 or: [ args last = '-' ])
		    ifTrue: [ stdout ]
		    ifFalse: [ FileStream open: args last mode: FileStream write ] ]
	    ifFalse: [
		args := args collect: [ :f |
		    f = '-'
			ifTrue: [ stdin ]
			ifFalse: [ FileStream open: f mode: FileStream read ] ].
		inFile := args fold: [ :a :b | a, b ].

	        outFile := outFile = '-'
		    ifTrue: [ stdout ]
		    ifFalse: [ FileStream open: outFile mode: FileStream write ] ].

	converter filter: filter.
	converter
	    convertStream: inFile
	    with: parser
	    to: outFile.

	inFile close.
	outFile close
    ]
	on: Notification do: [ :ex |
	    verbose ifTrue: [ stderr nextPutAll: 'gst-convert: ', ex messageText; nl; flush ].
	    ex resume ]
	on: Warning do: [ :ex |
	    quiet ifFalse: [ stderr nextPutAll: 'gst-convert: warning: ', ex messageText; nl; flush ].
	    ex resume ]
	on: Error do: [ :ex |
	    stderr nextPutAll: 'gst-convert: error: ', ex messageText; nl; flush.
	    outFile = stdout ifFalse: [
	        outFile close.

		"TODO: don't do this on non-regular files.  It will make
		 /dev/null disappear if you run gst-convert as root (which
		 you shouldn't)."
		[ (File name: outFile name) remove ] on: Error do: [ :ex | ] ].
	    "ex pass." ObjectMemory quit: 1 ].
]
