USING: ;
QUALIFIED-WITH: ink i
IN: ink.tests

CONSTANT: unparsed-test-ink [[ -> as_you_understand
=== as_you_understand
as you understand it, one used to tell the night from pins of light in the sky, and the morning from a thother of lye rising out the lead, in which our bodies would be barely the bulk of a relative grot.
now see the nightward shift, the fog of the day that alwhere cloaks the environ thins to bewray the lightlines in the lift, as like a newborn birthed fom a mist to witness a world.
= context_intros
a world of three axels, each with one bearing inborn in us:
    * structure
    * energy
    * information
]]

{

}
[ unparsed-test-ink i:tokenize i:collate-story ] unit-test
