"======================================================================
|
|   GNUPlot bindings, examples
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

GPObject subclass: GNUPlotExamples [
    
    <category: 'GNUPlot-Tests and examples'>
    <comment: 'See class side for methods with examples'>

    GNUPlotExamples class >> example1 [
	| p |
	p := GNUPlot new.
	p plot
	    lines: #(1 2 3 4 5)
	    with: [:series | series params title: 'Title' ].
	^p asString
    ]

    GNUPlotExamples class >> example2 [
	^self example2On: nil
    ]

    GNUPlotExamples class >> example2On: file [
	| p |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: ((GPPngTerminal new)
		    size: 300 @ 300;
		    "colors: (GPTerminalColors new borders: Color darkGray); FIXME"
		    yourself).
	    p output: file
	].

	p plot
	    lines: #(1 5 2 8 3)
	    with: [:series | series params title: 'Title' ].
	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> threePlots [
	^self threePlotsOn: nil
    ]

    GNUPlotExamples class >> threePlotsOn: file [
	| p |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: ((GPPngTerminal new)
		    transparent: true;
		    size: 300 @ 300;
		    "colors: (GPTerminalColors new borders: Color darkGray); FIXME"
		    yourself).
	    p output: file
	].

	p plot
	    "first plot"
	    lines: #(1 5 2 8 3)
	    with: [:series | series params title: 'Zig-zag' ];

	    "second plot"
	    function: [ :x | x sin ];

	    "third plot, notice no title appears"
	    boxes: #(6 3 1 5 4).

	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> twoPlots [
	^self twoPlotsOn: nil
    ]

    GNUPlotExamples class >> twoPlotsOn: file [
	| p |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: ((GPPngTerminal new)
		    size: 300 @ 300;
		    "colors: (GPTerminalColors new borders: Color darkGray); FIXME"
		    yourself).
	    p output: file
	].

	p plot
	    lines: #(1 5 2 8 3)
	    with: [:series | series params title: 'Zig-zag' ];

	    "second plot"
	    function: [ :x | x sin ].

	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> fit [
	^self fitOn: nil
    ]

    GNUPlotExamples class >> fitOn: file [
	| p fit data |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: ((GPPngTerminal new)
		    transparent: true;
		    size: 300 @ 300;
		    "colors: (GPTerminalColors new borders: Color darkGray); FIXME"
		    yourself).
	    p output: file
	].

	data := #((0.1 0.2) (1 2) (2 1) (3 3) (4 2) (4.9 3.8)).

	p plot
	    points: data with: [ :series |
		series x: '$1' y: '$2' ];
	    function: [ :x |
		x fit: data to: [ :a :b | a * x + b ] name: 'f' ].

	Transcript display: p; nl.
	p execute
    ]
]
