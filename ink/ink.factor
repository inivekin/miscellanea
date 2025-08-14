USING: accessors arrays assocs combinators.short-circuit kernel
linked-assocs multiline peg.ebnf sequences strings ;
IN: ink

SINGLETONS: diversion knot stitch choice-block ;

: next-knot ( tokens -- i ) [ drop first knot? ] find-index drop ;
: next-stitch ( tokens -- i ) [ drop first stitch? ] find-index drop ;
: (collate-knot) ( tokens -- tokens' stitch_content/f )
    dup next-stitch [ cut swap ] [ f ] if*  ;
:: collate-knot ( tokens -- knot_content )
    LH{ } clone :> stitches
    tokens dup next-stitch cut swap <enumerated> [ first2 swap stitches set-at ] each
    [ unclip [ (collate-knot) dupd ] [ [ [ <enumerated> stitch swap 2array ] [ second stitches ] bi* set-at ] [ [ <enumerated> stitch swap 2array ] [ second stitches ] bi* set-at f ] bi-curry if* ] bi* ] loop drop
    stitches knot swap 2array ;
: (collate-story) ( tokens --  tokens' knot_content/f )
    dup next-knot [ cut swap ] [ f ] if*  ;
:: collate-story ( tokens -- story )
    LH{ } clone :> knots
    tokens dup next-knot cut swap <enumerated> [ first2 swap knots set-at ] each
    [ unclip [ (collate-story) dupd ] [ [ [ collate-knot ] [ second ] bi* knots set-at ] [ [ collate-knot ] [ second ] bi* knots set-at f ] bi-curry if* ] bi* ] loop drop
    knots ;

! :: collate ( tokens collator -- collation )
!     LH{ } :> collation
!     tokens dup collator next-collator cut swap <enumerated> [ first2 swap collation set-at ] each
!     [ unclip [ collator (collate) dupd ] [ [ second collation set-at ] [ second collation set-at f ] bi-curry if* ] bi* ] loop drop
!     collation ;
! : collate-story ( tokens -- collation )
!     [ knot? ] collate ;
     

: trim-equals ( str -- str' ) [ [ CHAR: = = ] [ " " = ] bi or ] trim-tail ;
: trim-space ( str -- str' ) [ 32 = ] trim-tail ;

! choiceblock = (choicemarker (spaces?)~ ( ( choicetext | diversion ) (spaces?)~ (choicemarker) (spaces?)~ )+ (spaces?)~)+ => [[ first first2 concat swap prefix but-last choice-block swap 2array ]]
EBNF: tokenize [=[

tokenizer = default

space = " " | "\r" | "\t" | "\n"
spaces = space*

choicemarker = ( "*" | "+" )

notspace = (!(space) .)*

diversion= "->"~ " "? notspace => [[ last >string trim-equals diversion swap 2array ]]
content_line= . (!("\n" | choicemarker | "->") .)+ diversion? => [[ first3 [ >string trim-space swap prefix ] [ 2array ] bi* ]]
choicetext= . (!("\n" | choicemarker | "->" ) .)+ diversion? => [[ first3 [ >string trim-space swap prefix ] [ 2array ] bi* ]]
choiceblock = (choicemarker (spaces?)~ ( choicetext | diversion ) (spaces?)~ )+ => [[ choice-block swap 2array ]]
knotname= "==="~ " "? notspace => [[ last >string trim-equals knot swap 2array ]]
knot= knotname
stitchname= "="~ " "? notspace => [[ last >string trim-equals stitch swap 2array ]]
stitch= stitchname

story = ((spaces?)~ ( knot | stitch | diversion | choiceblock | content_line ))*

rule = story

]=]

! has side-effectful change of the keys slot of story object, may also print something to output stream and alter story variables
GENERIC: (continue) ( story content type -- node )


TUPLE: story tree keys variables ;
C: <story> story

: init-knot-key ( keys -- keys' ) f suffix ;
: (resolve-story-node) ( story keys -- node ) [ swap second over number? [ >alist nth second ] [ ?at [ throw ] unless ] if ] each ;
: resolve-story-node ( story node -- node ) swap [ keys>> unclip drop (resolve-story-node) ] [ [ init-knot-key ] change-keys drop ] bi ;
: resolve-knot-node ( story node -- node ) swap [ keys>> unclip drop unclip drop (resolve-story-node) ] [ [ init-knot-key ] change-keys drop ] bi ;
: stitch-exists? ( story -- node/f ) [ tree>> ] [ keys>> ] bi (resolve-story-node) ;
: relative-key-change ( key story -- ) [ but-last swap suffix init-knot-key ] change-keys drop ;
: divert-to-stitch ( key story -- stitch/f ) [ nip stitch-exists? ]
                                             [ rot [ [ relative-key-change ] [ 2drop ] if ] keep ] 2bi ;
: divert-to-knot ( key story -- knot/f ) [ tree>> second at ] [ rot [ [ [ drop 1array init-knot-key ] change-keys drop ] [ 2drop ] if ] keep ] 2bi ;
: step-or-init-knot ( story -- story' ) [ unclip-last [ 1 + ] [ 0 ] if* suffix ] change-keys ;
: next-key ( story -- node )
    [ [ unclip-last drop ] change-keys step-or-init-knot stitch-exists? ] [ [ init-knot-key ] change-keys drop ] bi ;
! TODO instead of drop check for diversion
M: string (continue) print drop next-key ;
M: diversion (continue) drop first swap { [ divert-to-knot ] [ divert-to-stitch ] } 2|| ;

M: knot (continue) prefix [ step-or-init-knot ] [ resolve-story-node ] bi* ;
M: stitch (continue) prefix [ step-or-init-knot ] [ resolve-knot-node ] bi* ;

: end-story ( tree -- ) [ f "END" ] dip set-at ;
: new-story ( tree -- story ) tokenize collate-story dup end-story [ knot swap 2array ] [ >alist first first 1array ] bi f <story> ;
: begin? ( story -- node/f )
    stitch-exists? ; ! TODO this needn't exist, just check if current node is choice-block
: continue ( story node -- node ) unclip (continue) ;
: continue-maximally ( story node -- story node ) [ dupd continue dup first choice-block? not ] loop ;
! : choose-choice-index ( i -- ) ;

