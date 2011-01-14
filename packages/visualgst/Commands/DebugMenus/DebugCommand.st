Command subclass: DebugCommand [

    iconPath [

	^ (GtkLauncher / self stockIcon) file displayString
    ]

    buildToolItem [
        <category: 'build'>

        ^ (GTK.GtkToolButton new: (GTK.GtkImage newFromFile: self iconPath) label: self item)
                                connectSignal: 'clicked' to: self selector: #executeIfValid;
                                setTooltipText: self tooltip;
                                yourself
    ]
]

