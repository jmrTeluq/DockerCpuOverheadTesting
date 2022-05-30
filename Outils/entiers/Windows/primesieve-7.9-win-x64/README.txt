primesieve 7.9
May 03, 2022
Kim Walisch, <kim.walisch@gmail.com>

About primesieve
================

  primesieve is a free software program that generates primes and
  prime k-tuplets (twin primes, prime triplets, ...) < 2^64 using a
  highly optimized implementation of the sieve of Eratosthenes.

  Homepage:   https://github.com/kimwalisch/primesieve

Usage examples
==============

  Open a terminal (Command Prompt) and run:

  primesieve 10000           Count the primes up to 10000
  primesieve 10000 --print   Print the primes up to 10000
  primesieve 1e9 2e9 -p2     Print the twin primes within [10^9, 2*10^9]
  primesieve 1e9 -d100 -c2   Count the twin primes within [10^9, 10^9+100]

Command-line options
====================

  Usage: primesieve [START] STOP [OPTION]...
  Generate the primes and/or prime k-tuplets inside [START, STOP]
  (< 2^64) using the segmented sieve of Eratosthenes.

  Options:
    -c, --count[=NUM+]  Count primes and/or prime k-tuplets, NUM <= 6.
                        Count primes: -c or --count (default option),
                        count twin primes: -c2 or --count=2,
                        count prime triplets: -c3 or --count=3, ...
        --cpu-info      Print CPU information (cache sizes).
    -d, --dist=DIST     Sieve the interval [START, START + DIST].
    -h, --help          Print this help menu.
    -n, --nth-prime     Find the nth prime.
                        primesieve 100 -n: finds the 100th prime,
                        primesieve 2 100 -n: finds the 2nd prime > 100.
        --no-status     Turn off the progressing status.
    -p, --print[=NUM]   Print primes or prime k-tuplets, NUM <= 6.
                        Print primes: -p or --print,
                        print twin primes: -p2 or --print=2,
                        print prime triplets: -p3 or --print=3, ...
    -q, --quiet         Quiet mode, prints less output.
    -s, --size=SIZE     Set the sieve size in KiB, SIZE <= 8192.
                        By default primesieve uses a sieve size that
                        matches your CPU's L1 cache size or half of
                        your CPU's L2 cache size (per core).
        --test          Run various sieving tests.
    -t, --threads=NUM   Set the number of threads, NUM <= CPU cores.
                        Default setting: use all available CPU cores.
        --time          Print the time elapsed in seconds.
    -v, --version       Print version and license information.
