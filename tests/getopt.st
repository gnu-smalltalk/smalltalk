"======================================================================
|
|   Smalltalk command-line parser tests
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Getopt extend [
    Getopt class [
        test: args with: pattern [
            args do: [ :each |
                self
                    parse: each subStrings
                    with: pattern
                    do: [ :x :y | (x->y) printNl ]
                    ifError: [ (each->'error') displayNl ].
                Transcript nl ]
        ]
    ]

    testParsing: p [
        self parsePattern: p.
        prefixes asSortedCollection printNl.
        (options keys asSortedCollection: [ :a :b | a asString < b asString ])
	    do: [ :k | (options associationAt: k) printNl ]
    ]
]

Eval [ Getopt new testParsing: '-B' ]
Eval [ Getopt new testParsing: '--long' ]
Eval [ Getopt new testParsing: '--longish --longer' ]
Eval [ Getopt new testParsing: '--long --longer' ]
Eval [ Getopt new testParsing: '-B:' ]
Eval [ Getopt new testParsing: '-B::' ]
Eval [ Getopt new testParsing: '-a|-b' ]
Eval [ Getopt new testParsing: '-a|--long' ]
Eval [ Getopt new testParsing: '-a|--very-long|--long' ]
Eval [ Getopt test: #('-a' '-b' '-ab' '-a -b') with: '-a -b' ]
Eval [ Getopt test: #('-a' '-b' '-ab' '-a -b') with: '-a: -b' ]
Eval [ Getopt test: #('-a' '-b' '-ab' '-a -b') with: '-a:: -b' ]
Eval [ Getopt test: #('--longish' '--longer' '--longi' '--longe' '--lo' '-longer') with: '--longish --longer' ]
Eval [ Getopt test: #('--lo' '--long' '--longe' '--longer') with: '--long --longer' ]
Eval [ Getopt test: #('--noarg' '--mandatory' '--mandatory foo' '--mandatory=' '--mandatory=foo' '--optional' '--optional foo') with: '--noarg --mandatory: --optional::' ]
Eval [ Getopt test: #('-a' '-b') with: '-a|-b' ]
Eval [ Getopt test: #('--long' '-b') with: '-b|--long' ]
Eval [ Getopt test: #('--long=x' '-bx') with: '-b|--long:' ]
Eval [ Getopt test: #('-b' '--long' '--very-long') with: '-b|--very-long|--long' ]
Eval [ Getopt test: #('--long=x' '--very-long x' '-bx') with: '-b|--very-long|--long:' ]
Eval [ Getopt test: #('-b -- -b' '-- -b' '-- -b -b') with: '-b' ]
