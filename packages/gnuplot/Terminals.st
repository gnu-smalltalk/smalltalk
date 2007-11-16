"======================================================================
|
|   GNUPlot bindings, concrete terminal
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"


"The GPPngTerminal class is Copyright (c) 2007 Igor Stasenko
 and licensed under the X11 license.

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the `Software'), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE."

GPFileTerminal subclass: GPPngTerminal [
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that saves plots to a PNG file.'>

    | transparent interlace trueColor rounded font size enhanced |
    
    enhanced [
	<category: 'accessing'>
	^enhanced
    ]

    enhanced: aBoolean [
	<category: 'accessing'>
	enhanced := aBoolean
    ]

    font [
	<category: 'accessing'>
	^font
    ]

    font: aSymbolOrString [
	<category: 'accessing'>
	font := aSymbolOrString
    ]

    initialize [
	"Set default values"

	<category: 'initialize-release'>
	transparent := false.
	interlace := false.
	trueColor := true.
	rounded := true.
	font := #medium.
	size := 800 @ 600.
	enhanced := false.
    ]

    interlace [
	<category: 'accessing'>
	^interlace
    ]

    interlace: aBoolean [
	<category: 'accessing'>
	interlace := aBoolean
    ]

    printOptionsOn: str [
	<category: 'printing'>
	transparent ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'transparent '.
	interlace ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'interlace '.
	trueColor ifFalse: [str nextPutAll: 'no'].
	str
	    nextPutAll: 'truecolor ';
	    nextPutAll: (rounded ifTrue: ['rounded '] ifFalse: ['butt ']);
	    "font could be a one of: tiny | small | medium | large | giant , or font <face> {pointsize}"
	    nextPutAll: font;
	    nextPut: Character space;
	    nextPutAll: 'size ';
	    display: size x;
	    nextPut: $, ;
	    display: size y;
	    space.

	enhanced ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'enhanced '.
    ]

    rounded [
	<category: 'accessing'>
	^rounded
    ]

    rounded: aBoolean [
	<category: 'accessing'>
	rounded := aBoolean
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: aPoint [
	<category: 'accessing'>
	size := aPoint
    ]

    name [
	<category: 'printing'>
	^'png'
    ]

    transparent [
	<category: 'accessing'>
	^transparent
    ]

    transparent: aBoolean [
	<category: 'accessing'>
	transparent := aBoolean
    ]

    trueColor [
	<category: 'accessing'>
	^trueColor
    ]

    trueColor: aBoolean [
	<category: 'accessing'>
	trueColor := aBoolean
    ]
]
