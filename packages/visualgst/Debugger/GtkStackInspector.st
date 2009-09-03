GtkInspectorWidget subclass: GtkStackInspector [

    object: aContext [
        <category: 'accessing'>

        object := aContext.
        objectView := object stackInspectorView openOn: self object.
        inspectorTree setModel: objectView model.
        self refreshModel
    ]
]

