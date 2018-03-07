#!/usr/bin/env python3

# Thank you https://github.com/JonathonReinhart/vmware-utils/blob/master/vtar/vtar.py

import struct
import sys

if len(sys.argv) != 4:
  print('{} usage: {} vtar_file search_filepath extracted_filename'.format(sys.argv[0],sys.argv[0]))

with open(sys.argv[1], 'rb') as fid:
  data=b''
  while not data.startswith(bytes(sys.argv[2], 'ascii') + b'\x00'):
    data = fid.read(512)

  size = int(data[0x7c:0x88].decode('ascii').strip('\x00'),8)
  offset = struct.unpack('I', data[0x1f0:0x1f4])[0]
  fid.seek(offset)

  with open(sys.argv[3], 'wb') as output:
    output.write(fid.read(size))
