FileStream fileIn: 'PerfMonitor.st'!

PerfMonitor initialize!

"FileStream fileIn: 'examples/printHier.st'!"
"FileStream fileIn: 'examples/mem-usage.st'!"
FileStream fileIn: 'tstCPT.st'!

PerfMonitor print!
