# How to contribute

## Things we will merge

* Bugfixes
* Performance improvements
* Features which are likely to be useful to the majority of Liquid users

## Things we won't merge

* Code which introduces considerable performance degrations
* Code which touches performance critical parts of Liquid and comes without benchmarks
* Features which are not important for most people (we want to keep the core Liquid code small and tidy)
* Features which can easily be implemented on top of Liquid (for example as a custom filter or custom filesystem)
* Code which comes without tests
* Code which breaks existing tests

## Workflow

* Fork the Liquid repository
* Create a new branch in your fork
* If it makes sense, add tests for your code and run a performance benchmark
* Make sure all tests pass
* Create a pull request
* In the description, ping one of [@boourns](https://github.com/boourns), [@fw42](https://github.com/fw42), [@camilo](https://github.com/camilo), [@dylanahsmith](https://github.com/dylanahsmith), or [@arthurnn](https://github.com/arthurnn) and ask for a code review.

