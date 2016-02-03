# How to contribute

## Things we will merge

* Bugfixes
* Performance improvements
* Features that are likely to be useful to the majority of Liquid users

## Things we won't merge

* Code that introduces considerable performance degrations
* Code that touches performance-critical parts of Liquid and comes without benchmarks
* Features that are not important for most people (we want to keep the core Liquid code small and tidy)
* Features that can easily be implemented on top of Liquid (for example as a custom filter or custom filesystem)
* Code that does not include tests
* Code that breaks existing tests

## Workflow

* Fork the Liquid repository
* Create a new branch in your fork
* If it makes sense, add tests for your code and/or run a performance benchmark
* Make sure all tests pass (`bundle exec rake`)
* Create a pull request

