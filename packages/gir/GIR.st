"======================================================================
|
|   Smalltalk bindings for GObject introspection
|
 ======================================================================"

"======================================================================
|
| Copyright 2011 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


CObject subclass: GITypelib [
    <category: 'GObjectIntrospection'>
]

CObject subclass: GIRepository [
    <category: 'GObjectIntrospection'>
]

CObject subclass: GIBaseInfo [
    <category: 'GObjectIntrospection'>

    GIBaseInfo class >> getType [^0 ]

    InfoTypeToClass := nil.

    GIBaseInfo class >> initialize [
        | n |
        n := 0.
        self withAllSubclassesDo: [ :each | n := n max: each getType ].
        InfoTypeToClass := Array new: n.

        self withAllSubclassesDo: [ :each |
            each getType = 0
                ifFalse: [ InfoTypeToClass at: each getType put: each ] ]
    ]

    GIBaseInfo class >> infoTypeToClass: anInteger [
        ^InfoTypeToClass at: anInteger ifAbsent: [nil]
    ]

    narrow [
        | class |
        class := self class infoTypeToClass: self getType.
        class isNil ifFalse: [ self changeClassTo: class ].
        self addToBeFinalized
    ]

    free [
        (self isAbsolute and: [ self address > 0 ])
	    ifTrue: [ self unref. self address: 0 ]
    ]
]

GIBaseInfo subclass: GICallableInfo [
    <category: 'GObjectIntrospection'>
]

GIBaseInfo subclass: GIRegisteredTypeInfo [
    <category: 'GObjectIntrospection'>
]

GICallableInfo subclass: GIFunctionInfo [
    <category: 'GObjectIntrospection'>
    GIFunctionInfo class >> getType [ ^1 ]
]

GIFunctionInfo subclass: GICallbackInfo [
    <category: 'GObjectIntrospection'>
    GICallbackInfo class >> getType [ ^2 ]
]

GICallableInfo subclass: GISignalInfo [
    <category: 'GObjectIntrospection'>
    GISignalInfo class >> getType [ ^13 ]
]

GICallableInfo subclass: GIVfuncInfo [
    <category: 'GObjectIntrospection'>
    GIVfuncInfo class >> getType [ ^14 ]
]

GIBaseInfo subclass: GIArgInfo [
    <category: 'GObjectIntrospection'>
    GIArgInfo class >> getType [ ^17 ]
]

GIBaseInfo subclass: GIConstantInfo [
    <category: 'GObjectIntrospection'>
    GIConstantInfo class >> getType [ ^9 ]
]

GIBaseInfo subclass: GIErrorDomainInfo [
    <category: 'GObjectIntrospection'>
    GIErrorDomainInfo class >> getType [ ^10 ]
]

GIBaseInfo subclass: GIFieldInfo [
    <category: 'GObjectIntrospection'>
    GIFieldInfo class >> getType [ ^16 ]
]

GIBaseInfo subclass: GIPropertyInfo [
    <category: 'GObjectIntrospection'>
    GIPropertyInfo class >> getType [ ^15 ]
]

GIBaseInfo subclass: GITypeInfo [
    <category: 'GObjectIntrospection'>
    GITypeInfo class >> getType [ ^18 ]
]

GIBaseInfo subclass: GIValueInfo [
    <category: 'GObjectIntrospection'>
    GIValueInfo class >> getType [ ^12 ]
]

GIRegisteredTypeInfo subclass: GIInterfaceInfo [
    <category: 'GObjectIntrospection'>
    GIInterfaceInfo class >> getType [ ^8 ]
]

GIRegisteredTypeInfo subclass: GIObjectInfo [
    <category: 'GObjectIntrospection'>
    GIObjectInfo class >> getType [ ^7 ]
]

GIRegisteredTypeInfo subclass: GIEnumInfo [
    <category: 'GObjectIntrospection'>
    GIEnumInfo class >> getType [ ^5 ]
]

GIEnumInfo subclass: GIFlagsInfo [
    <category: 'GObjectIntrospection'>
    GIFlagsInfo class >> getType [ ^6 ]
]

GIRegisteredTypeInfo subclass: GIStructInfo [
    <category: 'GObjectIntrospection'>
    GIStructInfo class >> getType [ ^3 ]
]

