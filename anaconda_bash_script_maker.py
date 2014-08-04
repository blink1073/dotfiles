''' Python Shell-Script Maker for Windows MSYS

Creates a bash shell script for all the `.bat` files in the Scripts directory.
This allows for compatibility with MSYS bash.
For example, `spyder.bat` would yield a file called `spyder`:

#!/bin/bash
cmd //c "spyder" "$@"

See http://sourceforge.net/p/mingw/bugs/1902/ for an explanation.

Author: Steven Silvester <steven.silvester@ieee.org>
License: MIT
Created: 9 Nov 2013
'''

import glob
import pip
import os

bin_py = pip.locations.bin_py
print 'Creating scripts in {0}...'.format(bin_py)

for fname in glob.glob(bin_py + '/*.bat') + glob.glob(bin_py + '/*.exe'):
    outfile = fname.replace('.bat', '').replace('.exe', '')
    with open(outfile, 'wb') as fid:
        fid.write('#!/bin/bash\n')
        cmd = os.path.basename(outfile)
        fid.write('cmd //c "{0}" "$@"\n'.format(cmd))
print 'Done!'
