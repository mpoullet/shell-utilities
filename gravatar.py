#!/usr/bin/python3

"""This script helps finding out the Gravatar URL associated with an email address."""

import urllib.parse
import hashlib
import sys


def main(argv):
    """Return the Gravatar URL associated with the passed email address."""
    if len(argv) != 2:
        print("Usage: " + argv[0] + " your.email@domain.com")
        sys.exit(1)

    email = argv[1]
    size = 80

    gravatar_url = "https://www.gravatar.com/avatar/"
    gravatar_url += hashlib.md5(str(email.lower()
                                   ).encode('utf-8')).hexdigest() + "?"
    gravatar_url += urllib.parse.urlencode({'s': str(size)})

    print(gravatar_url)


if __name__ == "__main__":
    main(sys.argv)
    sys.exit(0)