GIStructInfo subclass: GIBoxedInfo [
    <category: 'GObjectIntrospection'>
    GIBoxedInfo class >> getType [ ^4 ]
]

GIRegisteredTypeInfo subclass: GIUnionInfo [
    <category: 'GObjectIntrospection'>
    GIUnionInfo class >> getType [ ^11 ]
]


CStruct subclass: GIAttributeIter [
    <category: 'GObjectIntrospection'>
    <declaration: #((#dummy #(#array #int 4)))>
]


!GIArgInfo methodsFor: 'C call-outs'!
getDirection
    <cCall: 'g_arg_info_get_direction' returning: #int
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
isReturnValue
    <cCall: 'g_arg_info_is_return_value' returning: #boolean
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
isOptional
    <cCall: 'g_arg_info_is_optional' returning: #boolean
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
isCallerAllocates
    <cCall: 'g_arg_info_is_caller_allocates' returning: #boolean
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
mayBeNull
    <cCall: 'g_arg_info_may_be_null' returning: #boolean
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
getOwnershipTransfer
    <cCall: 'g_arg_info_get_ownership_transfer' returning: #int
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
getScope
    <cCall: 'g_arg_info_get_scope' returning: #int
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
getClosure
    <cCall: 'g_arg_info_get_closure' returning: #int
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
getDestroy
    <cCall: 'g_arg_info_get_destroy' returning: #int
	args: #( #self )>! !

!GIArgInfo methodsFor: 'C call-outs'!
loadType: type
    <cCall: 'g_arg_info_load_type' returning: #void
	args: #( #self #cObject )>! !

!GITypelib class methodsFor: 'C call-outs'!
newFromMemory: memory len: len error: error
    <cCall: 'g_typelib_new_from_memory' returning: #{GITypelib}
	args: #( #cObject #int #cObjectPtr )>! !

!GITypelib class methodsFor: 'C call-outs'!
newFromConstMemory: memory len: len error: error
    <cCall: 'g_typelib_new_from_const_memory' returning: #{GITypelib}
	args: #( #cObject #int #cObjectPtr )>! !

!GITypelib class methodsFor: 'C call-outs'!
newFromMappedFile: mfile error: error
    <cCall: 'g_typelib_new_from_mapped_file' returning: #{GITypelib}
	args: #( #cObject #cObjectPtr )>! !

!GITypelib methodsFor: 'C call-outs'!
free
    (self isAbsolute and: [ self address > 0 ])
	ifTrue: [ self primFree. self address: 0 ]!
primFree
    <cCall: 'g_typelib_free' returning: #void
	args: #( #self )>! !

!GITypelib methodsFor: 'C call-outs'!
symbol: symbolName symbol: symbol
    <cCall: 'g_typelib_symbol' returning: #boolean
	args: #( #self #string #cObjectPtr )>! !

!GITypelib methodsFor: 'C call-outs'!
getNamespace
    <cCall: 'g_typelib_get_namespace' returning: #string
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
ref
    <cCall: 'g_base_info_ref' returning: #{GIBaseInfo}
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
unref
    <cCall: 'g_base_info_unref' returning: #void
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
getType
    <cCall: 'g_base_info_get_type' returning: #int
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
getName
    <cCall: 'g_base_info_get_name' returning: #string
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
getNamespace
    <cCall: 'g_base_info_get_namespace' returning: #string
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
getAttribute: name
    <cCall: 'g_base_info_get_attribute' returning: #string
	args: #( #self #string )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
isDeprecated
    <cCall: 'g_base_info_is_deprecated' returning: #boolean
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
iterateAttributes: iterator name: name value: value
    <cCall: 'g_base_info_iterate_attributes' returning: #boolean
	args: #( #self #cObject #cObject #cObject )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
getContainer
    <cCall: 'g_base_info_get_container' returning: #{GIBaseInfo}
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
getTypelib
    <cCall: 'g_base_info_get_typelib' returning: #{GITypelib}
	args: #( #self )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
equal: info2
    <cCall: 'g_base_info_equal' returning: #boolean
	args: #( #self #cObject )>! !

!GIBaseInfo methodsFor: 'C call-outs'!
new: type container: container typelib: typelib offset: offset
    <cCall: 'g_info_new' returning: #{GIBaseInfo}
	args: #( #int #cObject #cObject #int )>! !

