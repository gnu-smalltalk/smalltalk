"Test out the C Preprocessor"

'here we go' printNl!

FileStream fileIn: 'CPP.st'!

| s |
    PreprocessorStream test: '/usr/openwin/include/X11/Xlib.h'
!
