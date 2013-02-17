
"======================================================================
|
|   Regression tests for Streams
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2012 Free Software Foundation.
| Written by Holger Hans Peter Freyther.
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

Eval [
    | concat streamA streamB |
    streamA := '123' readStream.
    streamB := '456' readStream.
    concat := streamA, streamB.

    "Should print 123"
    concat next printNl.
    concat next printNl.
    concat next printNl.
    (concat copyFrom: 0 to: 2) printNl.
    
    "Should print 45"
    concat next printNl.
    concat next printNl.
    (concat copyFrom: 3 to: 5) printNl.

    "Should print 6"
    concat next printNl.
    concat atEnd printNl.
    (concat copyFrom: 3 to: 5) printNl.

    concat stream printNl.
]

Eval [
    | concat |
    "Should print Array"
    concat := Kernel.ConcatenatedStream new.
    concat species printNl.

    "Should print UndefinedObject"
    concat := Kernel.ConcatenatedStream with: '' readStream.
    concat species printNl.

    "Should print String"
    concat := Kernel.ConcatenatedStream with: ' ' readStream.
    concat species printNl.

    "Should print String and then Array"
    concat := Kernel.ConcatenatedStream with: '1' readStream with: #(2) readStream.
    concat species printNl.
    concat next printNl.
    concat species printNl.
    concat next printNl.
]
