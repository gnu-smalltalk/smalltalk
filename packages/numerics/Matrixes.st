"======================================================================
|
|   Numerical methods - Matrixes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbMatrix [
    | rows lupDecomposition |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbMatrix class >> join: anArrayOfMatrices [
	"Inverse of the split operation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/5/99"

	<category: 'creation'>
	| rows n row rowSize n1 n2 |
	rows := OrderedCollection new.
	n1 := (anArrayOfMatrices at: 1) numberOfColumns.
	n2 := n1 + 1.
	rowSize := n1 + (anArrayOfMatrices at: 2) numberOfColumns.
	n := 0.
	(anArrayOfMatrices at: 1) rowsDo: 
		[:each | 
		n := n + 1.
		row := DhbVector new: rowSize.
		row
		    replaceFrom: 1
			to: n1
			with: each
			startingAt: 1;
		    replaceFrom: n2
			to: rowSize
			with: ((anArrayOfMatrices at: 2) rowAt: n)
			startingAt: 1.
		rows add: row].
	n := 0.
	(anArrayOfMatrices at: 3) rowsDo: 
		[:each | 
		n := n + 1.
		row := DhbVector new: rowSize.
		row
		    replaceFrom: 1
			to: n1
			with: each
			startingAt: 1;
		    replaceFrom: n2
			to: rowSize
			with: ((anArrayOfMatrices at: 4) rowAt: n)
			startingAt: 1.
		rows add: row].
	^self rows: rows
    ]

    DhbMatrix class >> new: anInteger [
	"Create an empty square matrix of dimension anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: anInteger
    ]

    DhbMatrix class >> rows: anArrayOrVector [
	"Create a new matrix with given components.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initializeRows: anArrayOrVector
    ]

    DhbMatrix class >> lupCRLCriticalDimension [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	^40
    ]

    = aNumberOrMatrix [
	<category: 'comparing'>
	aNumberOrMatrix isNil ifTrue: [^false].
	aNumberOrMatrix isNumber 
	    ifTrue: 
		[^(self numberOfRows = 1 and: [self numberOfColumns = 1]) 
		    and: [(self rowAt: 1 columnAt: 1) = aNumberOrMatrix]].
	aNumberOrMatrix class = self class ifFalse: [^false].
	^self rows = aNumberOrMatrix rows
    ]

    hash [
	<category: 'comparing'>
	^rows hash
    ]

    printOn: aStream [
	"Append to the argument aStream, a sequence of characters that describes the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'display'>
	| first |
	first := true.
	rows do: 
		[:each | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		each printOn: aStream]
    ]

    addWithMatrix: aMatrix class: aMatrixClass [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	| n |
	n := 0.
	^aMatrixClass 
	    rows: (self rowsCollect: 
			[:each | 
			n := n + 1.
			each + (aMatrix rowAt: n)])
    ]

    addWithRegularMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^aMatrix addWithMatrix: self class: aMatrix class
    ]

    addWithSymmetricMatrix: aMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/28/99"

	<category: 'double dispatching'>
	^aMatrix addWithMatrix: self class: self class
    ]

    productFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self * aFloatD
    ]

    productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self productWithMatrixFinal: aMatrix
    ]

    productWithMatrixFinal: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class rows: (aMatrix 
		    rowsCollect: [:row | self columnsCollect: [:col | row * col]])
    ]

    productWithSymmetricMatrix: aSymmetricMatrix [
	"Answers the product of the receiver with aSymmetricMatrix (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class rows: (self 
		    rowsCollect: [:row | aSymmetricMatrix columnsCollect: [:col | row * col]])
    ]

    productWithTransposeMatrix: aMatrix [
	"Answers the product of the receiver with the transpose of aMatrix(in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class 
	    rows: (self rowsCollect: [:row | aMatrix rowsCollect: [:col | row * col]])
    ]

    productWithVector: aVector [
	"Answers the product of the receiver with aVector
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self columnsCollect: [:each | each * aVector]
    ]

    subtractWithMatrix: aMatrix class: aMatrixClass [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	| n |
	n := 0.
	^aMatrixClass 
	    rows: (self rowsCollect: 
			[:each | 
			n := n + 1.
			each - (aMatrix rowAt: n)])
    ]

    subtractWithRegularMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^aMatrix subtractWithMatrix: self class: aMatrix class
    ]

    subtractWithSymmetricMatrix: aMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/28/99"

	<category: 'double dispatching'>
	^aMatrix subtractWithMatrix: self class: self class
    ]

    transposeProductWithMatrix: aMatrix [
	"Answers the product of the transpose of the receiver with aMatrix (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class rows: (self 
		    columnsCollect: [:row | aMatrix columnsCollect: [:col | row * col]])
    ]

    columnAt: anInteger [
	"Answers the anInteger-th column of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows collect: [:each | each at: anInteger]
    ]

    determinant [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	^self lupDecomposition determinant
    ]

    isSquare [
	"Answers true if the number of rows is equal to the number of columns.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows size = rows last size
    ]

    isSymmetric [
	"Answers false because the receiver is not a symmetric matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^false
    ]

    largestPowerOf2SmallerThan: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved
	 Initial code: 21/3/99"

	<category: 'information'>
	| m m2 |
	m := 2.
	
	[m2 := m * 2.
	m2 < anInteger] whileTrue: [m := m2].
	^m
    ]

    lupDecomposition [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'information'>
	lupDecomposition isNil 
	    ifTrue: [lupDecomposition := DhbLUPDecomposition equations: rows].
	^lupDecomposition
    ]

    numberOfColumns [
	"Answer the number of rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows last size
    ]

    numberOfRows [
	"Answer the number of rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows size
    ]

    rowAt: anInteger [
	"Answers the anInteger-th row of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows at: anInteger
    ]

    rowAt: aRowIndex columnAt: aColumnIndex [
	"Answers the aRowIndex-th, aColumnIndex-th entry in the receiver.
	 (c) Copyrights Joseph WHITESELL, 2001, all rights reserved.
	 Initial code: 08/17/2001"

	<category: 'information'>
	^(rows at: aRowIndex) at: aColumnIndex
    ]

    rowAt: aRowIndex columnAt: aColumnIndex put: aValue [
	<category: 'information'>
	^(rows at: aRowIndex) at: aColumnIndex put: aValue
    ]

    rows [
	<category: 'information'>
	^rows
    ]

    transpose [
	"Answer a new matrix, transpose of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^self class rows: (self columnsCollect: [:each | each])
    ]

    initialize: anInteger [
	"Build empty components for a square matrix.
	 No check is made: components are assumed to be orgainized in rows.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	rows := (1 to: anInteger) asVector 
		    collect: [:each | DhbVector new: anInteger]
    ]

    initializeRows: anArrayOrVector [
	"Defines the components of the recevier.
	 No check is made: components are assumed to be orgainized in rows.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	rows := anArrayOrVector asVector collect: [:each | each asVector]
    ]

    columnsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	| n |
	n := 0.
	^rows last collect: 
		[:each | 
		n := n + 1.
		aBlock value: (self columnAt: n)]
    ]

    columnsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	| n |
	n := 0.
	^rows last do: 
		[:each | 
		n := n + 1.
		aBlock value: (self columnAt: n)]
    ]

    rowsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	^rows collect: aBlock
    ]

    rowsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	^rows do: aBlock
    ]

    * aNumberOrMatrixOrVector [
	"Answers the product of the receiver with the argument.
	 The argument can be a number, matrix or vector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aNumberOrMatrixOrVector productWithMatrix: self
    ]

    + aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix addWithRegularMatrix: self
    ]

    - aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix subtractWithRegularMatrix: self
    ]

    inverse [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^self isSquare 
	    ifTrue: [self lupInverse]
	    ifFalse: [self squared inverse * self transpose]
    ]

    inversePureCRL [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'operation'>
	^self squared inversePureCRL * self transpose
    ]

    lupInverse [
	<category: 'operation'>
	^self class rows: self lupDecomposition inverseMatrixComponents
    ]

    squared [
	"Answers the product of the transpose of the receiver with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^DhbSymmetricMatrix rows: (self 
		    columnsCollect: [:col | self columnsCollect: [:colT | col * colT]])
    ]

    strassenProductWithMatrix: aMatrix [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/5/99"

	<category: 'operation'>
	| matrixSplit selfSplit p1 p2 p3 p4 p5 p6 p7 |
	(self numberOfRows > 2 and: [self numberOfColumns > 2]) 
	    ifFalse: 
		[^self class rows: (aMatrix 
			    rowsCollect: [:row | self columnsCollect: [:col | row * col]])].
	selfSplit := self split.
	matrixSplit := aMatrix split.
	p1 := (selfSplit at: 2) - (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 1).
	p2 := (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 1) + (matrixSplit at: 2).
	p3 := (selfSplit at: 1) 
		    strassenProductWithMatrix: (matrixSplit at: 3) + (matrixSplit at: 4).
	p4 := (selfSplit at: 3) - (selfSplit at: 1) 
		    strassenProductWithMatrix: (matrixSplit at: 4).
	p5 := (selfSplit at: 1) + (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 1) + (matrixSplit at: 4).
	p6 := (selfSplit at: 3) + (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 2) - (matrixSplit at: 4).
	p7 := (selfSplit at: 1) + (selfSplit at: 2) 
		    strassenProductWithMatrix: (matrixSplit at: 1) - (matrixSplit at: 3).
	^self class join: (Array 
		    with: p5 + p4 + p6 - p2
		    with: p1 + p2
		    with: p3 + p4
		    with: p5 + p1 - p3 - p7)
    ]

    accumulate: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	| n |
	n := 0.
	self rowsCollect: 
		[:each | 
		n := n + 1.
		each accumulate: (aMatrix rowAt: n)]
    ]

    accumulateNegated: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	| n |
	n := 0.
	self rowsCollect: 
		[:each | 
		n := n + 1.
		each accumulateNegated: (aMatrix rowAt: n)]
    ]

    asSymmetricMatrix [
	"Convert the receiver to a symmetric matrix (no check is made).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	^DhbSymmetricMatrix rows: rows
    ]

    negate [
	"Inverse the sign of all components of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	rows do: [:each | each negate]
    ]

    scaleBy: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/11/00"

	<category: 'transformation'>
	rows do: [:each | each scaleBy: aNumber]
    ]

    split [
	"Private - Answers an array of 4 matrices split from the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/5/99"

	<category: 'transformation'>
	| n m n1 m1 |
	n := self numberOfRows.
	m := self numberOfColumns.
	n1 := self largestPowerOf2SmallerThan: n.
	m1 := self largestPowerOf2SmallerThan: m.
	^Array 
	    with: (self class 
		    rows: ((1 to: n1) asVector collect: [:k | (rows at: k) copyFrom: 1 to: m1]))
	    with: (self class rows: ((1 to: n1) asVector 
			    collect: [:k | (rows at: k) copyFrom: m1 + 1 to: m]))
	    with: (self class rows: ((n1 + 1 to: n) asVector 
			    collect: [:k | (rows at: k) copyFrom: 1 to: m1]))
	    with: (self class rows: ((n1 + 1 to: n) asVector 
			    collect: [:k | (rows at: k) copyFrom: m1 + 1 to: m]))
    ]
]



