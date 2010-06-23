"======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

GtkMainWindow subclass: Tetris [
    | canvasWidget canvas process pause delay grid movingBlocks level score level lines |
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    Tetris class [ | highScores | ]

    Tetris class >> highScores [
	<category: 'accessing'>

	^ highScores ifNil: [ highScores := HighScores newSized: 10 ]
    ]

    Tetris class >> open [
	<category: 'user interface'>

	TetrisPiece initialize.

	^ super open
	    play;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	movingBlocks := false.
	super initialize.
    ]

    windowTitle [
	<category: 'initialization'>

	^'Tetris'
    ]

    postInitialize [
	<category: 'initialization'>

	super postInitialize.
        canvasWidget grabFocus.
	window
	    connectSignal: 'key-press-event' to: self selector: #'keyPressedOn:keyEvent:'
    ]

    onDelete [
	<category: 'windows event'>

	self quit.
	^ true
    ]

    createHelpMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'About Tetris' connectTo: self selector: #aboutLauncher.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self createMainMenu: #(#('Help' #createHelpMenus))
    ]

    buildCentralWidget [
	<category: 'user interface'>
	
	^ canvasWidget := GTK.GtkDrawingArea new
	    setSizeRequest: 400 height: 700;
	    connectSignal: 'expose_event' to: self selector: #'expose:event:';
	    yourself
    ]

    clearArea: aGtkAllocation [
        <category: 'drawing'>

        | res |
        res := aGtkAllocation castTo: (CIntType arrayType: 4).

        canvas saveWhile: [ 
	    canvas
                rectangle: ((0@0) extent: ((res at: 2) @ (res at: 3)));
                operator: #clear;
                fill ]
    ]

    drawArea [
	<category: 'drawing'>

	1 to: 22 do: [ :i |
	    BlockWidget new
		position: 50@(50 + ((i - 1) * 15));
		size: 15;
		color: Cairo.Color white;
		drawOn: canvas.

            BlockWidget new
                position: (50 + (11 * 15))@(50 + ((i - 1) * 15));
                size: 15;
		color: Cairo.Color white;
                drawOn: canvas ].

	1 to: 12 do: [ :i |
            BlockWidget new
                position: (50 + ((i - 1) * 15))@50;
                size: 15;
		color: Cairo.Color white;
                drawOn: canvas.

            BlockWidget new
                position: (50 + ((i - 1) * 15))@(50 + (22 * 15));
                size: 15;
		color: Cairo.Color white;
                drawOn: canvas ]
    ]

    drawGrid [
	<category: 'drawing'>

	grid ifNil: [ ^ self ].
	grid drawOn: canvas
    ]

    drawScore [
	<category: 'drawing'>

	canvas
	    moveTo: 300@100;
	    sourceRed: 1 green: 1 blue: 1;
	    showText: 'Score : ', (self score displayString);
	    moveTo: 300@150;
	    showText: 'Level : ', (self level displayString);
	    stroke.
    ]

    expose: aGtkWidget event: aGdkEventExpose [
	<category: 'drawing event'>

	aGtkWidget getWindow withContextDo: [ :cr |
            canvas := cr.
            self
                clearArea: aGtkWidget getAllocation;
		drawArea;
		drawGrid;
		drawScore ].

        ^ true
    ]

    keyPressedOn: aGtkWidget keyEvent: aGdkEventKey [
	<category: 'key event'>

	| event |
	movingBlocks ifFalse: [ ^ false ].

	event := aGdkEventKey castTo: GTK.GdkEventKey type.

	event keyval value = 65361 ifTrue: [ self movePieceLeft. ^ true ].
	event keyval value = 65363 ifTrue: [ self movePieceRight. ^ true ].
	event keyval value = 65362 ifTrue: [ self rotatePiece. ^ true ].
	event keyval value = 65364 ifTrue: [ self dropPiece. ^ true ].

	^ false
    ]

    refresh [
	<category: 'drawing'>

	canvasWidget queueDraw
    ]

    cycle [
	<category: 'game'>
	
	| result filledLines |
	grid := TetrisField new.
	[ movingBlocks := true.
	  result := grid currentPiece: TetrisPiece random.
	  result ifTrue: [ self 
			    refresh;
			    delay ].
	  result ] whileTrue: [ 
		[ result := self slidePiece.
		  self refresh.
		  result ] whileTrue: [ self delay ].
		  filledLines := self 
				    resetMovingBlocks;
				    cementPiece;
				    removeLines.
		  self updateScore: filledLines.
		  Processor yield ].

	^ self gameOver 
    ]

    initializeGame [
	<category: 'game'>

	self 
	    level: 1;
	    lines: 0;
	    score: 0.
	movingBlocks := true
    ]

    play [
	<category: 'game'>

	process := [ self
			initializeGame;
			cycle ] fork.
    ]

    quit [
	<category: 'game'>

	process terminate.
	window hideAll
    ]

    gameOver [
	<category: 'game'>

	self highScores addScore: (Score score: self score)
    ]

    resetMovingBlocks [
	<category: 'game'>

	movingBlocks := false
    ]

    delay [
	"I like this method a lot!"

	<category: 'private'>
	delay wait.

	"Especially this semaphore!!
	pause wait.
	pause signal"
    ]

    highScores [
	<category: 'accessing'>

	^ self class highScores
    ]

    level [
	<category: 'accessing'>

	^ level
    ]

    level: nextLevel [
	<category: 'private'>

	level := nextLevel min: 10.
	delay := Delay forMilliseconds: 825 - (75 * level).
    ]

    lines [
	<category: 'private'>

	^ lines
    ]

    lines: newLines [
	<category: 'private'>

	lines := newLines
    ]

    score [
	<category: 'private'>

	^ score
    ]

    score: newScore [
	<category: 'private'>

	score := newScore
    ]

    updateScore: filledLines [
	<category: 'private'>

	self lines: self lines + filledLines.
        (self lines - 1) // 10 > (self level - 1) ifTrue: [ self advanceLevel ].
        self score: 2 * self level squared + (#(0 50 150 400 900) at: filledLines + 1) + self score
    ]

    advanceLevel [
	<category: 'events'>

	self level: self level + 1
    ]

    movePieceLeft [
	<category: 'events'>

	grid movePieceLeft.
	self refresh
    ]

    movePieceRight [
	<category: 'events'>

	grid movePieceRight.
	self refresh
    ]

    pause [
	<category: 'events'>

	"I like this semaphore a lot!"
	pause wait
    ]

    restart [
	<category: 'events'>

	"I like this semaphore a lot!"
	pause signal
    ]

    rotatePiece [
	<category: 'events'>

	grid rotatePiece.
	self refresh
    ]

    slidePiece [
	<category: 'events'>

	^ grid slidePiece
    ]

    cementPiece [
	<category: 'events'>

	^ grid cementPiece
    ]

    removeLines [
	<category: 'game'>

	^ grid removeLines
    ]

    dropPiece [
	<category: 'events'>

	^ grid dropPiece
    ]
]

