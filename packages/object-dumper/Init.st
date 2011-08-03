
Eval [
    ObjectDumper
        initialize;
        registerProxyClass: PluggableProxy for: CompiledMethod;
        registerProxyClass: PluggableProxy for: CompiledBlock;
        registerProxyClass: SingletonProxy for: Processor class
]

