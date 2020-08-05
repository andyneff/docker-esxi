#!/usr/bin/env python3

# Thank you https://github.com/JonathonReinhart/vmware-utils/blob/master/vtar/vtar.py

import struct
import sys

if len(sys.argv) != 4:
  print('{} usage: {} vtar_file search_filepath extracted_filename'.format(sys.argv[0],sys.argv[0]))

with open(sys.argv[1], 'rb') as fid:
  data=b'DEADBEEF'
  while data and data[0] != 0 and not data.startswith(bytes(sys.argv[2], 'ascii') + b'\x00'):
    data = fid.read(512)
    # Uncomment this line to add a "tell" to vmtar
    # print(data[0:100].decode('ascii').strip('\x00'))

  if not data or data[0] == 0:
    exit(1)

  size = int(data[0x7c:0x88].decode('ascii').strip('\x00'),8)
  offset = struct.unpack('I', data[0x1f0:0x1f4])[0]
  fid.seek(offset)

  with open(sys.argv[3], 'wb') as output:
    output.write(fid.read(size))
