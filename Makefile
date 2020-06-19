##
##          Copyright Daniel Haase 2020.
## Distributed under the Boost Software License, Version 1.0.
##      (See accompanying file LICENSE or copy at
##        https://www.boost.org/LICENSE_1_0.txt)
##
## This file belongs to objembed.
##
## Author: Daniel Haase
##

NAME = embed
VERSION = "0.1.0"
CC = gcc
CSTD = -ansi
ARCH = 64
GCCW = -Wall -Werror -Wextra -Wunused \
	-Wswitch -Wstrict-prototypes \
	-pedantic -pedantic-errors
DEFS = -DNDEBUG -DLINUX
CFLAGS = -O3 $(CSTD) -m$(ARCH) $(GCCW) $(DEFS)
STRIP = strip --strip-all
SCRP = bash objembed.sh
RM = rm -f

.PHONY: all clean pack

all: $(NAME)

$(NAME): $(NAME).o version.o
	$(CC) -o $@ $^
	$(STRIP) $(NAME)

$(NAME).o: $(NAME).c
	$(CC) -c $(CFLAGS) -o $@ $<

version.o: version.txt
	$(SCRP) $< $@ $(ARCH)

version.txt:
	echo $(VERSION) > $@

clean:
	$(RM) $(NAME) *.o core.* *~ version.txt

pack:
	tar cJf $(NAME)_$(VERSION).txz $(NAME).c objembed.sh Makefile LICENSE README*
