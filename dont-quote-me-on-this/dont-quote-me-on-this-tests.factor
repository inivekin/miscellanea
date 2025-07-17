USING: dont-quote-me-on-this ;
IN: dont-quote-me-on-this.tests

{
    " some/test" t "P\""
}
[ "P\" some/test" ?paths-match-head ] unit-test

{
    "some/test" t "~//"
}
[ "~//some/test" ?paths-match-head ] unit-test

{
    "test/with space/in/filepath" t ".//"
}
[ ".//test/with\ space/in/filepath" ?paths-match-head ] unit-test
