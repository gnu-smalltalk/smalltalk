"======================================================================
|
|   Smalltalk SUnit runner (utility script)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2007, 2009 Free Software Foundation, Inc.
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

Smalltalk arguments isEmpty ifTrue: [ ObjectMemory quit ]!

Object subclass: SUnitUnhandledDebugger [
    <comment: 'I can be set as the debugger for un-handled exceptions
    and then pop-up a visual debugger'>

    LoadedDebugger := nil.

    SUnitUnhandledDebugger class >> open: aString [
        Transcript nextPutAll: 'Unhandled exception. Loading debugger.'; nl.
        self loadVisualGST.
        ((Smalltalk at: #VisualGST) at: #GtkDebugger) open: aString.
    ]

    SUnitUnhandledDebugger class >> debuggerClass [
        ^nil
    ]

    SUnitUnhandledDebugger class >> debuggingPriority [
        ^0
    ]

    SUnitUnhandledDebugger class >> loadVisualGST [
        LoadedDebugger ifNotNil: [^self].

        LoadedDebugger := true.
        PackageLoader fileInPackage: 'VisualGST'.

        "Start to run the VisualGST task queue"
        ((Smalltalk at: #VisualGST) at: #TaskQueue) uniqueInstance run.
    ]

    SUnitUnhandledDebugger class >> keepRunningOnFailure [
        "Check if we have loaded the debugger and then just keep running."
        LoadedDebugger ifNotNil: [self keepRunning]
    ]

    SUnitUnhandledDebugger class >> keepRunning [
        Processor activeProcess name: 'Main-loop for SUnit'.
        ((Smalltalk at: #GTK) at: #Gtk) main
    ]
]


PackageLoader fileInPackage: 'SUnit'!

| helpString verbose pkgScript script suite result quiet debug |
quiet := false.
verbose := false.
debug := false.
FileStream verbose: false.
script := ''.
pkgScript := ''.

helpString :=
'Usage:
    gst-sunit [ flag ... ] class.tests ...

Options:
    -q --quiet            hide the output
    -v --verbose          show passed tests
    -f --file=FILE        load file before running subsequent tests
    -p --package=PACKAGE  load package and run its tests
    -I --image-file=FILE  run tests on the specified image file
       --kernel-dir=PATH  use the specified kernel directory
    -h --help             show this message and exit
       --version          print version information and exit
    -d --debug            debug failing tests using VisualGST

'.

"Parse the command-line arguments."
Smalltalk
    arguments: '-h|--help -q|--quiet -v|-V|--verbose -f|--file: -p|--package:
		-I|--image-file: --kernel-directory: --version -d|--debug'
    do: [ :opt :arg |

    opt = 'help' ifTrue: [
	helpString displayOn: stdout.
	ObjectMemory quit: 0 ].

    opt = 'version' ifTrue: [
	('gst-sunit - %1' % {Smalltalk version}) displayNl.
	ObjectMemory quit: 0 ].


    opt = 'verbose' ifTrue: [
        OutputVerbosity := 1.
	quiet := false.
	verbose := true.
	FileStream verbose: true ].

    opt = 'quiet' ifTrue: [
        OutputVerbosity := 0.
	quiet := true.
	verbose := false.
	FileStream verbose: false ].

    opt = 'debug' ifTrue: [
        debug := true.
        Behavior compile: 'debuggerClass [ ^SUnitUnhandledDebugger]'
    ].

    opt = 'package' ifTrue: [
	[
	    | pkg |
	    pkg := (arg endsWith: '.xml')
		ifTrue: [ | tmp |
                    tmp := PackageLoader loadPackageFromFile: Directory working / arg.
                    PackageLoader insertPackage: tmp. tmp ]
		ifFalse: [ PackageLoader packageAt: arg ].
	    pkgScript := pkgScript, ' ', pkg sunitScript.
	    pkg test notNil ifTrue: [
		pkg := pkg test.
	        pkgScript := pkgScript, ' ', pkg sunitScript ].
	    pkg fileIn ]
	    ifCurtailed: [ ObjectMemory quit: 2 ] ].

    opt = 'file' ifTrue: [
	[ FileStream fileIn: arg ]
	    ifCurtailed: [ ObjectMemory quit: 2 ] ].

    opt isNil ifTrue: [
	script := script, ' ', arg ] ]

    ifError: [
	helpString displayOn: stderr.
	ObjectMemory quit: 1 ].

(script isEmpty and: [pkgScript isEmpty]) ifTrue: [ ObjectMemory quit ].
script isEmpty ifTrue: [script := pkgScript].

FileStream verbose: false.
(PackageLoader packageAt: #SUnit) loaded
    ifFalse: [
	stderr nextPutAll: 'gst-sunit: you should load SUnit first.'; nl.
	ObjectMemory quit: 1 ].

result := TestSuitesScripter run: script quiet: quiet verbose: verbose.
SUnitUnhandledDebugger keepRunningOnFailure.

result runCount = result passedCount ifFalse: [
    debug ifTrue: [
        Transcript nextPutAll: 'Tests failed. Loading graphical environment.'; nl.
        SUnitUnhandledDebugger loadVisualGST.
        Smalltalk VisualGST GtkSUnit results: result.
        SUnitUnhandledDebugger keepRunning].
    ObjectMemory quit: 1 ]!