!GICallableInfo methodsFor: 'C call-outs'!
getReturnAttribute: n
    <cCall: 'g_callable_info_get_return_attribute' returning: #{GITypeInfo}
	args: #( #self #int )>! !

!GICallableInfo methodsFor: 'C call-outs'!
getReturnType
    <cCall: 'g_callable_info_get_return_type' returning: #{GITypeInfo}
	args: #( #self )>! !

!GICallableInfo methodsFor: 'C call-outs'!
loadReturnType: type
    <cCall: 'g_callable_info_load_return_type' returning: #void
	args: #( #self #cObject )>! !

!GICallableInfo methodsFor: 'C call-outs'!
iterateReturnAttributes: iterator name: name value: value
    <cCall: 'g_callable_info_iterate_return_attributes' returning: #boolean
	args: #( #self #cObject #cObject #cObject )>! !

!GICallableInfo methodsFor: 'C call-outs'!
getCallerOwns
    <cCall: 'g_callable_info_get_caller_owns' returning: #int
	args: #( #self )>! !

!GICallableInfo methodsFor: 'C call-outs'!
mayReturnNull
    <cCall: 'g_callable_info_may_return_null' returning: #boolean
	args: #( #self )>! !

!GICallableInfo methodsFor: 'C call-outs'!
getNArgs
    <cCall: 'g_callable_info_get_n_args' returning: #int
	args: #( #self )>! !

!GICallableInfo methodsFor: 'C call-outs'!
getArg: n
    <cCall: 'g_callable_info_get_arg' returning: #{GIArgInfo}
	args: #( #self #int )>! !

!GICallableInfo methodsFor: 'C call-outs'!
loadArg: n arg: arg
    <cCall: 'g_callable_info_load_arg' returning: #void
	args: #( #self #int #cObject )>! !

!GIConstantInfo methodsFor: 'C call-outs'!
getValue: value
    <cCall: 'g_constant_info_get_value' returning: #int
	args: #( #self #cObject )>! !

!GIEnumInfo methodsFor: 'C call-outs'!
getNValues
    <cCall: 'g_enum_info_get_n_values' returning: #int
        args: #( #self )>! !

!GIEnumInfo methodsFor: 'C call-outs'!
getValue: n
    <cCall: 'g_enum_info_get_value' returning: #{GIValueInfo}
        args: #( #self #int )>! !

!GIEnumInfo methodsFor: 'C call-outs'!
getStorageType
    <cCall: 'g_enum_info_get_storage_type' returning: #int
        args: #( #self )>! !

!GIErrorDomainInfo methodsFor: 'C call-outs'!
getQuark
    <cCall: 'g_error_domain_info_get_quark' returning: #string
        args: #( #self )>! !

!GIErrorDomainInfo methodsFor: 'C call-outs'!
getCodes
    <cCall: 'g_error_domain_info_get_codes' returning: #{GIInterfaceInfo}
        args: #( #self )>! !

!GIFieldInfo methodsFor: 'C call-outs'!
getFlags
    <cCall: 'g_field_info_get_flags' returning: #int
	args: #( #self )>! !

!GIFieldInfo methodsFor: 'C call-outs'!
getSize
    <cCall: 'g_field_info_get_size' returning: #int
	args: #( #self )>! !

!GIFieldInfo methodsFor: 'C call-outs'!
getOffset
    <cCall: 'g_field_info_get_offset' returning: #int
	args: #( #self )>! !

!GIFieldInfo methodsFor: 'C call-outs'!
getField: fieldInfo mem: mem value: value
    <cCall: 'g_field_info_get_field' returning: #boolean
	args: #( #cObject #cObject #cObject )>! !

!GIFieldInfo methodsFor: 'C call-outs'!
setField: fieldInfo mem: mem value: value
    <cCall: 'g_field_info_set_field' returning: #boolean
	args: #( #cObject #cObject #cObject )>! !

!GIFunctionInfo methodsFor: 'C call-outs'!
getFlags
    <cCall: 'g_function_info_get_flags' returning: #int
	args: #( #self )>! !

!GIFunctionInfo methodsFor: 'C call-outs'!
getProperty
    <cCall: 'g_function_info_get_property' returning: #{GIPropertyInfo}
	args: #( #self )>! !

