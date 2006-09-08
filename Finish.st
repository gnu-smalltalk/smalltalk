"======================================================================
|
|   Smalltalk installation finishing touches (utility script)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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

"Invoked as Finish.st DESTDIR/PKGDATADIR PKGDATADIR [MODULES]..."

| ok |
ok := false.
[
    PackageLoader fileInPackages: (Smalltalk arguments copyFrom: 3).
    ok := true
] valueWithUnwind.

ok ifFalse: [ ObjectMemory quit: 1 ]!

"Symbol rebuildTable."

"Remove DESTDIR from the paths stored in the image"
| old new |
old := Smalltalk arguments first.
new := Smalltalk arguments at: 2.
old = new ifFalse: [ FileSegment relocateFrom: old to: new ].
KernelFilePath := new, '/kernel'!
