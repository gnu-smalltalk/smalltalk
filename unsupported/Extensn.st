"From dnsmith@watson.ibm.com Fri Nov 24 02:13:31 1995
Path: gazette.engr.sgi.com!fido.asd.sgi.com!sgigate.sgi.com!swrinde!cs.utexas.edu!uwm.edu!chi-news.cic.net!newsfeed.internetmci.com!in2.uu.net!cospo.osis.gov!portal.dia.osis.gov!swiss.ans.net!newsgate.watson.ibm.com!watnews.watson.ibm.com!yasc137.watson.ibm.com!dnsmith
From: David N. Smith <dnsmith@watson.ibm.com>
Newsgroups: comp.lang.smalltalk
Subject: Re: Newbie Question: Formating Strings?
Date: 5 Nov 1995 16:05:30 GMT
Organization: IBM T J Watson Research Center, Hawthorne
Lines: 81
Distribution: world
Message-ID: <47inca$jq3@watnews2.watson.ibm.com>
References: <47ddgr$fdi@newsbf02.news.aol.com>
NNTP-Posting-Host: yasc137.watson.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
X-Newsreader: Nuntius 2.0.4_68K
X-XXMessage-ID: <ACC240302202E025@yasc137.watson.ibm.com>
X-XXDate: Sun, 5 Nov 1995 15:19:28 GMT

In article <47ddgr$fdi@newsbf02.news.aol.com> Cpraber, cpraber@aol.com
writes:
>I would like to format a string that for exampe contains a telephone
>number (ie '8101234567' so that the string is translated to (810)123-4567.
>
>If possible I'd like to use the same mechanism that the UI classes employ.
>I'm using VW 2.0

Wouldn't it be nice if it were possible to write something like:

Expression: '8101234567' formatAs: '(###)###-####' 
and get:    '(810)123-4567'

Expression: '5431234567' formatAs: '###-###-####' 
and get:    '543-123-4567'

Expression: '496449294' formatAs: '###-##-####' 
and get:    '496-44-9294'

Expression: '12345' formatAs: '$###.##' 
and get:    '$123.45'

Expression: 'SR2859591' formatAs: 'Publication number ####-####-#' 
and get:    'Publication number SR28-5959-1' 

Expression: '388350028456431097' formatAs: 
	      'Card Number #### ###### #### Expires ##/##' 
and get:    'Card Number 3883 500284 5643 Expires 10/97'

You can. Try Dave's patented Sunday Morning Quickie:"

!String methodsFor: 'extensions'!

formatAs: format
    " Answer a string holding format with all $# replaced 
      successive characters from self. "
    | str result inStream |
    result := WriteStream on: (String new: format size).

    " Set str to self; assure no errors by fixing odd cases "
    str := String new: format size.
    
    (self size = 0) ifFalse: [
	str replaceFrom: 1 to: self size with: self startingAt: 1
    ].
    str atAll: (self size + 1 to: format size) put: $ .

    " Process format, replacing each $# with a char from str "
    inStream := ReadStream on: str.
    format do: [ :ch |
	result nextPut:
	    (ch = $# ifTrue: [ inStream next ] ifFalse: [ ch ])
    ].
    ^ result contents! !

"(This code was run only on the closest available Smalltalk
implementation, tested only with the cases above [and three more
below], and comes with no guarantee, blah, blah...).

Error test cases:

   Expression:  '543' formatAs: '###-###-####' 
   Result:      '543-   -    '

   Expression:  '' formatAs: '###-###-####'  
   Result:      '   -   -    '

   Expression:  '1234' formatAs: '' 
   Result:      ''


Dave


__________________________________
David N. Smith
dnsmith@watson.ibm.com
70167.2274@compuserve.com
IBM T J Watson Research Center
Hawthorne, NY
__________________________________
Any opinions or recommendations
herein are those of the author  
and not of his employer.

"
