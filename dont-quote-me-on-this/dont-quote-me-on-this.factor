USING: kernel.private ;
IN: dont-quote-me-on-this

IN: lexer.private

: (skip-word) ( col line -- newcol )
    [ [ forbid-tab " \"" member-eq? ] find-from CHAR: \" eq? [ 1 + ] when ]
    [ "//" subseq-index-from [ 2 + ] [ f ] if* 2dup and [ min ] [ or ] if ]
    [ nip length or ] 2tri ;

IN: strings.parser.private

: find-next-whitespace ( lexer -- i elt )
    { lexer } declare
    [ column>> ] [ line-text>> ] bi
    [ "\\ \n" member-eq? ] find-from ;

IN: strings.parser

DEFER: (parse-unescaped-whitespace)

: parse-to-unescaped-whitespace ( accum lexer i elt -- )
    { sbuf lexer fixnum fixnum } declare
    [ over lexer-subseq pick push-all ] dip
    CHAR: \ eq? [
        dup dup [ next-char ] bi@
        [ [ pick push ] bi@ ]
        [ drop 2dup next-line% ] if*
        (parse-unescaped-whitespace)
    ] [ 2drop ] if ;

: (parse-unescaped-whitespace) ( accum lexer -- )
    { sbuf lexer } declare
    dup still-parsing? [
        dup find-next-whitespace [
            parse-to-unescaped-whitespace
        ] [
            drop 2dup next-line%
            2drop
        ] if*
    ] [
        "'\"'" "[eof]" unexpected
    ] if ;

: parse-to-whitespace ( -- str )
    SBUF" " clone [
        lexer get (parse-unescaped-whitespace)
    ] keep unescape-string ;

: (until-whitespace) ( -- string )
    lexer get skip-blank parse-to-whitespace ;
: (./) ( -- pathname )
    (until-whitespace) >pathname ;
: (~/) ( -- pathname )
    "~/" (until-whitespace) append >pathname ;
: (/) ( -- pathname )
    "/" (until-whitespace) append >pathname ;

SYNTAX: // (/) suffix! ;
SYNTAX: .// (./) suffix! ;

SYNTAX: ~// (~/) suffix! ;

SYNTAX: <.// (./) suffix! utf8 suffix! [ read-lines ] suffix! \ with-file-reader suffix! ;
SYNTAX: <~// (~/) suffix! utf8 suffix! [ read-lines ] suffix! \ with-file-reader suffix! ;
SYNTAX: <// (/) suffix! utf8 suffix! [ read-lines ] suffix! \ with-file-reader suffix! ;
SYNTAX: [<.// (./) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-reader suffix! ;
SYNTAX: [<// (/) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-reader suffix! ;
SYNTAX: [<~// (~/) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-reader suffix! ;

: assumptive-write ( lines -- )
    dup sequence? [ [ present ] map ] [ present 1array ] if write-lines ;
SYNTAX: >.// (./) suffix! utf8 suffix! [ assumptive-write ] suffix! \ with-file-writer suffix! ;
SYNTAX: >>.// (./) suffix! utf8 suffix! [ assumptive-write ] suffix! \ with-file-appender suffix! ;
SYNTAX: [>.// (./) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-writer suffix! ;
SYNTAX: [>>.// (./) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-appender suffix! ;

SYNTAX: >~// (~/) suffix! utf8 suffix! [ assumptive-write ] suffix! \ with-file-writer suffix! ;
SYNTAX: >>~// (~/) suffix! utf8 suffix! [ assumptive-write ] suffix! \ with-file-appender suffix! ;
SYNTAX: [>~// (~/) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-writer suffix! ;
SYNTAX: [>>~// (~/) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-appender suffix! ;

SYNTAX: >// (/) suffix! utf8 suffix! [ assumptive-write ] suffix! \ with-file-writer suffix! ;
SYNTAX: >>// (/) suffix! utf8 suffix! [ assumptive-write ] suffix! \ with-file-appender suffix! ;
SYNTAX: [>// (/) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-writer suffix! ;
SYNTAX: [>>// (/) suffix! utf8 suffix! \ ] parse-until >quotation suffix! \ with-file-appender suffix! ;

SYNTAX: [// (/) suffix! \ ] parse-until >quotation suffix! \ with-directory suffix! ;
SYNTAX: [.// (./) suffix! \ ] parse-until >quotation suffix! \ with-directory suffix! ;
SYNTAX: [~// (~/) suffix! \ ] parse-until >quotation suffix! \ with-directory suffix! ;

SYNTAX: https:// (until-whitespace) resolve-host suffix! ;

IN: tools.completion

: complete-to-whitespace? ( tokens -- ? )
    
    first [ "//" subseq-of? ] [ CHAR: " swap in? not ] bi and ;

USE: tools.completion.private

: complete-pathname? ( tokens -- ? )
    [ "P\"" complete-string? ] [ complete-to-whitespace? ] bi or ;

IN: tools.completion
: ?paths-match-head ( str -- str ? head )
    {
        { [ dup "P\"" [ head? ] [ length ] bi and ] [ cut t rot ] }
        { [ dup "//" subseq-index ] [ 2 + cut t rot ] }
        [ f "" ]
    } cond* ;

: (paths-matching) ( str -- seq )
    dup last-path-separator [ 1 + cut ] [ drop "" ] if swap
    dup { [ file-exists? ] [ file-info directory? ] } 1&&
    ! complete given path else assume working directory
    [ drop "./" ] unless directory-paths completions ;
: paths-matching ( str -- seq )
    ?paths-match-head
    {
        { [ CHAR: ~ over in? ] [ "~/" ] }
        { [ dup "//" = ] [ "/" ] }
        [ "./" ]
    } cond
    [ [ (paths-matching) ] 2dip 
      '[ [ [ _ prepend ] dip ] assoc-map ] when
    ] with-directory ;

