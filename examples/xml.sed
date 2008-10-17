#! /bin/sed -f

#######################################################################
#
#   Convert VisualWorks XML file-outs to chunked format
#
########################################################################


#######################################################################
#
# Copyright 1999, 2000, 2008 Free Software Foundation, Inc.
# Written by Paolo Bonzini.
#
# This file is part of GNU Smalltalk
#
# GNU Smalltalk is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
# 
# GNU Smalltalk is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with GNU Smalltalk; see the file COPYING.  If not, write to
# the Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.  
#
########################################################################

# Remove processing instructions and comments
s/<?[^?]*?>//g

:xmlcomment
/^<!--/ {
  /-->/! {
    :continue
    N
    /-->/! b continue
  }
  s/^<!--[^-]*-\([^-][^-]*-\)*->//
  b xmlcomment
}

/^$/d

# Set the default namespace to be Smalltalk, and restore it
# when we reach the imported classes
1 {
  h
  s/.*/Smalltalk/
  x
}

/"Imported Classes:"/ {
  :imports
  /parcel imports/! {
    N
    b imports
  }
  x
  /^Smalltalk$/! i\
Namespace current: Smalltalk!
  s/.*/"Imported Classes:"/
  h
  d
}

0,/<st-source>/d
/<\/st-source>/,$ d

# Turn copyright into a Smalltalk comment; "..." becomes `...'
/<copyright>/ {
  :copyright
  /<\/copyright>/! {
    N
    b copyright
  }

  :quote
  s/"/`/
  s/"/'/
  t quote
  s|</\{0,1\}copyright>|"|g
  s/$/\
/
  b entities
}

# Turn timestamp into a Smalltalk string
/<time-stamp>/ {
  :timestamp
  /<\/time-stamp>/! {
    N
    b timestamp
  }
  s/'/''/g
  s|</\{0,1\}time-stamp>|'|g
  s/$/!/
  b entities
}

# Convert namespace declarations to `parent addSubspace: #child'
/<name-space>/ {
  :namespace
  /<\/name-space>/! {
    N
    b namespace
  }

  s|<name-space>\
<name>\([^<]*\)</name>\
<environment>\([^<]*\)</environment>.*\
</name-space>|\
\2 addSubspace: #\1!|
}

/<methods>/ {
  :methods
  /<\/methods>/! {
    N
    b methods
  }

  # Convert the body into chunk representation
  s|^<methods>||
  s|\n</methods>$| !|
  s|<body[^>]*>\([^\n]*.\)\n\{0,1\}|\1|g
  s|</body>|!|g

  # Subsume the category into the class-id tag
  s|\(</class-id>\) <category>\([^<].*\)</category>\n| methodsFor: '\2'!\
\1|
  b classid
}

/<comment>/ {
  :comment
  /<\/comment>/! {
    N
    b comment
  }
  # Reject namespace comments
  /<class-id>/! d

  # Quote any apostrophe, since we are inside a string, and
  # convert to `<class-id>class</class-id> comment: 'body' '
  s/'/''/g
  s|.*<class-id>\(.*\)</class-id>\
.*<body>\(.*\)</body>\
.*|\
<class-id>\1</class-id> comment: '\
\2'!\
|

  # Check if the class belongs to the active name-space
  # If so, omit the name-space specification.
  :classid
  s/<class-id>Core./<class-id>Smalltalk./
  G
  /<class-id>\([^.]*\)\..*\n\1$/  s/\(<class-id>\)[^.]*\./\1/
  s/\(.*\)\n.*/\1/

  s|<class-id>\([^<]*\)</class-id>|\1|

  # Fix a little the output
  /methodsFor/ s/^\n/&!/
  b entities
}

