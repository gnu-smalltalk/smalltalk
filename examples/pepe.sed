#! /bin/sed -nf

$a\
!

/^PepeImage installMethodWithSelector:/! {
  /./ {
    # Print the last method category
    x
    s/''/'/g
    /./p
    s/.*//p
    x
  }

  s/^PepeImage installClassWithName: '\([^']*\)' superclassName: '\([^']*\)' classVariableNames: '\([^']*\)' instanceVariableNames: '\([^']*\)'\.$/\2 subclass: #\1\
    instanceVariableNames: '\4'\
    classVariableNames: '\3'\
    poolDictionaries: ''\
    category: ''!/

  /./p
  b
}

# Concatenate a full Pepe command into hold space
:a
H 
/^\(.*[^']\)\{0,1\}\(''\)*'\.$/! {
  n
  ba
}

#---------- Process method declarations

x
s/^\n*//

# If hold space is empty, just insert the definition
/methodsFor:/! bt

# Check if we can merge the two methods
tx
:x
s/^\(!\([^ ]*\( class\)\{0,1\}\) methodsFor: nil!\([^!]*!\)*\) !\nPepeImage installMethodWithSelector: '\([^']*\)' inClassWithName: '\2' source: '\(.*\)'\.$/\1\
\
\6! !/

tz

#-------

# No, print the first category  
i\

h
s/\nPepeImage.*//
s/''/'/g
p

g
s/^\([^\n]*\n\)*PepeImage/PepeImage/

:t
s/^PepeImage installMethodWithSelector: '\([^']*\)' inClassWithName: '\([^']*\)' source: '\(.*\)'\.\(\nPepeImage installMethodWithSelector:\|$\)/\
!\2 methodsFor: nil!\
\
\3! !\4/

# And put the second back into hold space
:z
x
