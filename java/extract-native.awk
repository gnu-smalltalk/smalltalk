# Script to extract native method names from .class files
# Parses the output of the GCJ program jcf-dump.

BEGIN {
  firstfirst = 1
}

$1 == "Reading" {
  first = 1
  fname = $0
  class = $NF
  sub (/^\.\//, "", class)
  sub (/\.class\.$/, "", class)
  gsub (/\//, ".", class)
}

$2 == "Utf8:" {
  id = substr ($1, 2, length ($1) - 2)
  sub (/^[^"]*"/, "")
  $0 = substr ($0, 1, length - 1)
  pool[id] = $0
}

$1 == "Method" && / native / {
  # Extract the destination class of the native method.
  if (/ static /)
    static = "true"
  else
    static = "false"

  # Remove method specifiers and put name into a separate field.
  sub (/"/, " ")
  sub (/".*native/, " ")
  $0 = $0

  # Separate signature number and actual signature
  sub (/=/, " ", $5)
  $0 = $0

  # Extract method id and index of signature
  name = $3
  id = $5

  # Remove everything up to the signature
  sub (/^[^<]*</, "")

  # Parse an argument at a time
  decl = class "_" name
  sub (/.*\(/, "")
  if ($0 !~ /^\)/) {

    i = 1
    while (/,/)
      sub (/,/, ": arg" i++ " ")

    sub (/\).*/, ": arg" i++)
    gsub (/\[]/, "Array")
    decl = decl "_" $0
  }

  # Convert class names to be valid Smalltalk names
  gsub (/\./, "_", decl)

  # Print each method
  if (first)
    {
      if (!firstfirst)
        print " !\n"
      print "!JavaVM methodsFor: '" class "'!"
    }
  else
    print ""

  first = firstfirst = 0

  print ""
  print decl
  print "    <javaNativeMethod: #'" name pool[id] "'"
  print "        for: #{Java." class "} static: " static ">"
  print "    self notYetImplemented"
  printf "!"
}

END {
  print " !"
}
