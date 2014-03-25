require 'mkmf'
$CFLAGS << ' -Wall -Werror'
create_makefile("liquid/liquid")