Object subclass: DhbLUPDecomposition [
    | rows permutation parity |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLUPDecomposition class >> direct: anArrayOfArrays [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'creation'>
	^self new initialize: anArrayOfArrays
    ]

    DhbLUPDecomposition class >> equations: anArrayOfArrays [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'creation'>
	^self new initialize: (anArrayOfArrays collect: [:each | each copy])
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'display'>
	| first delimitingString n k |
	n := rows size.
	first := true.
	rows do: 
		[:row | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		delimitingString := '('.
		row do: 
			[:each | 
			aStream nextPutAll: delimitingString.
			each printOn: aStream.
			delimitingString := ' '].
		aStream nextPut: $)]
    ]

    determinant [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	| n |
	permutation isNil ifTrue: [self protectedDecomposition].
	permutation = 0 ifTrue: [^0].	"Singular matrix has 0 determinant"
	n := 0.
	^rows inject: parity
	    into: 
		[:det :each | 
		n := n + 1.
		(each at: n) * det]
    ]

    inverseMatrixComponents [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'information'>
	| n inverseRows column |
	permutation isNil ifTrue: [self protectedDecomposition].
	permutation = 0 ifTrue: [^nil].	"Singular matrix has no inverse"
	n := rows size.
	inverseRows := (1 to: n) asVector collect: [:j | DhbVector new: n].
	1 to: n
	    do: 
		[:j | 
		column := self solve: ((Array new: rows size)
				    atAllPut: 0;
				    at: j put: 1;
				    yourself).
		1 to: n do: [:i | (inverseRows at: i) at: j put: (column at: i)]].
	^inverseRows
    ]

    largestPivotFrom: anInteger [
	"Private - Answers the largest pivot element in column anInteger, from position anInteger upward.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	| valueOfMaximum indexOfMaximum value |
	valueOfMaximum := ((rows at: anInteger) at: anInteger) abs.
	indexOfMaximum := anInteger.
	anInteger + 1 to: rows size
	    do: 
		[:n | 
		value := ((rows at: n) at: anInteger) abs.
		value > valueOfMaximum 
		    ifTrue: 
			[valueOfMaximum := value.
			indexOfMaximum := n]].
	^indexOfMaximum
    ]

    initialize: anArrayOfArrays [
	"Private - A copy of the original array is made.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'initialization'>
	rows := anArrayOfArrays.
	parity := 1.
	^self
    ]

    backwardSubstitution: anArray [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| n sum answer |
	n := rows size.
	answer := DhbVector new: n.
	n to: 1
	    by: -1
	    do: 
		[:i | 
		sum := anArray at: i.
		i + 1 to: n do: [:j | sum := sum - (((rows at: i) at: j) * (answer at: j))].
		answer at: i put: sum / ((rows at: i) at: i)].
	^answer
    ]

    decompose [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| n |
	n := rows size.
	permutation := (1 to: n) asArray.
	1 to: n - 1
	    do: 
		[:k | 
		self
		    swapRow: k withRow: (self largestPivotFrom: k);
		    pivotAt: k]
    ]

    forwardSubstitution: anArray [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| n sum answer |
	answer := permutation collect: [:each | anArray at: each].
	n := rows size.
	2 to: n
	    do: 
		[:i | 
		sum := answer at: i.
		1 to: i - 1 do: [:j | sum := sum - (((rows at: i) at: j) * (answer at: j))].
		answer at: i put: sum].
	^answer
    ]

    pivotAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| inversePivot size k |
	inversePivot := 1 / ((rows at: anInteger) at: anInteger).
	size := rows size.
	k := anInteger + 1.
	k to: size
	    do: 
		[:i | 
		(rows at: i) at: anInteger put: ((rows at: i) at: anInteger) * inversePivot.
		k to: size
		    do: 
			[:j | 
			(rows at: i) at: j
			    put: ((rows at: i) at: j) 
				    - (((rows at: i) at: anInteger) * ((rows at: anInteger) at: j))]]
    ]

    protectedDecomposition [
	"Private - If decomposition fails, set permutation to 0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	[self decompose] on: Error
	    do: 
		[:signal | 
		permutation := 0.
		signal return: nil]
    ]

    solve: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	permutation isNil ifTrue: [self protectedDecomposition].
	^permutation = 0 
	    ifTrue: [nil]
	    ifFalse: 
		[self backwardSubstitution: (self forwardSubstitution: anArrayOrVector)]
    ]

    swapRow: anInteger1 withRow: anInteger2 [
	"Private - Swap the rows indexed by the given integers.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	anInteger1 = anInteger2 
	    ifFalse: 
		[| swappedRow |
		swappedRow := rows at: anInteger1.
		rows at: anInteger1 put: (rows at: anInteger2).
		rows at: anInteger2 put: swappedRow.
		swappedRow := permutation at: anInteger1.
		permutation at: anInteger1 put: (permutation at: anInteger2).
		permutation at: anInteger2 put: swappedRow.
		parity := parity negated]
    ]
]