!GIFunctionInfo methodsFor: 'C call-outs'!
getSymbol
    <cCall: 'g_function_info_get_symbol' returning: #string
	args: #( #self )>! !

!GIFunctionInfo methodsFor: 'C call-outs'!
getVfunc
    <cCall: 'g_function_info_get_vfunc' returning: #{GIVFuncInfo}
	args: #( #self )>! !

!GIFunctionInfo methodsFor: 'C call-outs'!
invoke: inArgs nInArgs: nInArgs outArgs: outArgs nOutArgs: nOutArgs returnValue: returnValue error: error
    <cCall: 'g_function_info_invoke' returning: #boolean
	args: #( #self #cObject #int #cObject #int #cObject #cObjectPtr )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getNPrerequisites
    <cCall: 'g_interface_info_get_n_prerequisites' returning: #int
	args: #( #self )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getPrerequisite: n
    <cCall: 'g_interface_info_get_prerequisite' returning: #{GIBaseInfo}
	args: #( #self #int )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getNProperties
    <cCall: 'g_interface_info_get_n_properties' returning: #int
	args: #( #self )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getProperty: n
    <cCall: 'g_interface_info_get_property' returning: #{GIPropertyInfo}
	args: #( #self #int )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getNMethods
    <cCall: 'g_interface_info_get_n_methods' returning: #int
	args: #( #self )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getMethod: n
    <cCall: 'g_interface_info_get_method' returning: #{GIFunctionInfo}
	args: #( #self #int )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
findMethod: name
    <cCall: 'g_interface_info_find_method' returning: #{GIFunctionInfo}
	args: #( #self #string )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getNSignals
    <cCall: 'g_interface_info_get_n_signals' returning: #int
	args: #( #self )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getSignal: n
    <cCall: 'g_interface_info_get_signal' returning: #{GISignalInfo}
	args: #( #self #int )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getNVfuncs
    <cCall: 'g_interface_info_get_n_vfuncs' returning: #int
	args: #( #self )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getVfunc: n
    <cCall: 'g_interface_info_get_vfunc' returning: #{GIVFuncInfo}
	args: #( #self #int )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
findVfunc: name
    <cCall: 'g_interface_info_find_vfunc' returning: #{GIVFuncInfo}
	args: #( #self #string )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getNConstants
    <cCall: 'g_interface_info_get_n_constants' returning: #int
	args: #( #self )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getConstant: n
    <cCall: 'g_interface_info_get_constant' returning: #{GIConstantInfo}
	args: #( #self #int )>! !

!GIInterfaceInfo methodsFor: 'C call-outs'!
getIfaceStruct
    <cCall: 'g_interface_info_get_iface_struct' returning: #{GIStructInfo}
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getTypeName
    <cCall: 'g_object_info_get_type_name' returning: #string
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getTypeInit
    <cCall: 'g_object_info_get_type_init' returning: #string
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getAbstract
    <cCall: 'g_object_info_get_abstract' returning: #boolean
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getFundamental
    <cCall: 'g_object_info_get_fundamental' returning: #boolean
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getParent
    <cCall: 'g_object_info_get_parent' returning: #{GIObjectInfo}
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getNInterfaces
    <cCall: 'g_object_info_get_n_interfaces' returning: #int
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getInterface: n
    <cCall: 'g_object_info_get_interface' returning: #{GIInterfaceInfo}
	args: #( #self #int )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getNFields
    <cCall: 'g_object_info_get_n_fields' returning: #int
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getField: n
    <cCall: 'g_object_info_get_field' returning: #{GIFieldInfo}
	args: #( #self #int )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getNProperties
    <cCall: 'g_object_info_get_n_properties' returning: #int
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getProperty: n
    <cCall: 'g_object_info_get_property' returning: #{GIPropertyInfo}
	args: #( #self #int )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getNMethods
    <cCall: 'g_object_info_get_n_methods' returning: #int
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getMethod: n
    <cCall: 'g_object_info_get_method' returning: #{GIFunctionInfo}
	args: #( #self #int )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
