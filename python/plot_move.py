import sys
import numpy as np
import matplotlib.pyplot as plt

if len(sys.argv) < 2:
    print('Usage:', sys.argv[0], 'filename [outfilename]')
    raise

fn = sys.argv[1]
ofn = None if len(sys.argv) < 3 else sys.argv[2]

print(fn, ofn)

d = np.loadtxt(fn).T

d[0] = d[0] - d[0][0]

plt.figure()
plt.plot(d[0], d[3], '#1 FE')
plt.plot(d[0], d[6], '#1 FE')
if ofn is not None:
    plt.savefig(ofn)
plt.show()