DhbIterativeProcess subclass: DhbJacobiTransformation [
    | lowerRows transform |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbJacobiTransformation class >> matrix: aSymmetricMatrix [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'creation'>
	^super new initialize: aSymmetricMatrix
    ]

    DhbJacobiTransformation class >> new [
	"Prevent using this message to create instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    printOn: aStream [
	"Append to the argument aStream, a sequence of characters that describes the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'display'>
	| first |
	first := true.
	lowerRows do: 
		[:each | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		each printOn: aStream]
    ]

    largestOffDiagonalIndices [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'information'>
	| n m abs |
	n := 2.
	m := 1.
	precision := ((lowerRows at: n) at: m) abs.
	1 to: lowerRows size
	    do: 
		[:i | 
		1 to: i - 1
		    do: 
			[:j | 
			abs := ((lowerRows at: i) at: j) abs.
			abs > precision 
			    ifTrue: 
				[n := i.
				m := j.
				precision := abs]]].
	^Array with: m with: n
    ]

    transform [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'information'>
	^DhbMatrix rows: transform
    ]

    initialize: aSymmetricMatrix [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'initialization'>
	| n m |
	n := aSymmetricMatrix numberOfRows.
	lowerRows := Array new: n.
	transform := Array new: n.
	1 to: n
	    do: 
		[:k | 
		lowerRows at: k put: ((aSymmetricMatrix rowAt: k) copyFrom: 1 to: k).
		transform at: k
		    put: ((Array new: n)
			    atAllPut: 0;
			    at: k put: 1;
			    yourself)].
	^self
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'operation'>
	| indices |
	indices := self largestOffDiagonalIndices.
	self transformAt: (indices at: 1) and: (indices at: 2).
	^precision
    ]

    finalizeIterations [
	"Transfer the eigenValues into a vector and set this as the result.
	 eigen values and transform matrix are sorted using a bubble sort.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'operation'>
	| n |
	n := 0.
	result := lowerRows collect: 
			[:each | 
			n := n + 1.
			each at: n].
	self sortEigenValues
    ]

    exchangeAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'transformation'>
	| temp n |
	n := anInteger + 1.
	temp := result at: n.
	result at: n put: (result at: anInteger).
	result at: anInteger put: temp.
	transform do: 
		[:each | 
		temp := each at: n.
		each at: n put: (each at: anInteger).
		each at: anInteger put: temp]
    ]

    sortEigenValues [
	"Private - Use a bubble sort.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'transformation'>
	| n bound m |
	n := lowerRows size.
	bound := n.
	[bound = 0] whileFalse: 
		[m := 0.
		1 to: bound - 1
		    do: 
			[:j | 
			(result at: j) abs > (result at: j + 1) abs 
			    ifFalse: 
				[self exchangeAt: j.
				m := j]].
		bound := m]
    ]

    transformAt: anInteger1 and: anInteger2 [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'transformation'>
	| d t s c tau apq app aqq arp arq |
	apq := (lowerRows at: anInteger2) at: anInteger1.
	apq = 0 ifTrue: [^nil].
	app := (lowerRows at: anInteger1) at: anInteger1.
	aqq := (lowerRows at: anInteger2) at: anInteger2.
	d := aqq - app.
	arp := d * 0.5 / apq.
	t := arp > 0 
		    ifTrue: [1 / ((arp squared + 1) sqrt + arp)]
		    ifFalse: [1 / (arp - (arp squared + 1) sqrt)].
	c := 1 / (t squared + 1) sqrt.
	s := t * c.
	tau := s / (1 + c).
	1 to: anInteger1 - 1
	    do: 
		[:r | 
		arp := (lowerRows at: anInteger1) at: r.
		arq := (lowerRows at: anInteger2) at: r.
		(lowerRows at: anInteger1) at: r put: arp - (s * (tau * arp + arq)).
		(lowerRows at: anInteger2) at: r put: arq + (s * (arp - (tau * arq)))].
	anInteger1 + 1 to: anInteger2 - 1
	    do: 
		[:r | 
		arp := (lowerRows at: r) at: anInteger1.
		arq := (lowerRows at: anInteger2) at: r.
		(lowerRows at: r) at: anInteger1 put: arp - (s * (tau * arp + arq)).
		(lowerRows at: anInteger2) at: r put: arq + (s * (arp - (tau * arq)))].
	anInteger2 + 1 to: lowerRows size
	    do: 
		[:r | 
		arp := (lowerRows at: r) at: anInteger1.
		arq := (lowerRows at: r) at: anInteger2.
		(lowerRows at: r) at: anInteger1 put: arp - (s * (tau * arp + arq)).
		(lowerRows at: r) at: anInteger2 put: arq + (s * (arp - (tau * arq)))].
	1 to: lowerRows size
	    do: 
		[:r | 
		arp := (transform at: r) at: anInteger1.
		arq := (transform at: r) at: anInteger2.
		(transform at: r) at: anInteger1 put: arp - (s * (tau * arp + arq)).
		(transform at: r) at: anInteger2 put: arq + (s * (arp - (tau * arq)))].
	(lowerRows at: anInteger1) at: anInteger1 put: app - (t * apq).
	(lowerRows at: anInteger2) at: anInteger2 put: aqq + (t * apq).
	(lowerRows at: anInteger2) at: anInteger1 put: 0
    ]
]



