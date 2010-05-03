"======================================================================
|
|   GNU Smalltalk profiling tool
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
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

PackageLoader fileInPackage: 'ProfileTools'.
DLD addLibrary: 'libc'.

SystemDictionary extend [
    SmalltalkArgv := OrderedCollection new.
]

| helpString output profiler profilerClass last |
commands := OrderedCollection new.
output := nil.
profilerClass := CallGraphProfiler.

helpString :=
'Usage:
    gst-profile [ flag ... ] [FILE ARGS]

Options:
    -f --file=FILE            file in FILE
    -e --eval=CODE            evaluate CODE
    -o --output=FILE          output file for callgrind_annotate
    -h --help                 show this message
    -v --verbose              print extra information while processing
       --no-separate-blocks   do not track blocks separately
       --version              print version information and exit

FILE is always parsed, even if --file or --eval are used.  It is also
always parsed last.  Use /dev/null to pass arguments directly to --file
or --eval options.

'.

"Parse the command-line arguments."
[Smalltalk
    arguments: '-f|--file: -e|--eval: -o|--output: -h|--help --version
		--no-separate-blocks -v|-V|--verbose'
    do: [ :opt :arg |

    opt = 'help' ifTrue: [
	helpString displayOn: stdout.
	ObjectMemory quit: 0 ].

    opt = 'no-separate-blocks' ifTrue: [
	profilerClass := MethodCallGraphProfiler ].

    opt = 'version' ifTrue: [
	('gst-profile - %1' % {Smalltalk version}) displayNl.
	ObjectMemory quit: 0 ].

    opt = 'output' ifTrue: [
	output isNil ifFalse: [ self error: 'multiple output files' ].
	output := arg ].

    opt = 'file' ifTrue: [
	commands add: (File name: arg) ].

    opt = 'eval' ifTrue: [
	commands add: arg ].

    opt = 'verbose' ifTrue: [
	OutputVerbosity := 1.
	FileStream verbose: true
    ].

    opt isNil ifTrue: [
	last isNil
	    ifTrue: [ last := arg ]
	    ifFalse: [ SystemDictionary.SmalltalkArgv addLast: arg ] ].
    ]

    ifError: [
        helpString displayOn: stderr.
        ObjectMemory quit: 1 ].

    last isNil ifFalse: [
	commands add: (File name: last) ].

    commands isEmpty ifTrue: [ self error: 'no commands given' ]
	] on: Error do: [ :ex |
	    ('gst-profile: ', ex messageText, '
') displayOn: stderr.
	    stderr flush.
	    helpString displayOn: stderr.
	    ObjectMemory quit: 1 ].

SystemDictionary compile:
    'getpid [ <cCall: ''getpid'' returning: #int args: #()> ]'.
SystemDictionary compile:
    'arguments [ ^SmalltalkArgv asArray ]'.

profiler := profilerClass new.
output isNil ifTrue: [
    output := Directory working / ('gst-profile.%1' % { Smalltalk getpid }) ].

commands do: [ :each |
    "Using #readStream makes it work both for Strings and Files.
     TODO: use hooks instead, maybe directly in Profiler?."
    profiler withProfilerDo: [ each readStream fileIn ] ].

profiler printCallGraphToFile: output.
