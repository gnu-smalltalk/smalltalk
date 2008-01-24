"======================================================================
|
|   Smalltalk documentation publisher (utility script)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2004, 2005, 2007, 2008 Free Software Foundation, Inc.
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

| package outFile publisher files classes classPatterns loader defaultNamespace |

classPatterns := OrderedCollection new.
publisher := STInST.TexinfoDocPublisher.
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
    -h --help             show this message
       --version          print version information and exit
'.

[
    loader := STInST.STClassLoader new.
    Namespace current: Smalltalk.

    "Parse the command-line arguments."
    Smalltalk
        arguments: '-h|--help --version -p|--package: -f|--file: -n|--namespace:
                    -I|--image-file: -o|--output: --kernel-directory:'
        do: [ :opt :arg |

        opt = 'help' ifTrue: [
            helpString displayOn: stdout.
            ObjectMemory quit: 0 ].

        opt = 'version' ifTrue: [
            ('gst-doc - %1' % {Smalltalk version}) displayNl.
            ObjectMemory quit: 0 ].

        opt = 'output' ifTrue: [
	    outFile isNil ifFalse: [
	        self error: '--output specified multiple times' ].
	    outFile := arg ].

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
	    files do: [ :each || file |
	        file := FileStream open: each mode: FileStream read.
	        loader
	            parseSmalltalkStream: file
	            with: STInST.GSTFileInParser ].

	    loader currentNamespace: defaultNamespace ].

        opt = 'file' ifTrue: [
	    file := FileStream open: arg mode: FileStream read.
	    loader
	        parseSmalltalkStream: file
	        with: STInST.GSTFileInParser ].

        opt isNil ifTrue: [ classPatterns add: arg ] ]

        ifError: [
            helpString displayOn: stderr.
            ObjectMemory quit: 1 ].

    classPatterns isEmpty
        ifTrue: [
            classes := loader fullyDefinedLoadedClasses.
            classes isEmpty
	        ifTrue: [ self error: 'specify -p, -f, or a class name' ] ]
        ifFalse: [
	    allClasses :=
	        loader fullyDefinedLoadedClasses,
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

    outFile isNil
        ifTrue: [
	    Transcript message: stderr -> #nextPutAllFlush:.
	    publisher publishAll: classes on: stdout ]
        ifFalse: [
	    publisher publishAll: classes onFile: outFile ]
]
    on: Error
    do: [ :ex |
        ('gst-doc: ', ex messageText, '
') displayOn: stderr.
        "ex pass." ObjectMemory quit: 1 ]!
