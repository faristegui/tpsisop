sub runTests {
    ($tests) = @_;
    foreach my $name (keys($tests)) {
        print("$name--------------\n");
        $tests->{$name}();
    };
    print("-----------------------\n");
}

return 1