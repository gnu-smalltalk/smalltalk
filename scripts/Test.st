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
PackageLoader fileInPackage: 'SUnit'!

| helpString verbose script suite result quiet |
quiet := false.
verbose := false.
FileStream verbose: false.
script := ''.

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

'.

"Parse the command-line arguments."
Smalltalk
    arguments: '-h|--help -q|--quiet -v|-V|--verbose -f|--file: -p|--package:
		-I|--image-file: --kernel-directory: --version'
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

    opt = 'package' ifTrue: [
	[
	    | pkg |
	    pkg := PackageLoader packageAt: arg.
	    script := script, ' ', pkg sunitScript.
	    pkg test notNil ifTrue: [
		pkg := pkg test.
	        script := script, ' ', pkg sunitScript ].
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

script isEmpty ifTrue: [ ObjectMemory quit ].

FileStream verbose: false.
(PackageLoader packageAt: #SUnit) loaded
    ifFalse: [
	stderr nextPutAll: 'gst-sunit: you should load SUnit first.'; nl.
	ObjectMemory quit: 1 ].

result := TestSuitesScripter run: script quiet: quiet verbose: verbose.

result runCount = result passedCount
    ifFalse: [ ObjectMemory quit: 1 ]!
