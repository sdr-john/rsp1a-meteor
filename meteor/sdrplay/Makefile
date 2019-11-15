CFLAGS?=-O2 -g -Wall
LDLIBS+= -lpthread -lm -lmirsdrapi-rsp
CC?=gcc
PROGNAME=play_sdr

all: play_sdr

%.o: %.c
	$(CC) $(CFLAGS) -c $<

play_sdr: play_sdr.o
	$(CC) -g -o play_sdr play_sdr.o $(LDFLAGS) $(LDLIBS)

clean:
	rm -f *.o play_sdr