findMethod: name
    <cCall: 'g_object_info_find_method' returning: #{GIFunctionInfo}
	args: #( #self #string )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getNSignals
    <cCall: 'g_object_info_get_n_signals' returning: #int
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getSignal: n
    <cCall: 'g_object_info_get_signal' returning: #{GISignalInfo}
	args: #( #self #int )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getNVfuncs
    <cCall: 'g_object_info_get_n_vfuncs' returning: #int
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getVfunc: n
    <cCall: 'g_object_info_get_vfunc' returning: #{GIVFuncInfo}
	args: #( #self #int )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
findVfunc: name
    <cCall: 'g_object_info_find_vfunc' returning: #{GIVFuncInfo}
	args: #( #self #string )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getNConstants
    <cCall: 'g_object_info_get_n_constants' returning: #int
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getConstant: n
    <cCall: 'g_object_info_get_constant' returning: #{GIConstantInfo}
	args: #( #self #int )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getClassStruct
    <cCall: 'g_object_info_get_class_struct' returning: #{GIStructInfo}
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getRefFunction
    <cCall: 'g_object_info_get_ref_function' returning: #string
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getUnrefFunction
    <cCall: 'g_object_info_get_unref_function' returning: #string
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getSetValueFunction
    <cCall: 'g_object_info_get_set_value_function' returning: #string
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getGetValueFunction
    <cCall: 'g_object_info_get_get_value_function' returning: #string
	args: #( #self )>! !

!GIPropertyInfo methodsFor: 'C call-outs'!
getFlags
    <cCall: 'g_property_info_get_flags' returning: #int
	args: #( #self )>! !

!GIPropertyInfo methodsFor: 'C call-outs'!
getOwnershipTransfer
    <cCall: 'g_property_info_get_ownership_transfer' returning: #int
	args: #( #self )>! !

!GIRegisteredTypeInfo methodsFor: 'C call-outs'!
getTypeName
    <cCall: 'g_registered_type_info_get_type_name' returning: #string
	args: #( #self )>! !

!GIRegisteredTypeInfo methodsFor: 'C call-outs'!
getTypeInit
    <cCall: 'g_registered_type_info_get_type_init' returning: #string
	args: #( #self )>! !

!GIRegisteredTypeInfo methodsFor: 'C call-outs'!
getGType
    <cCall: 'g_registered_type_info_get_g_type' returning: #long
	args: #( #self )>! !

!GIObjectInfo methodsFor: 'C call-outs'!
getFlags
    <cCall: 'g_signal_info_get_flags' returning: #int
	args: #( #self )>! !

!GISignalInfo methodsFor: 'C call-outs'!
getClassClosure
    <cCall: 'g_signal_info_get_class_closure' returning: #{GIVfuncInfo}
	args: #( #self )>! !

!GISignalInfo methodsFor: 'C call-outs'!
getTrueStopsEmit
    <cCall: 'g_signal_info_true_stops_emit' returning: #boolean
	args: #( #self )>! !

!GIStructInfo methodsFor: 'C call-outs'!
getNFields
    <cCall: 'g_struct_info_get_n_fields' returning: #int
	args: #( #self )>! !

!GIStructInfo methodsFor: 'C call-outs'!
getField: n
    <cCall: 'g_struct_info_get_field' returning: #{GIFieldInfo}
	args: #( #self #int )>! !

!GIStructInfo methodsFor: 'C call-outs'!
getNMethods
    <cCall: 'g_struct_info_get_n_methods' returning: #int
	args: #( #self )>! !

!GIStructInfo methodsFor: 'C call-outs'!
getMethod: n
    <cCall: 'g_struct_info_get_method' returning: #{GIFunctionInfo}
	args: #( #self #int )>! !

!GIStructInfo methodsFor: 'C call-outs'!
findMethod: name
    <cCall: 'g_struct_info_find_method' returning: #{GIFunctionInfo}
	args: #( #self #string )>! !

!GIStructInfo methodsFor: 'C call-outs'!
getSize
    <cCall: 'g_struct_info_get_size' returning: #int
	args: #( #self )>! !

!GIStructInfo methodsFor: 'C call-outs'!
getAlignment
    <cCall: 'g_struct_info_get_alignment' returning: #int
	args: #( #self )>! !

!GIStructInfo methodsFor: 'C call-outs'!
isGtypeStruct
    <cCall: 'g_struct_info_is_gtype_struct' returning: #boolean
	args: #( #self )>! !

!GIStructInfo methodsFor: 'C call-outs'!
isForeign
    <cCall: 'g_struct_info_is_foreign' returning: #boolean
	args: #( #self )>! !

