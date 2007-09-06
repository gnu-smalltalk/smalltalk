"======================================================================
|
|   Regression tests for File
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003, 2007  Free Software Foundation.
| Written by Paolo Bonzini, based on test vectors by Nicolas Pelletier.
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

Object extend [

    testCaseData [
        | extensions |
        extensions := OrderedCollection new.
        extensions
            add: '' -> '';
            add: '.' -> '';
            add: '/' -> '';
            add: 'text' -> '';
            add: 'text.' -> '.';
            add: '.text' -> '';
            add: 'text/' -> '';
            add: '/text' -> '';
            add: '/.' -> '';
            add: './' -> '';
            add: 'file.ext' -> '.ext';
            add: 'file.ext.' -> '.';
            add: '.file.ext' -> '.ext';
            add: 'file.ext/' -> '';
            add: '/file.ext' -> '.ext';
            add: '/.file.ext' -> '.ext';
            add: './file.ext' -> '.ext';
            add: 'dir/file' -> '';
            add: 'dir/file.' -> '.';
            add: 'dir/.file' -> '';
            add: 'dir/file.ext' -> '.ext';
            add: 'dir/file.ext.' -> '.'.
    
         ^extensions
    ]

    testExtensionFor [
    
       self testCaseData do: [:each |
	    [(File extensionFor: each key) = each value] value printNl ]
    ]

    testStripExtensionFrom [
    
       "(File stripExtensionFrom: aString),
        (File extensionFor: aString) = aString"
    
       self testCaseData do: [:each |
	    [(File stripExtensionFrom: each key),
	     (File extensionFor: each key) = each key] value printNl ]
    ]
]

Eval [
    CSymbols.PathSeparator := $/.
    Object new testExtensionFor; testStripExtensionFrom
]
