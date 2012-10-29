require 'mkmf'

dir_config("liquid_ext")
have_library("c", "main")

create_makefile("liquid_ext")
