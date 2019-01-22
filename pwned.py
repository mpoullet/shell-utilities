#!/usr/bin/python3

"""http://disq.us/p/1yy2tst"""

import hashlib
import requests


def test_pw(byte_string):
    hasher = hashlib.sha1()
    hasher.update(byte_string)
    digest = hasher.hexdigest().upper()
    print(f'Hash: {digest[:5]}, {digest[5:]}')
    print(f'GET https://api.pwnedpasswords.com/range/{digest[:5]}')
    pw_list = requests.get(
        f'https://api.pwnedpasswords.com/range/{digest[:5]}')
    for line in pw_list.text.split('\n'):
        info = line.split(':')
        if info[0] == digest[5:]:
            print(f'Pwned! Seen {int(info[1])} times.')
            break
    else:
        print('Not found')


test_pw(b'12345')