!GITypeInfo methodsFor: 'C call-outs'!
isPointer
    <cCall: 'g_type_info_is_pointer' returning: #boolean
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getTag
    <cCall: 'g_type_info_get_tag' returning: #int
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getParamType: n
    <cCall: 'g_type_info_get_param_type' returning: #{GITypeInfo}
        args: #( #cObject #int )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getInterface
    <cCall: 'g_type_info_get_interface' returning: #{GIBaseInfo}
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getArrayLength
    <cCall: 'g_type_info_get_array_length' returning: #int
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getArrayFixedSize
    <cCall: 'g_type_info_get_array_fixed_size' returning: #int
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
isZeroTerminated
    <cCall: 'g_type_info_is_zero_terminated' returning: #boolean
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getArrayType
    <cCall: 'g_type_info_get_array_type' returning: #int
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getNErrorDomains
    <cCall: 'g_type_info_get_n_error_domains' returning: #int
        args: #( #cObject )>! !

!GITypeInfo methodsFor: 'C call-outs'!
getErrorDomain: n
    <cCall: 'g_type_info_get_error_domain' returning: #{GIErrorDomainInfo}
        args: #( #cObject #int )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getNFields
    <cCall: 'g_union_info_get_n_fields' returning: #int
	args: #( #self )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getField: n
    <cCall: 'g_union_info_get_field' returning: #{GIFieldInfo}
	args: #( #self #int )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getNMethods
    <cCall: 'g_union_info_get_n_methods' returning: #int
	args: #( #self )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getMethod: n
    <cCall: 'g_union_info_get_method' returning: #{GIFunctionInfo}
	args: #( #self #int )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
isDiscriminated
    <cCall: 'g_union_info_is_discriminated' returning: #boolean
	args: #( #self )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getDiscriminatorOffset
    <cCall: 'g_union_info_get_discriminator_offset' returning: #int
	args: #( #self )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getDiscriminatorType
    <cCall: 'g_union_info_get_discriminator_type' returning: #{GITypeInfo}
	args: #( #self )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getDiscriminator: n
    <cCall: 'g_union_info_get_discriminator' returning: #{GIConstantInfo}
	args: #( #self #int )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
findMethod: name
    <cCall: 'g_union_info_find_method' returning: #{GIFunctionInfo}
	args: #( #self #string )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getSize
    <cCall: 'g_union_info_get_size' returning: #int
	args: #( #self )>! !

!GIUnionInfo methodsFor: 'C call-outs'!
getAlignment
    <cCall: 'g_union_info_get_alignment' returning: #int
	args: #( #self )>! !

!GIValueInfo methodsFor: 'C call-outs'!
getValue: n
    <cCall: 'g_value_info_get_value' returning: #long
        args: #( #self #int )>! !

!GIVfuncInfo methodsFor: 'C call-outs'!
getFlags
    <cCall: 'g_vfunc_info_get_flags' returning: #int
	args: #( #self )>! !

!GIVfuncInfo methodsFor: 'C call-outs'!
getOffset
    <cCall: 'g_vfunc_info_get_offset' returning: #int
	args: #( #self )>! !

!GIVfuncInfo methodsFor: 'C call-outs'!
getSignal
    <cCall: 'g_vfunc_info_get_signal' returning: #{GISignalInfo}
	args: #( #self )>! !

!GIVfuncInfo methodsFor: 'C call-outs'!
getInvoker
    <cCall: 'g_vfunc_info_get_invoker' returning: #{GIFunctionInfo}
	args: #( #self )>! !

!GIRepository class methodsFor: 'C call-outs'!
getDefault
    <cCall: 'g_irepository_get_default' returning: #{GIRepository}
	args: #( )>! !

!GIRepository class methodsFor: 'C call-outs'!
prependSearchPath: directory
    <cCall: 'g_irepository_prepend_search_path' returning: #void
	args: #( #string )>! !

!GIRepository class methodsFor: 'C call-outs'!
getSearchPath
    <cCall: 'g_irepository_get_search_path' returning: #{GLib.GSList}
	args: #( )>! !

!GIRepository methodsFor: 'C call-outs'!
getTypelibPath: namespace
    <cCall: 'g_irepository_get_typelib_path' returning: #string
	args: #( #self #string )>! !

