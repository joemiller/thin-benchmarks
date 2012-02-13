

installation
------------

Install bundler, if not installed, then install gems:

    gem install bundler --no-rdoc --no-ri
    bundle install

Install haproxy.  OS/X w/ homebrew:

    brew install haproxy

ApacheBench on OSX Lion is broken. Use the included `./ab` or follow the guide here: http://forrst.com/posts/Fixing_ApacheBench_bug_on_Mac_OS_X_Lion-wku

run tests
---------

Test with 1 thin process:

    ./run_tests.sh 1