/<class>/ {
  :class
  /<\/class>/! {
    N
    b class
  }

  # We have no Core namespace
  s|<environment>Core</environment>|<environment>Smalltalk</environment>|
  s|<super>Core\.|<super>Smalltalk.|

  # If the class is to be defined in another environment, set
  # the current namespace
  G
  /"Imported Classes:"$/d

  /<environment>\([^<]*\)<\/environment>.*\n\1$/! {
    h
    s|.*<environment>\(.*\)</environment>.*|\
Namespace current: \1!|p
    s/.*Namespace current: //
    s/!//g
    x
  }
  s/\(.*\)\n.*/\1/

  # If the class and the superclass belong to the same namespace, remove
  # the namespace from the superclass
  s|\(<environment>\([^<]*\)</environment>.<super>\)\2\.|\1|

  # There is a default for the category
  s|<category></category>|<category>Unclassified</category>|

  # The attributes tag is optional ([^s> does not match attributes
  # closing tag)
  s|\([^s]>\)\(.\)\(</class>\)|\1\2<attributes></attributes>\2\3|
  
  # Do the bulk of the translation
  s|<class>\
<name>\([^<]*\)</name>\
<environment>\([^<]*\)</environment>\
<super>\([^<]*\)</super>\
<private>[^<]*</private>\
<indexed-type>\([^<]*\)</indexed-type>\
<inst-vars>\([^<]*\)</inst-vars>\
<class-inst-vars>\([^<]*\)</class-inst-vars>\
<imports>[^<]*</imports>\
<category>\([^<]*\)</category>\
<attributes>.*</attributes>\
</class>|\
\3 -\4- #\1\
    instanceVariableNames: '\5'\
    classVariableNames: ''\
    poolDictionaries: ''\
    category: '\2-\7'!\
\
\1 class instanceVariableNames: '\6'!|

  # Remove an empty class-instance variable declaration, and
  # convert the indexed instance variable declaration
  s/\n\n[^ ]* class instanceVariableNames: ''!//
  s/-none- #/subclass: #/
  s/-byte- #/variableByteSubclass: #/
  s/-word- #/variableWordSubclass: #/
  s/-objects\?- #/variableSubclass: #/
  b entities
}

/<shared-variable>/ {
  :var
  /<\/shared-variable>/! {
    N
    b var
  }

  # We have no Core namespace
  s|<environment>Core</environment>|<environment>Smalltalk</environment>|

  # If the class is to be defined in another environment, set
  # the current namespace
  G
  treset
  :reset
  s|<environment>\([^<]*\.\([^<]*\)\)\(.*\)\n\1$|<environment>\2\3|
  tenv
  s/\(.*\)\n.*/\1/
  :env

  # The attributes tag is optional ([^s> does not match attributes
  # closing tag)
  s|\([^s]>\)\(.\)\(</class>\)|\1\2<attributes></attributes>\2\3|

  # Do the bulk of the translation for pool variables
  s|<shared-variable>\
<name>\([^<]*\)</name>\
<environment>\([^<]*\)</environment>\
<private>\([^<]*\)</private>\
<constant>\([^<]*\)</constant>\
<category>\([^<]*\)</category>\
<initializer>\([^<]*\)</initializer>\
<attributes>.*</attributes>\
</shared-variable>|\
\2 at: #'\1' put: \6!|

  # Do the bulk of the translation for class variables
  s|<shared-variable>\
<name>\([^<]*\)</name>\
<environment>\([^<]*\)</environment>\
<private>\([^<]*\)</private>\
<constant>\([^<]*\)</constant>\
<category>\([^<]*\)</category>\
<attributes>.*</attributes>\
</shared-variable>|\
\2 addClassVariable: #'\1'!|

  b entities
}

/<initialize>/ {
  :initialize
  /<\/initialize>/! {
    N
    b initialize
  }
  s|</\{0,1\}initialize>||g

  # Convert initializations to sends of initialize
  s|</class-id>| initialize!|g
  s/<class-id>//g
  b entities
}

# Convert entities
:entities
s/<[^>]*>//g
s/&lt;/</g
s/&gt;/>/g
s/&amp;/\&/g

# Convert to four-character tabs and re-tabify
:tabs
s/\(\n\)	/\1    /g
s/\(\n	*\)        /\1	/g
t tabs  