!GIRepository methodsFor: 'C call-outs'!
getSharedLibrary: namespace
    <cCall: 'g_irepository_get_shared_library' returning: #string
	args: #( #self #string )>! !

!GIRepository methodsFor: 'C call-outs'!
getCPrefix: namespace
    <cCall: 'g_irepository_get_c_prefix' returning: #string
	args: #( #self #string )>! !

!GIRepository methodsFor: 'C call-outs'!
getVersion: namespace
    <cCall: 'g_irepository_get_version' returning: #string
	args: #( #self #string )>! !

!GIRepository methodsFor: 'C call-outs'!
isRegistered: namespace version: version
    <cCall: 'g_irepository_is_registered' returning: #boolean
	args: #( #self #string #string )>! !

!GIRepository methodsFor: 'C call-outs'!
findByName: namespace name: name
    <cCall: 'g_irepository_find_by_name' returning: #{GIBaseInfo}
	args: #( #self #string #string )>! !

!GIRepository methodsFor: 'C call-outs'!
enumerateVersions: namespace
    <cCall: 'g_irepository_enumerate_versions' returning: #{GLib.GList}
	args: #( #self #string )>! !

!GIRepository methodsFor: 'C call-outs'!
loadTypelib: typelib flags: flags error: error
    <cCall: 'g_irepository_load_typelib' returning: #string
	args: #( #self #cObject #int #cObjectPtr )>! !

!GIRepository methodsFor: 'C call-outs'!
require: namespace version: version flags: flags error: error
    <cCall: 'g_irepository_require' returning: #{GITypelib}
	args: #( #self #string #string #int #cObjectPtr )>! !

!GIRepository methodsFor: 'C call-outs'!
requirePrivate: typelibDir namespace: namespace version: version flags: flags error: error
    <cCall: 'g_irepository_require_private' returning: #{GITypelib}
	args: #( #self #string #string #string #int #cObjectPtr )>! !

!GIRepository methodsFor: 'C call-outs'!
getDependencies: namespace
    <cCall: 'g_irepository_get_dependencies' returning: #{CString}
	args: #( #self #string )>! !

!GIRepository methodsFor: 'C call-outs'!
getLoadedNamespaces
    <cCall: 'g_irepository_get_loaded_namespaces' returning: #{CString}
	args: #( #self )>! !

!GIRepository methodsFor: 'C call-outs'!
findByGtype: gtype
    <cCall: 'g_irepository_find_by_gtype' returning: #{GIBaseInfo}
	args: #( #self #long )>! !

!GIRepository methodsFor: 'C call-outs'!
getNInfos: namespace
    <cCall: 'g_irepository_get_n_infos' returning: #int
	args: #( #self #string )>! !

!GIRepository methodsFor: 'C call-outs'!
getInfo: namespace index: index
    <cCall: 'g_irepository_get_info' returning: #{GIBaseInfo}
	args: #( #self #string #int )>! !

!GIRepository class methodsFor: 'C call-outs'!
dump: arg error: error
    <cCall: 'g_irepository_dump' returning: #boolean
	args: #( #string #cObjectPtr )>! !


!GIBaseInfo class methodsFor: 'GIInfoType'!
typeTagToString: anInteger
    <cCall: 'g_info_type_to_string' returning: #string
	args: #( #int )>! !

giInfoTypeInvalid ^0!
giInfoTypeFunction ^1!
giInfoTypeCallback ^2!
giInfoTypeStruct ^3!
giInfoTypeBoxed ^4!
giInfoTypeEnum ^5!
giInfoTypeFlags ^6!
giInfoTypeObject ^7!
giInfoTypeInterface ^8!
giInfoTypeConstant ^9!
giInfoTypeErrorDomain ^10!
giInfoTypeUnion ^11!
giInfoTypeValue ^12!
giInfoTypeSignal ^13!
giInfoTypeVfunc ^14!
giInfoTypeProperty ^15!
giInfoTypeField ^16!
giInfoTypeArg ^17!
giInfoTypeType ^18!
giInfoTypeUnresolved ^19! !

!GIBaseInfo class methodsFor: 'GITransfer'!
giTransferNothing ^0!
giTransferContainer ^1!
giTransferEverything ^2! !

