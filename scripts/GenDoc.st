"======================================================================
|
|   Smalltalk documentation publisher (utility script)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2004, 2005, 2007, 2008, 2009 Free Software Foundation, Inc.
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

"Load the prerequisites"
PackageLoader fileInPackage: #ClassPublisher!

| package location publisher files classes classPatterns loader defaultNamespace warnings |

classPatterns := OrderedCollection new.
warnings := Set new.
defaultNamespace := Smalltalk.

helpString :=
'Usage:
    gst-doc [ flag ... ] class ...

Options:
    -I --image-file=FILE  look for classes in the given image
    -p --package=PKG      look for classes in the given package
    -f --file=FILE        look for classes in the given file
    -n --namespace=NAMESP load files in the given namespace
    -o --output=FILE      emit documentation in the given file (default=stdout)
       --kernel-dir=PATH  use the specified kernel directory
    -F --output-format=KIND   use the given publisher (HTML or default=Texinfo)
    -h --help             show this message
    -v --verbose          print extra information while processing
       --version          print version information and exit

'.

[
    loader := STInST.STClassLoader new.
    Namespace current: Smalltalk.

    "Parse the command-line arguments."
    Smalltalk
        arguments: '-h|--help --version -p|--package: -f|--file: -n|--namespace:
                    -I|--image-file: -o|--output: --kernel-directory: -F|--output-format:
		    -v|-V|--verbose'
        do: [ :opt :arg |

        opt = 'help' ifTrue: [
            helpString displayOn: stdout.
            ObjectMemory quit: 0 ].

        opt = 'version' ifTrue: [
            ('gst-doc - %1' % {Smalltalk version}) displayNl.
            ObjectMemory quit: 0 ].

        opt = 'output' ifTrue: [
	    location isNil ifFalse: [
	        self error: '--output specified multiple times' ].
	    location := arg ].

	opt = 'namespace' ifTrue: [
            defaultNamespace := Smalltalk.
            (arg subStrings: $.) do:
                [:each |  
                | key |
                key := each asSymbol.
                (defaultNamespace includesKey: key)
		    ifFalse: [defaultNamespace addSubspace: key].
                defaultNamespace := defaultNamespace at: key].
	        loader currentNamespace: defaultNamespace ].

        opt = 'package' ifTrue: [
	    package := PackageLoader packageAt: arg.
	    loader currentNamespace: package createNamespace.
            files := package fullPathsOf: package fileIns.
	    files do: [ :each |
	        loader
	            parseSmalltalkStream: each readStream
	            with: STInST.GSTFileInParser ].

	    loader currentNamespace: defaultNamespace ].

        opt = 'file' ifTrue: [
	    loader
	        parseSmalltalkStream: arg asFile readStream
	        with: STInST.GSTFileInParser ].

        opt = 'output-format' ifTrue: [
            publisher isNil ifFalse: [
                self error: '--output-format specified multiple times' ].
            arg asLowercase = 'html'
                ifTrue: [ publisher := STInST.HTMLDocPublisher ]
                ifFalse: [
                    arg asLowercase = 'texinfo'
                        ifTrue: [ publisher:= STInST.TexinfoDocPublisher ]
                        ifFalse: [ self error: 'unknown --output-format arg' ] ] ].

	opt = 'verbose' ifTrue: [
	    OutputVerbosity := 1.
	    FileStream verbose: true ].

        opt isNil ifTrue: [ classPatterns add: arg ] ]

        ifError: [
            helpString displayOn: stderr.
            ObjectMemory quit: 1 ].

    publisher isNil ifTrue: [ publisher := STInST.TexinfoDocPublisher ].

    classPatterns isEmpty
        ifTrue: [
            classes := loader loadedClasses.
            classes isEmpty
	        ifTrue: [ self error: 'specify -p, -f, or a class name' ] ]
        ifFalse: [
	    allClasses :=
	        loader loadedClasses,
	        (Class allSubclasses collect: [ :each | each instanceClass ]).

	    classes := IdentitySet new.
	    classPatterns do: [ :pat || ns |
	        (pat last: 2) = '.*'
		    ifTrue: [
		        ns := pat allButLast: 2.
	                classes addAll:
			    (allClasses select: [ :each |
			        (each environment nameIn: Smalltalk) = ns ]) ]
		    ifFalse: [
	                classes addAll:
			    (allClasses select: [ :each |
			        pat match: (each nameIn: Smalltalk) ]) ] ] ].

    location isNil
        ifTrue: [
	    Transcript message: stderr -> #nextPutAllFlush:.
	    publisher publishAll: classes ]
        ifFalse: [
	    publisher publishAll: classes toLocation: location ]
]
    on: Warning
    do: [ :ex |
        (warnings includes: ex messageText) ifFalse: [
            warnings add: ex messageText.
            ('gst-doc: warning: ', ex messageText, '
') displayOn: Transcript ].
        ex resume ]

    on: Error
    do: [ :ex |
        ('gst-doc: ', ex messageText, '
') displayOn: stderr.
        "ex pass." ObjectMemory quit: 1 ]!