DhbIterativeProcess subclass: DhbLargestEigenValueFinder [
    | matrix eigenvector transposeEigenvector |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbLargestEigenValueFinder class >> matrix: aMatrix [
	"Create a new instance of the receiver for a given matrix and default precision.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^(self new)
	    initialize: aMatrix;
	    yourself
    ]

    DhbLargestEigenValueFinder class >> matrix: aMatrix precision: aNumber [
	"Create a new instance of the receiver for a given matrix and desired precision.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^(self new)
	    initialize: aMatrix;
	    desiredPrecision: aNumber;
	    yourself
    ]

    DhbLargestEigenValueFinder class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^100
    ]

    nextLargestEigenValueFinder [
	"Return an eigen value finder for the same eigen values of the receiver except the one found.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	| norm |
	norm := 1 / (eigenvector * transposeEigenvector).
	^self class 
	    matrix: matrix * ((DhbSymmetricMatrix identity: eigenvector size) 
			    - (eigenvector * norm tensorProduct: transposeEigenvector))
	    precision: desiredPrecision
    ]

    eigenvalue [
	"Answer the eigen value found by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^result
    ]

    eigenvector [
	"Answer the normalized eigen vector found by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^eigenvector * (1 / eigenvector norm)
    ]

    initialize: aMatrix [
	"Defines the matrix for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	matrix := aMatrix
    ]

    evaluateIteration [
	"Iterate the product of the matrix of the eigen vector and the transpose.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| oldEigenvalue |
	oldEigenvalue := result.
	transposeEigenvector := transposeEigenvector * matrix.
	transposeEigenvector := transposeEigenvector 
		    * (1 / (transposeEigenvector at: 1)).
	eigenvector := matrix * eigenvector.
	result := eigenvector at: 1.
	eigenvector := eigenvector * (1 / result).
	^oldEigenvalue isNil 
	    ifTrue: [2 * desiredPrecision]
	    ifFalse: [(result - oldEigenvalue) abs]
    ]

    initializeIterations [
	"Initialize the iterations (subclasses must write their own method and call this one last).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	eigenvector := DhbVector new: matrix numberOfRows.
	eigenvector atAllPut: 1.0.
	transposeEigenvector := DhbVector new: eigenvector size.
	transposeEigenvector atAllPut: 1.0
    ]
]



