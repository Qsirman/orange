import matplotlib.pyplot as plt
import numpy as np
def CircleThru3Dots(A,B,C):
    x1 = A[0]
    x2 = B[0]
    x3 = C[0]
    
    y1 = A[1]
    y2 = B[1]
    y3 = C[1]
    a = x1 - x2
    b = y1 - y2
    c = x1 - x3
    d = y1 - y3
    a1 = ((x1 * x1 - x2 * x2) + (y1 * y1 - y2 * y2)) / 2.0
    a2 = ((x1 * x1 - x3 * x3) + (y1 * y1 - y3 * y3)) / 2.0
    theta = b * c - a * d
    if abs(theta) < 1e-7:
        #print('too small')
        return []
    x0 = (b * a2 - d * a1) / theta
    y0 = (c * a1 - a * a2) / theta
    CC = np.array([x0,y0])
    r = np.sqrt(pow((x1 - x0), 2)+pow((y1 - y0), 2))
    return [CC,r]
P = CircleThru3Dots([1,1],[1,0],[0,-1])
print(P)
if len(P) > 0:
    fig = plt.figure()
    ax = fig.add_subplot(111)
    
    circ=plt.Circle((0,0),P[-1],color='r')
    ax.add_patch(circ)
    plt.show()