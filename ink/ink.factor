USING: peg.ebnf ;
IN: ink

SINGLETONS: diversion knot stitch choice-block ;

: next-knot ( tokens -- i ) [ drop first knot? ] find-index drop ;
: next-stitch ( tokens -- i ) [ drop first stitch? ] find-index drop ;
: (collate-knot) ( tokens -- tokens' stitch_content/f )
    dup next-stitch [ cut swap ] [ f ] if*  ;
:: collate-knot ( tokens -- knot_content )
    LH{ } :> knot
    tokens dup next-stitch cut swap <enumerated> [ first2 swap knot set-at ] each
    [ unclip [ (collate-knot) dupd ] [ [ second knot set-at ] [ second knot set-at f ] bi-curry if* ] bi* ] loop drop
    knot ;
: (collate-story) ( tokens --  tokens' knot_content/f )
    dup next-knot [ cut swap ] [ f ] if*  ;
:: collate-story ( tokens -- story )
    LH{ } :> story
    tokens dup next-knot cut swap <enumerated> [ first2 swap story set-at ] each
    [ unclip [ (collate-story) dupd ] [ [ [ collate-knot ] [ second ] bi* story set-at ] [ [ collate-knot ] [ second ] bi* story set-at f ] bi-curry if* ] bi* ] loop drop
    story ;

! :: collate ( tokens collator -- collation )
!     LH{ } :> collation
!     tokens dup collator next-collator cut swap <enumerated> [ first2 swap collation set-at ] each
!     [ unclip [ collator (collate) dupd ] [ [ second collation set-at ] [ second collation set-at f ] bi-curry if* ] bi* ] loop drop
!     collation ;
! : collate-story ( tokens -- collation )
!     [ knot? ] collate ;
     

: trim-equals ( str -- str' ) [ [ CHAR: = = ] [ " " = ] bi or ] trim-tail ;

EBNF: tokenize [=[

tokenizer = default

space = " " | "\r" | "\t" | "\n"
spaces = space*

choicemarker = ( "*" | "+" )

notspace = (!(space) .)*

content_line= . (!("\n") .)+ => [[ first2 >string swap prefix ]]
choicetext= . (!("\n" | choicemarker) .)+ => [[ first2 >string swap prefix ]]
choiceblock = (choicemarker (spaces?)~ ( ( choicetext | diversion ) (spaces?)~ (choicemarker?) (spaces?)~ )+ (spaces?)~)+ => [[ first first2 concat swap prefix but-last choice-block swap 2array ]]
knotname= "==="~ " "? notspace => [[ last >string trim-equals knot swap 2array ]]
knot= knotname
stitchname= "="~ " "? notspace => [[ last >string trim-equals stitch swap 2array ]]
stitch= stitchname
diversion= "->"~ " "? notspace => [[ last >string trim-equals diversion swap 2array ]]

story = ((spaces?)~ ( knot | stitch | diversion | choiceblock | content_line ))*

rule = story

]=]