Object subclass: DhbLinearEquationSystem [
    | rows solutions |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLinearEquationSystem class >> equations: anArrayOfArrays constant: anArray [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: anArrayOfArrays constants: (Array with: anArray)
    ]

    DhbLinearEquationSystem class >> equations: anArrayOfArrays constants: anArrayOfConstantArrays [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: anArrayOfArrays constants: anArrayOfConstantArrays
    ]

    printOn: aStream [
	"Append to the argument aStream, a sequence of characters that describes the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'display'>
	| first delimitingString n k |
	n := rows size.
	first := true.
	rows do: 
		[:row | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		delimitingString := '('.
		k := 0.
		row do: 
			[:each | 
			aStream nextPutAll: delimitingString.
			each printOn: aStream.
			k := k + 1.
			delimitingString := k < n ifTrue: [' '] ifFalse: [' : ']].
		aStream nextPut: $)]
    ]

    largestPivotFrom: anInteger [
	"Private - Answers the largest pivot element in column anInteger, from position anInteger upward.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	| valueOfMaximum indexOfMaximum |
	valueOfMaximum := (rows at: anInteger) at: anInteger.
	indexOfMaximum := anInteger.
	anInteger + 2 to: rows size
	    do: 
		[:n | 
		((rows at: n) at: anInteger) > valueOfMaximum 
		    ifTrue: 
			[valueOfMaximum := (rows at: n) at: anInteger.
			indexOfMaximum := n]].
	^indexOfMaximum
    ]

    solution [
	"Answers the solution corresponding to the first constant array.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	^self solutionAt: 1
    ]

    solutionAt: anInteger [
	"Answer the solution corresponding to the anInteger-th constant array.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	"solutions isNil
	 ifTrue: [ [self solve] when: Error do: [ :signal |solutions := 0. signal return: nil.] ].
	 solutions = 0
	 ifTrue: [ ^nil].
	 ( solutions at: anInteger) isNil
	 ifTrue: [ self backSubstitutionAt: anInteger].
	 ^solutions at: anInteger"

	<category: 'information'>
	solutions isNil 
	    ifTrue: 
		[[self solve] on: Error
		    do: 
			[:signal | 
			solutions := 0.
			signal return: nil]].
	solutions = 0 ifTrue: [^nil].
	(solutions at: anInteger) isNil 
	    ifTrue: [self backSubstitutionAt: anInteger].
	^solutions at: anInteger
    ]

    initialize: anArrayOfArrays constants: anArrayOfConstantArrays [
	"Private - Initialize the receiver with system's matrix in anArrayOfArrays and several constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	| n |
	n := 0.
	rows := anArrayOfArrays collect: 
			[:each | 
			n := n + 1.
			each , (anArrayOfConstantArrays collect: [:c | c at: n])].
	^self
    ]

    backSubstitutionAt: anInteger [
	"Private - Perform the back-substitution step corresponding to the anInteger-th constant array.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| size answer accumulator |
	size := rows size.
	answer := Array new: size.
	size to: 1
	    by: -1
	    do: 
		[:n | 
		accumulator := (rows at: n) at: anInteger + size.
		n + 1 to: size
		    do: [:m | accumulator := accumulator - ((answer at: m) * ((rows at: n) at: m))].
		answer at: n put: accumulator / ((rows at: n) at: n)].
	solutions at: anInteger put: answer
    ]

    pivotAt: anInteger [
	"Private - Performs pivot operation with pivot element at anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| inversePivot rowPivotValue row pivotRow |
	pivotRow := rows at: anInteger.
	inversePivot := 1 / (pivotRow at: anInteger).
	anInteger + 1 to: rows size
	    do: 
		[:n | 
		row := rows at: n.
		rowPivotValue := (row at: anInteger) * inversePivot.
		anInteger to: row size
		    do: [:m | row at: m put: (row at: m) - ((pivotRow at: m) * rowPivotValue)]]
    ]

    pivotStepAt: anInteger [
	"Private - Performs an optimum pivot operation at anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	self
	    swapRow: anInteger withRow: (self largestPivotFrom: anInteger);
	    pivotAt: anInteger
    ]

    solve [
	"Private - Perform LU decomposition of the system.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	1 to: rows size do: [:n | self pivotStepAt: n].
	solutions := Array new: (rows at: 1) size - rows size
    ]

    swapRow: anInteger1 withRow: anInteger2 [
	"Private - Swap the rows indexed by the given integers.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| swappedRow |
	anInteger1 = anInteger2 
	    ifFalse: 
		[swappedRow := rows at: anInteger1.
		rows at: anInteger1 put: (rows at: anInteger2).
		rows at: anInteger2 put: swappedRow]
    ]
]



