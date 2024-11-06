make cli
make merge_coverage
make cli GEN_TEST_TYPE?=invalid_test
make merge_coverage
make cli GEN_TEST_TYPE?=default_values
make merge_coverage
make cli GEN_TEST_TYPE?=random_write
make merge_coverage
