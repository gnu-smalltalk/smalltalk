MenuBuilder subclass: DebuggerToolbar [
    DebuggerToolbar class >> menus [

        ^ {ContinueDebugCommand.
        StepIntoDebugCommand.
        StepToDebugCommand}
    ]
]