DhbMatrix subclass: DhbSymmetricMatrix [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbSymmetricMatrix class >> identity: anInteger [
	"Create an identity matrix of dimension anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initializeIdentity: anInteger
    ]

    DhbSymmetricMatrix class >> join: anArrayOfMatrices [
	"Inverse of the split operation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	| rows n |
	rows := OrderedCollection new.
	n := 0.
	(anArrayOfMatrices at: 1) rowsDo: 
		[:each | 
		n := n + 1.
		rows add: each , ((anArrayOfMatrices at: 3) columnAt: n)].
	n := 0.
	(anArrayOfMatrices at: 2) rowsDo: 
		[:each | 
		n := n + 1.
		rows add: ((anArrayOfMatrices at: 3) rowAt: n) , each].
	^self rows: rows
    ]

    DhbSymmetricMatrix class >> lupCRLCriticalDimension [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	^36
    ]

    isSquare [
	"Answers true because a symmetric matrix is square.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^true
    ]

    isSymmetric [
	"Answers true because the receiver is a symmetric matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^true
    ]

    clear [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/11/00"

	<category: 'initialization'>
	rows do: [:each | each atAllPut: 0]
    ]

    initializeIdentity: anInteger [
	"Build components for an identity matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	rows := (1 to: anInteger) asVector collect: 
			[:n | 
			(DhbVector new: anInteger)
			    atAllPut: 0;
			    at: n put: 1;
			    yourself]
    ]

    + aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix addWithSymmetricMatrix: self
    ]

    - aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix subtractWithSymmetricMatrix: self
    ]

    addWithSymmetricMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix addWithMatrix: self class: self class
    ]

    crlInverse [
	<category: 'operation'>
	| matrices b1 cb1ct cb1 |
	matrices := self split.
	b1 := (matrices at: 1) inverse.
	cb1 := (matrices at: 3) * b1.
	cb1ct := (cb1 productWithTransposeMatrix: (matrices at: 3)) 
		    asSymmetricMatrix.
	matrices at: 3 put: (matrices at: 2) * cb1.
	matrices at: 2 put: ((matrices at: 2) accumulateNegated: cb1ct) inverse.
	matrices at: 1
	    put: (b1 accumulate: (cb1 transposeProductWithMatrix: (matrices at: 3))).
	(matrices at: 3) negate.
	^self class join: matrices
    ]

    inverse [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^(rows size < self class lupCRLCriticalDimension 
	    or: [lupDecomposition notNil]) 
		ifTrue: [self lupInverse]
		ifFalse: [self crlInverse]
    ]

    inverse1By1 [
	"Private - Answer the inverse of the receiver when it is a 1x1 matrix (no check is made).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'operation'>
	^self class 
	    rows: (DhbVector with: (DhbVector with: 1 / ((rows at: 1) at: 1)))
    ]

    inverse2By2 [
	"Private - Answer the inverse of the receiver when it is a 2x2 matrix (no check is made).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'operation'>
	| line1 line2 |
	line1 := DhbVector with: ((rows at: 2) at: 2)
		    with: ((rows at: 1) at: 2) negated.
	line2 := DhbVector with: ((rows at: 1) at: 2) negated
		    with: ((rows at: 1) at: 1).
	^self class rows: (DhbVector with: line1 with: line2) 
		    * (1 / (((rows at: 1) at: 1) * ((rows at: 2) at: 2) 
				    - ((rows at: 1) at: 2) squared))
    ]

    inversePureCRL [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| matrices b1 cb1 cb1ct |
	rows size = 1 ifTrue: [^self inverse1By1].
	rows size = 2 ifTrue: [^self inverse2By2].
	matrices := self split.
	b1 := (matrices at: 1) inversePureCRL.
	cb1 := (matrices at: 3) * b1.
	cb1ct := (cb1 productWithTransposeMatrix: (matrices at: 3)) 
		    asSymmetricMatrix.
	matrices at: 2
	    put: ((matrices at: 2) accumulateNegated: cb1ct) inversePureCRL.
	matrices at: 3 put: (matrices at: 2) * cb1.
	matrices at: 1
	    put: (b1 accumulate: (cb1 transposeProductWithMatrix: (matrices at: 3))).
	(matrices at: 3) negate.
	^self class join: matrices
    ]

    inversePureLUP [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	lupDecomposition := nil.
	^self class rows: lupDecomposition inverseMatrixComponents
    ]

    productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix productWithSymmetricMatrix: self
    ]

    productWithSymmetricMatrix: aSymmetricMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aSymmetricMatrix productWithMatrixFinal: self
    ]

    subtractWithSymmetricMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix subtractWithMatrix: self class: self class
    ]

    split [
	"Private -
	 Answers an array of 3 matrices split from the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	| n |
	n := self largestPowerOf2SmallerThan: rows size.
	^Array 
	    with: (self class 
		    rows: ((1 to: n) asVector collect: [:k | (rows at: k) copyFrom: 1 to: n]))
	    with: (self class rows: ((n + 1 to: rows size) asVector 
			    collect: [:k | (rows at: k) copyFrom: n + 1 to: rows size]))
	    with: (self class superclass rows: ((n + 1 to: rows size) asVector 
			    collect: [:k | (rows at: k) copyFrom: 1 to: n]))
    ]
]

