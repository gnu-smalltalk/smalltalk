Gui class extend [

    test: selector [
	<category: 'testing'>
	| win |
	win := BWindow new: 'test'.
	win width: 100 height: 100.
	(self perform: selector) value: win.
	win map.
	Blox dispatchEvents: win
    ]

    callbackTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| cont dlg sure |
	win callback: 
		[cont := BTransientWindow new: 'BLOX test' in: win.
		cont width: 250 height: 130.
		dlg := BDialog new: cont label: 'Are you sure?'.
		dlg 
		    addButton: 'Yes'
		    receiver: [sure := true]
		    message: #value.
		dlg 
		    addButton: 'No'
		    receiver: [sure := false]
		    message: #value.
		dlg loop.
		sure]
	    message: #value]
    ]

    canvasTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| ctl |
	ctl := BScrolledCanvas new: win.
	ctl width: 100 height: 100.
	ctl backgroundColor: 'gray35'.
	ctl extraSpace: 10 @ 0.
	win width: 220 height: 220.
	win map.

	"p := ctl widthAbsolute @ ctl heightAbsolute. p printNl."
	self drawInCanvas: ctl width: 200 @ 200]
    ]

    drawInCanvas: ctl width: p [
	<category: 'testing single controls'>
	| status rect poly |
	poly := (BPolyline new: ctl)
		    closed: true;
		    color: 'blue';
		    outlineColor: 'LemonChiffon';
		    points: (self points: p
				coords: #(#(0.1 0.1) #(0.5 0.2) #(0.9000000000000001 0.9000000000000001) #(0.5 0.8000000000000001)));
		    create.
	(BLine new: ctl)
	    origin: p * 0.1 corner: p * 0.9000000000000001;
	    color: 'Magenta';
	    cap: #round;
	    width: 8;
	    create.
	rect := (BRectangle new: ctl)
		    origin: p * 0.45 extent: p * 0.1;
		    color: 'yellow';
		    outlineColor: 'Magenta';
		    width: 2;
		    create.
	(BSpline new: ctl)
	    closed: false;
	    points: (self points: p
			coords: #(#(0.05 0.05) #(0.05 0.05) #(0.05 0.9500000000000001) #(0.9500000000000001 0.9500000000000001) #(0.9500000000000001 0.9500000000000001) #(0.9500000000000001 0.05) #(0.05 0.05) #(0.05 0.05) #(0.05 0.25) #(0.05 0.25)));
	    join: #bevel;
	    color: 'ForestGreen';
	    width: 8;
	    create.	"Trick to get the bevel-styled join"	"at the top-left corner too"
	(BArc new: ctl)
	    origin: p * (0.2 @ 0.8000000000000001) corner: p * (0.8000000000000001 @ 1);
	    outlineColor: 'gray75';
	    from: p * (0.2 @ 0.9000000000000001);
	    to: p * (0.5 @ 0.8000000000000001);
	    create.
	(BArc new: ctl)
	    origin: p * (0.2 @ 0) corner: p * (0.8000000000000001 @ 0.2);
	    outlineColor: 'gray75';
	    startAngle: 270;
	    endAngle: 360;
	    create.
	status := 0.
	poly 
	    onMouseDoubleEvent: 1
	    send: #value:
	    to: 
		[:pnt | 
		status := status + 1.
		status = 1 ifTrue: [poly raise].
		status = 2 ifTrue: [poly lower].
		status = 3 
		    ifTrue: 
			[(BEmbeddedText new: ctl)
			    color: 'Cyan';
			    text: 'Smalltalk is great';
			    font: 'Helvetica 12';
			    center: p / 2 extent: p x @ (p y / 10);
			    create.
			rect remove]]
    ]

    points: p coords: coords [
	<category: 'testing single controls'>
	^coords collect: [:each | p * ((each at: 1) @ (each at: 2))]
    ]

    dropdownTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| cb name size label |
	cb := 
		[[label font: '{%1} %2' % 
				{name text.
				size text}] on: Error
		    do: [:sig | sig return]].
	win width: 300 height: 300.
	name := BDropDownList new: win.
	size := BDropDownEdit new: win.
	label := BLabel new: win.
	name
	    width: 250;
	    contents: Blox fonts;
	    callback: cb message: #value;
	    index: 1.
	size
	    x: 252;
	    width: 48;
	    elements: #(6 8 10 12 14 18 24 36 48 72);
	    callback: cb message: #value;
	    index: 4.
	label
	    effect: #groove;
	    width: 300 height: 300;
	    posVert: name;
	    alignment: #center;
	    label: 'The quick brown fox jumps over the lazy dog. 0123456789']
    ]

    vContainerTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| vertical ctl cont |
	cont := BContainer new: win.
	cont setVerticalLayout: true.
	ctl := BLabel new: cont label: 'label'.
	ctl := BButton new: cont label: 'button'.
	win backgroundColor: 'navyblue']
    ]

    hContainerTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| vertical ctl cont |
	cont := BContainer new: win.
	cont setVerticalLayout: false.
	ctl := BLabel new: cont label: 'label'.
	ctl := BButton new: cont label: 'button'.
	win backgroundColor: 'navyblue']
    ]

    dialogTest1 [
	<category: 'testing single controls'>
	^
	[:win | 
	| cont dlg |
	cont := BTransientWindow new: 'transient' in: win.
	cont width: 250 height: 130.
	dlg := BDialog new: cont label: 'dialog test'.
	dlg 
	    addButton: 'OK'
	    receiver: self
	    message: #itemChosen.
	dlg 
	    addButton: 'Cancel'
	    receiver: self
	    message: #yourself.
	win map.
	dlg loop]
    ]

    dialogTest2 [
	<category: 'testing single controls'>
	^
	[:win | 
	| cont dlg |
	cont := BTransientWindow new: 'transient' in: win.
	cont width: 250 height: 130.
	dlg := BDialog 
		    new: cont
		    label: 'dialog test'
		    prompt: 'default'.
	dlg 
	    addButton: 'OK'
	    receiver: self
	    message: #pickMeHarder.
	dlg 
	    addButton: 'Cancel'
	    receiver: self
	    message: #yourself.
	win map.
	dlg loop]
    ]

    editTest [
	<category: 'testing single controls'>
	^
	[:win | 
	(BLabel new: win) label: 'Enter whatever you want:'.
	(BEdit new: win)
	    x: 0 y: 50;
	    width: 100;
	    callback: Blox message: 'beep'.
	win width: 200 height: 80]
    ]

    eventTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| event events x y key ascii mouse |
	mouse := 
		[:pnt | 
		x label: pnt x printString.
		y label: pnt y printString].
	win width: 400 height: 200.
	(event := BLabel new: win label: '')
	    x: 0 y: 0;
	    width: 200.
	(x := BLabel new: win label: '')
	    x: 200 y: 0;
	    width: 50.
	(y := BLabel new: win label: '')
	    x: 250 y: 0;
	    width: 50.
	(key := BLabel new: win label: '')
	    x: 300 y: 0;
	    width: 50.
	(ascii := BLabel new: win label: '')
	    x: 350 y: 0;
	    width: 50.
	(BText new: win)
	    posVert: event;
	    onAsciiKeyEventSend: #value:
		to: 
		    [:char | 
		    "This is a test, so to save space I'm using blocks. This is not
		     good programming practice, as it leads to huge methods."

		    event label: 'key'.
		    ascii label: (String with: char)];
	    onKeyEventSend: #value:
		to: 
		    [:keyPressed | 
		    event label: 'ascii'.
		    key label: keyPressed];
	    onKeyEvent: 'Return'
		send: #beep
		to: Blox;
	    onMouseDownEvent: 1
		send: #value:
		to: 
		    [:pnt | 
		    mouse value: pnt.
		    event label: 'down'];
	    onMouseMoveEvent: 1
		send: #value:
		to: 
		    [:pnt | 
		    mouse value: pnt.
		    event label: 'move'];
	    onMouseUpEvent: 1
		send: #value:
		to: 
		    [:pnt | 
		    mouse value: pnt.
		    event label: 'up'];
	    onMouseDoubleEvent: 1
		send: #value:
		to: 
		    [:pnt | 
		    mouse value: pnt.
		    event label: 'double'];
	    onMouseTripleEvent: 1
		send: #value:
		to: 
		    [:pnt | 
		    mouse value: pnt.
		    event label: 'triple'];
	    onMouseEnterEventSend: #value to: [event label: 'enter'];
	    onMouseLeaveEventSend: #value to: [event label: 'leave']]
    ]

    formTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| cont |
	cont := BForm new: win.
	(BLabel new: cont label: 'label') width: 100 height: 50.
	(BButton new: cont label: 'button')
	    y: 50;
	    width: 100 height: 50]
    ]

    formattingTest [
	<category: 'testing single controls'>
	^
	[:win | 
	(BText new: win)
	    insertAtEnd: 'Trying edit box widgets' attribute: BTextAttributes red;
	    insertAtEnd: ' strikeout ' attribute: BTextAttributes strikeout;
	    insertAtEnd: ' red again ' attribute: BTextAttributes red;
	    insertAtEnd: ' now cyan '
		attribute: (BTextAttributes new foregroundColor: 'DarkCyan');
	    insertAtEnd: ' now background '
		attribute: (BTextAttributes yellow backgroundColor: 'DarkSlateBlue');
	    insertAtEnd: ' font '
		attribute: (BTextAttributes underline font: 'Helvetica 24')]
    ]

    textEventsTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| attrs bindings dlg cont text |
	win width: win width * 2.
	(bindings := BTextBindings new)
	    onMouseEnterEventSend: #value to: [text cursor: #hand2];
	    onMouseLeaveEventSend: #value to: [text cursor: #arrow];
	    onMouseUpEvent: 1
		send: #value:
		to: 
		    [:pnt | 
		    cont := BTransientWindow new: 'BLOX test' in: win.
		    cont height: 100.
		    dlg := BDialog new: cont label: 'You clicked on me'.
		    dlg 
			addButton: 'ok'
			receiver: self
			message: #yourself.
		    dlg loop].
	attrs := (BTextAttributes new)
		    underline;
		    center;
		    blue;
		    font: 'Helvetica 18';
		    events: bindings.
	(text := BText new: win)
	    cursor: #arrow;
	    insertAtEnd: 'Click on me!' attribute: attrs;
	    nl;
	    insertAtEnd: 'and not on me' attribute: BTextAttributes center]
    ]

    imageTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| image |
	image := BImage new: win image: self validImageFile.
	image 
	    onMouseMoveEvent: 1
	    send: #value:
	    to: [:pnt | image gamma: (0.2 max: pnt x / 100)].
	win width: image imageWidth height: image imageHeight]
    ]

    validImageFile [
	<category: 'testing single controls'>
	^(Directory kernel / '../blox/bear.gif') readStream
    ]

    labelTest [
	<category: 'testing single controls'>
	^
	[:win | 
	win width: 400.
	(BLabel new: win label: '*** a ''ridge'' blue label ***')
	    effect: #ridge;
	    x: 40;
	    width: 320 height: 100;
	    inset: 20;
	    backgroundColor: 'LightSkyBlue';
	    font: 'Helvetica 18']
    ]

    listboxTest [
	<category: 'testing single controls'>
	^
	[:win | 
	(BList new: win)
	    width: 100 height: 100;
	    inset: 2;
	    contents: #('test 1' 'test 2' 'test 3' 'test 4' 'test 5' 'test 6')]
    ]

    textTest [
	<category: 'testing single controls'>
	^
	[:win | 
	| text |
	win width: 300.
	text := BText new: win.
	text 
	    contents: 'Trying edit box widgets
this line is long - this line is long - this line is long - '.
	BButton new: text label: 'and has a button in it']
    ]

    fileDialogTest [
	<category: 'testing prompters'>
	^
	[:win | 
	| text file fileName |
	win width: 500.
	text := (BText new: win) font: 'Courier 9'.
	fileName := BDialog 
		    chooseFileToOpen: win
		    label: 'Open a file'
		    default: nil
		    defaultExtension: 'st'
		    types: #(#('Smalltalk files' '.st') #('Text files' '.txt' '.diz') #('C source files' '.c' '.h')).
	fileName isNil 
	    ifFalse: 
		[file := FileStream 
			    open: fileName
			    mode: 'r'
			    ifFail: [ReadStream on: '***FILE COULD NOT BE OPENED' copy].
		text contents: file contents.
		file close]]
    ]

    colorDialogTest [
	<category: 'testing prompters'>
	^
	[:win | 
	| label color |
	win width: 400.
	label := (BLabel new: win label: '*** this is gray (for now) ***')
		    effect: #groove;
		    x: 40;
		    width: 320 height: 100;
		    inset: 20;
		    font: 'Helvetica 18'.
	color := BDialog 
		    chooseColor: win
		    label: 'Choose a color!'
		    default: 'SteelBlue'.
	color isNil 
	    ifFalse: 
		[label
		    label: 'but now it isn''t anymore';
		    backgroundColor: color printNl]]
    ]

    menuTest [
	<category: 'testing menus'>
	^[:win | self createTestMenuBar: win]
    ]

    popupMenuTest [
	<category: 'testing menus'>
	^
	[:win | 
	| list menu menuItem |
	list := self listboxTest value: win.
	menu := BPopupMenu new: list.
	menuItem := BMenuItem new: menu label: 'a one'.
	menuItem callback: Gui message: 'itemChosen'.
	menuItem := BMenuItem new: menu label: 'and a two'.
	menuItem := BMenuItem new: menu label: 'and away'.
	menuItem := BMenuItem new: menu label: 'we go']
    ]

    createTestMenuBar: win [
	<category: 'testing menus'>
	| bar |
	bar := BMenuBar new: win.
	self createFirstMenu: bar.
	self createSecondMenu: bar
    ]

    createFirstMenu: bar [
	<category: 'testing menus'>
	| menu menuItem |
	menu := BMenu new: bar label: 'foo'.
	menuItem := BMenuItem new: menu label: 'a one'.
	menuItem callback: Gui message: 'itemChosen'.
	menuItem := BMenuItem new: menu label: 'and a two'.
	menuItem := BMenuItem new: menu label: 'and away'.
	menuItem := BMenuItem new: menu label: 'we go'.
	bar add: menu
    ]

    createSecondMenu: bar [
	<category: 'testing menus'>
	| menu menuItem |
	menu := BMenu new: bar label: 'bar'.
	menuItem := BMenuItem new: menu label: 'testme '.
	menuItem callback: Gui message: 'pickMeHarder'.
	menuItem := BMenuItem new: menu.
	menuItem := BCheckMenuItem new: menu label: 'don''t try me'.
	menuItem := BCheckMenuItem new: menu label: 'i do nothing'.
	menuItem := BMenuItem new: menu.
	menuItem := BCheckMenuItem new: menu label: 'abc'.
	menuItem value: true.
	bar add: menu.
	menuItem label: 'cba - changed my mind'.
	menuItem := BCheckMenuItem new: menu label: 'added on the fly'.
	menuItem value: true
    ]

    itemChosen [
	<category: 'testing menus'>
	'Picked me!!!' printNl
    ]

    pickMeHarder [
	<category: 'testing menus'>
	'Pick me harder' printNl
    ]

    iconTest [
	<category: 'testing extended widgets'>
	^
	[:win | 
	(self icon: BImage exclaim in: win) x: 30 y: 30.
	(self icon: BImage stop in: win) x: 70 y: 30.
	(self icon: BImage info in: win) x: 30 y: 70.
	(self icon: BImage question in: win) x: 70 y: 70.
	win width: 120 height: 120.
	win map]
    ]

    icon: data in: win [
	<category: 'testing extended widgets'>
	^(BImage new: win data: data)
	    inset: -16;
	    borderWidth: 0;
	    yourself
    ]

    progressTest [
	<category: 'testing extended widgets'>
	^
	[:win | 
	| ctl |
	win width: 150 height: 70.
	(ctl := BProgress new: win)
	    x: 5
		y: 5
		width: 140
		height: 60;
	    effect: #sunken;
	    borderWidth: 2;
	    value: 0.009000000000000002.
	Blox debug: false.
	
	[[win exists] whileTrue: 
		[(Delay forMilliseconds: 50) wait.
		[ctl value: (ctl value + 0.01) fractionPart] on: Error
		    do: [:sig | sig return]]] 
		forkAt: Processor userInterruptPriority]
    ]

    colorButtonTest [
	<category: 'testing extended widgets'>
	^
	[:win | 
	| btn |
	btn := BColorButton new: win.
	btn inset: 15]
    ]

    balloonTest [
	<category: 'testing extended widgets'>
	^
	[:win | 
	| eventSet btn |
	btn := BButton new: win label: 'Move here!'.
	btn
	    inset: 15;
	    width: 100 height: 100.
	(btn addEventSet: BBalloon) text: 'Sample balloon help']
    ]

]



Eval [
    Transcript
	nextPutAll: 'Available tests';
	nl.
    tests := OrderedCollection new.
    BLOX.Gui class selectors 
	do: [:sel | ('*Test*' match: sel) & (sel numArgs = 0) ifTrue: [tests add: sel]].
    tests asSortedCollection do: 
	    [:each | 
	    Transcript
		nextPutAll: '    ';
		print: each;
		nl]
]

