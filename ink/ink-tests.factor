USING: ;
QUALIFIED-WITH: ink i
IN: ink.tests

CONSTANT: unparsed-test-ink [[ -> as_you_understand
=== as_you_understand
as you understand it, one used to tell the night from pins of light in the sky, and the morning from a thother of lye rising out the lead, in which our bodies would be barely the bulk of a relative grot.
now see the nightward shift, the fog of the day that alwhere cloaks the environ thins to bewray the lightlines in the lift, as like a newborn birthed fom a mist to witness a world.
= context_intros
a world of three axels, each with one bearing inborn in us:
    * structure -> as_you_understand
    * energy
    * information
something other than structure selected
]]

{
    LH{
        { 0 { diversion "as_you_understand" } }
        { "as_you_understand" { knot LH{
                                    { 0 { "as you understand it, one used to tell the night from pins of light in the sky, and the morning from a thother of lye rising out the lead, in which our bodies would be barely the bulk of a relative grot." f } }
                                    { 1 { "now see the nightward shift, the fog of the day that alwhere cloaks the environ thins to bewray the lightlines in the lift, as like a newborn birthed fom a mist to witness a world." f } }
                                    { "context_intros" { stitch T{ enumerated { seq V{
                                                         { "a world of three axels, each with one bearing inborn in us:" f }
                                                         { choice-block V{ V{ "*" { "structure" { diversion "as_you_understand" } } } V{ "*" { "energy" f } } V{ "*" { "information" f } } } }
                                                         { "something other than structure selected" f }
                                                       } } } }
                                    }
                                }
                              }
        }
    }
}
[ unparsed-test-ink i:tokenize i:collate-story ] unit-test

{
  { knot
    LH{
       { 0 { "as you understand it, one used to tell the night from pins of light in the sky, and the morning from a thother of lye rising out the lead, in which our bodies would be barely the bulk of a relative grot." f } }
       { 1 { "now see the nightward shift, the fog of the day that alwhere cloaks the environ thins to bewray the lightlines in the lift, as like a newborn birthed fom a mist to witness a world." f } }
       { "context_intros" { stitch T{ enumerated { seq V{
                            { "a world of three axels, each with one bearing inborn in us:" f }
                            { choice-block V{ V{ "*" { "structure" { diversion "as_you_understand" } } } V{ "*" { "energy" f } } V{ "*" { "information" f } } } }
                            { "something other than structure selected" f }
                          } } } }
       }
  }
}
}
[ unparsed-test-ink i:new-story dup i:begin? continue ] unit-test

{
  "as you understand it, one used to tell the night from pins of light in the sky, and the morning from a thother of lye rising out the lead, in which our bodies would be barely the bulk of a relative grot.\n"
}
[ unparsed-test-ink i:new-story dup i:begin? dupd i:continue dupd i:continue [ dupd i:continue ] with-string-writer 2nip ] unit-test


{
[[ as you understand it, one used to tell the night from pins of light in the sky, and the morning from a thother of lye rising out the lead, in which our bodies would be barely the bulk of a relative grot.
now see the nightward shift, the fog of the day that alwhere cloaks the environ thins to bewray the lightlines in the lift, as like a newborn birthed fom a mist to witness a world.
a world of three axels, each with one bearing inborn in us:
]]
}
[ unparsed-test-ink i:new-story dup i:begin? [ i:continue-maximally ] with-string-writer 2nip ] unit-test

