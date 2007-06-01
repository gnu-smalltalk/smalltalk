"======================================================================
|
|   Smalltalk package loader (utility script)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2002, 2004 Free Software Foundation, Inc.
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

| helpString verbose snapshot force |
snapshot := true.
force := false.
verbose := FileStream verbose: false.

helpString :=
'Usage:
    gst-load [ flag ... ] package ...

Options:
    -q --quiet            hide the output
    -v --verbose          show loaded files
    -f --force            reload package if already loaded
    -n --dry-run          don''t save the image after loading
    -t --test             run SUnit tests if available
    -I --image-file=FILE  load into the specified image
    -h --help             show this message
'.

"Parse the command-line arguments."
Smalltalk
    arguments: '-h|--help -q|--quiet -v|-V|--verbose -n|--dry-run -f|--force
		-t|--test -I|--image-file:'
    do: [ :opt :arg |

    opt = 'help' ifTrue: [
	helpString displayOn: stderr.
	ObjectMemory quit: 0 ].

    opt = 'quiet' ifTrue: [
	OutputVerbosity := 0.
	FileStream verbose: false ].

    opt = 'verbose' ifTrue: [
	OutputVerbosity := 1.
	FileStream verbose: true ].

    opt = 'force' ifTrue: [
	force := true ].

    opt = 'dry-run' ifTrue: [
	snapshot := false ].

    opt isNil ifTrue: [
	[
	    force ifTrue: [ Smalltalk removeFeature: arg asSymbol ].
	    PackageLoader fileInPackage: arg ]
	    ifCurtailed: [ ObjectMemory quit: 1 ] ] ]

    ifError: [
	helpString displayOn: stderr.
	ObjectMemory quit: 1 ].

FileStream verbose: verbose.

snapshot ifTrue: [ ObjectMemory snapshot ]!

