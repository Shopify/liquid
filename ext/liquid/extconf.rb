require 'mkmf'
$CFLAGS << ' -Wall -Werror'
$warnflags.gsub!(/-Wdeclaration-after-statement/, "")
create_makefile("liquid/liquid")
