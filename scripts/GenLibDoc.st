#! /usr/bin/env gst -f

"======================================================================
|
|   Smalltalk documentation publisher (utility script)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2004, 2005 Free Software Foundation, Inc.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

"Load the prerequisites"
PackageLoader fileInPackage: 'Parser'.
FileStream fileIn: '../examples/Publish.st'.
FileStream fileIn: '../examples/StreamFilter.st'!

| namespace package outTexinfo rejected files dir source classes |
namespace := (Smalltalk arguments at: 1) asSymbol.
package := Smalltalk arguments at: 2.
outTexinfo := Smalltalk arguments at: 3.
rejected := (Smalltalk arguments copyFrom: 4) asSet.

"Load the list of files comprising the package"
dir := PackageLoader directoryFor: package.
files := PackageLoader filesFor: package.
files := files select: [ :each | '*.st' match: each ].
files := files reject: [ :each | rejected includes: each ].
files := files collect: [ :each | Directory append: each to: dir ].

"Load the source code"
source := files
    inject: ConcatenatedStream new
    into: [ :str :each | str, (FileStream open: each mode: FileStream read) ].

"Go!"
Smalltalk addSubspace: namespace.
Namespace current: (Smalltalk at: namespace).
classes := STInST.STClassLoader parseSmalltalkStream: source.
Namespace current: Smalltalk.
ClassPublisher.Texinfo publishAll: classes onFile: outTexinfo!
