Smalltalk.Object subclass: GtkClock [
    | canvas hour minute process radius second window x y |

    GtkClock class >> open [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    showAll;
	    yourself
    ]

    GtkClock class >> openSized: aPoint [
	<category: 'user interface'>
	
	^ (self new)
	    initialize;
	    resize: aPoint;
	    showAll;
	    yourself
    ]

    quit [
	<category: 'events'>

	process terminate.
	window hide
    ]

    time [
	<category: 'time'>

	| now |
	now := DateTime now.
        hour := now hour.
        minute := now minute.
        second := now second.
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

    drawClockCircle: context [
	<category: 'drawing'>

        context
            lineWidth: 6;
            stroke: [ context arc: x@y radius: radius from: 0 to: Float pi * 2 ]
    ]

    drawHourMarker: context [
	<category: 'drawing'>

        1 to: 12 do: [ :i |
            context
                lineWidth: 4;
                stroke: [ | inset |
                    inset := 0.1 * radius.
                    context
                        moveTo: (x + ((radius - inset) * (i * Float pi / 6.0) cos)) @ (y + ((radius - inset) * (i * Float pi / 6.0) sin));
                        lineTo: (x + (radius * (i * Float pi / 6.0) cos)) @ (y + (radius * (i * Float pi / 6.0) sin)) ] ]
    ]

    drawClockLine: context angle: anAngFloat [
	<category: 'drawing'>

        context
            lineWidth: 4;
            paint: [
                context stroke: [
                    context
                        sourceRed: 1 green: 0.2 blue: 0.2 alpha: 1.0;
                        moveTo: x@y;
                        lineTo: (x + (radius * anAngFloat  cos)) @ (y + (radius * anAngFloat sin)) ] ]
            withAlpha: 0.64
    ]

    drawHourLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (hour \\ 12 * (Float pi / 6.0)) - (Float pi / 2.0).
    ]

    drawMinuteLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (minute * (Float pi / 30.0)) - (Float pi / 2.0)
    ]

    drawSecondLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (second * (Float pi / 30.0)) - (Float pi / 2.0)
    ]

    drawClock: context [
	<category: 'drawing'>

	self
            drawClockCircle: context;
            drawHourMarker: context;
            drawHourLine: context;
            drawMinuteLine: context;
            drawSecondLine: context
    ]

    expose: aGtkWidget event: aGdkEventExpose [

	aGtkWidget getWindow withContextDo: [ :cr |
	    canvas := cr.

	    x := 128.
	    y := 128.

	    self 
		clearArea: aGtkWidget getAllocation;
		time;
		drawClock: cr ].

	^ true
    ]

    initialize [
	<category: 'intialization'>

	window := (GTK.GtkWindow new: GTK.Gtk gtkWindowToplevel).
	window 
	    setColormap: window getScreen getRgbaColormap;
	    connectSignal: 'expose_event' to: self selector: #'expose:event:';
	    connectSignal: 'delete-event' to: self selector: #'delete:event:';
	    setDecorated: false.
	radius := 100
    ]

    delete: aGtkWidget event: aGdkEvent [
        <category: 'windows event'>

        self quit.
        ^ true
    ]

    resize: aPoint [
	<category: 'user interface'>

	window resize: aPoint x height: aPoint y
    ]

    showAll [
	| delay |

	delay := Delay forSeconds: 1.
	window showAll.
	process := [ [ true ] whileTrue: [ window queueDraw. delay wait ] ] fork
    ]
]
