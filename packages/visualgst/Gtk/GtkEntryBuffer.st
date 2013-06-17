GTK.GtkEntryBuffer extend [

    getText [

        <cCall: 'gtk_entry_buffer_get_text' returning: #string args: #( #self #cObject )>
    ]

]