!GIBaseInfo class methodsFor: 'GIDirection'!
giDirectionIn ^0!
giDirectionOut ^1!
giDirectionInout ^2! !

!GIBaseInfo class methodsFor: 'GIScopeType'!
giScopeTypeInvalid ^0!
giScopeTypeCall ^1!
giScopeTypeAsync ^2!
giScopeTypeNotified ^3! !

!GIBaseInfo class methodsFor: 'GITypeTag'!
typeTagToString: anInteger
    <cCall: 'g_type_tag_to_string' returning: #string
	args: #( #int )>!

giTypeTagVoid ^0!
giTypeTagBoolean ^1!
giTypeTagInt8 ^2!
giTypeTagUint8 ^3!
giTypeTagInt16 ^4!
giTypeTagUint16 ^5!
giTypeTagInt32 ^6!
giTypeTagUint32 ^7!
giTypeTagInt64 ^8!
giTypeTagUint64 ^9!
giTypeTagFloat ^10!
giTypeTagDouble ^11!
giTypeTagGtype ^12!
giTypeTagUtf8 ^13!
giTypeTagFilename ^14!
giTypeTagArray ^15!
giTypeTagInterface ^16!
giTypeTagGlist ^17!
giTypeTagGslist ^18!
giTypeTagGhash ^19!
giTypeTagError ^20! !

!GITypeInfo class methodsFor: 'GIArrayType'!
giArrayTypeC ^0!
giArrayTypeArray ^1!
giArrayTypePtrArray ^2!
giArrayTypeByteArray ^3! !

!GIFieldInfo class methodsFor: 'GIFieldInfoFlags'!
giFieldIsReadable ^1!
giFieldIsWritable ^2! !

!GIVfuncInfo class methodsFor: 'GIVFuncInfoFlags'!
giVfuncMustChainUp ^1!
giVfuncMustOverride ^2!
giVfuncMustNotOverride ^4! !

!GIFunctionInfo class methodsFor: 'GIFunctionInfoFlags'!
giFunctionIsMethod ^1!
giFunctionIsConstructor ^2!
giFunctionIsGetter ^4!
giFunctionIsSetter ^8!
giFunctionWrapsVfunc ^16!
giFunctionThrows ^32! !

!GIRepository class methodsFor: 'GIRepositoryLoadFlags'!
giRepositoryLoadFlagLazy ^1! !

!GIRepository class methodsFor: 'GIRepositoryError'!
giRepositoryErrorTypelibNotFound ^0!
giRepositoryErrorNamespaceMismatch ^1!
giRepositoryErrorNamespaceVersionConflict ^2!
giRepositoryErrorLibraryNotFound ^3! !

Eval [
    GIBaseInfo initialize
]

"st> r := GIRepository getDefault
GIRepository(16r12CD8C0)
st> t := r require: 'GObject' version: '2.0' flags: 0 error: nil
GITypelib(16r12A9AC0)
st> r getTypelibPath: 'GObject'
'/usr/lib64/girepository-1.0/GObject-2.0.typelib'
st> r getSharedLibrary: 'GObject'
'libgobject-2.0.so.0'
st> r findByName: 'GObject' name: 'Object'
GIObjectInfo(16r11B4320)
st> r findByName: 'GObject' name: 'Value'
GIStructInfo(16r11B4370)
st> o := r findByName: 'GObject' name: 'Object'
GIObjectInfo(16r12B8400)
st> o getTypeName
'GObject'
st> o getTypeInit
'intern'
st> o getAbstract
true
st> o getParent
nil
st> o getNMethods
23
st> 0 to: 22 collect: [:each |
        | name f |
        f := o getMethod: each. name := f getName. f unref. name]
('set_property' 'get_property' 'freeze_notify' 'notify' 'notify_by_pspec' 'thaw_notify' 'weak_ref' 'weak_unref' 'add_weak_pointer' 'remove_weak_pointer' 'add_toggle_ref' 'remove_toggle_ref' 'get_qdata' 'set_qdata' 'set_qdata_full' 'steal_qdata' 'get_data' 'set_data' 'set_data_full' 'steal_data' 'watch_closure' 'force_floating' 'run_dispose' )
st> f := o findMethod: 'set_property'
GIFunctionInfo(16r12B8850)
st> f getSymbol
'g_object_set_property'

"

