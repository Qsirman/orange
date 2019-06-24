import cv2
import matplotlib.pyplot as plt
import numpy as np
import random
import math

fileName = '4.jpg'
alpha = 0.99
e= 10**(0)
tt = 0
ttt = 0
step = 5

def getK(A,B):
    K = (A[1]-B[1])/(A[0]-B[0])
    return K

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

def getM(points,A,B,C):
    w = 20
    if (getK(A,B)==getK(A,C)) or (getK(A,B)==getK(B,C)) or (getK(A,C)==getK(B,C)):
        return []
    c=CircleThru3Dots(A,B,C)
    if len(c) == 0:
        return []
    CC=c[0]
    r=c[1]
    print('getM len of points =',len(points))
    temp = np.sqrt(np.power(points[:,0,0]-CC[0],2)+np.power(points[:,0,1]-CC[1],2))
    #print('temp',temp)
    print('r',r)
    result1 = np.where(temp > max(r-w/2,0))
    result1_ = temp[result1]
    result2 = np.where(temp < r+w/2)
    result2_ = temp[result2]
    rr = np.intersect1d(result1_,result2_)
    M = len(rr)/len(points)
    print('M=',M)
    return [M,CC,A,B,C,r]

def getP(df,T):
    out = 1
    if df < 0:
        out = 1
    else:
        out = math.exp(-df/T)
    return out

original_RGB = cv2.imread(fileName,1)
original_RGB = cv2.cvtColor(original_RGB,cv2.COLOR_BGR2RGB)

width = original_RGB.shape[1]
height = original_RGB.shape[0]

fig = plt.figure()
plt.subplot(231),plt.imshow(original_RGB),plt.title('original')
plt.xticks([]),plt.yticks([])

original_YUV = cv2.cvtColor(original_RGB, cv2.COLOR_BGR2YCrCb)

histeq_V = original_YUV[:,:,2]*1.8

plt.subplot(232),plt.imshow(histeq_V),plt.title('histeq_V')

#change img(2D) to 1D
histeq_V_ = histeq_V.reshape((histeq_V.shape[0]*histeq_V.shape[1],1))
histeq_V_ = np.float32(histeq_V_)

#define criteria = (type,max_iter,epsilon)
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER,10,1.0)

#set flags: hou to choose the initial center
#---cv2.KMEANS_PP_CENTERS ; cv2.KMEANS_RANDOM_CENTERS
flags = cv2.KMEANS_RANDOM_CENTERS
# apply kmenas
compactness,histeq_V_,centers = cv2.kmeans(histeq_V_,2,None,criteria,10,flags)

histeq_V = histeq_V_.reshape((histeq_V.shape[0],histeq_V.shape[1]))

histeq_V = np.uint8(histeq_V)

#histeq_V = cv2.cvtColor(histeq_V, cv2.COLOR_BGR2GRAY)
ret2,histeq_v = cv2.threshold(histeq_V,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)

plt.subplot(233),plt.imshow(histeq_v),plt.title('sagementation')
plt.xticks([]),plt.yticks([])

kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
#open_V = cv2.morphologyEx(histeq_v, cv2.MORPH_CLOSE, kernel)
open_V = cv2.dilate(histeq_v, kernel)
# kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(18,18))
# open_V = cv2.erode(open_V, kernel)
plt.subplot(234),plt.imshow(open_V),plt.title('open operation')
plt.xticks([]),plt.yticks([])

# kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (1, 2))  # 十字形结构
# edge_V = cv2.dilate(edge_V, kernel)  # 膨胀

edge_V = cv2.GaussianBlur(open_V,(9,9),0)
edge_V = cv2.Canny(edge_V, 50, 150)

kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
edge_V = cv2.dilate(edge_V, kernel)

contours, hierarchy=cv2.findContours(edge_V,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_NONE)  

# edge_V = label(edge_V,4)
# dst=color.label2rgb(edge_V)
# plt.subplot(235),plt.imshow(edge_V),plt.title('open operation')
# plt.xticks([]),plt.yticks([])

#plt.show()

for k in range(len(contours)):
    points = contours[k]
    if len(points) < 50:
        cv2.fillConvexPoly(edge_V, points, 0)
        continue
#     for i in range(len(points) - 2*step)
#         temp1 = points(i+step)
    for i in range(len(points) - 2*step):
        temp1 = points[i+step,0,:]-points[i,0,:]
        temp2 = points[i+2*step,0,:]-points[i+step,0,:]
        if temp2[0]*temp1[0] == 0:
            cv2.fillConvexPoly(edge_V, points[i:i+2*step], 0)
            continue
        kk = abs(temp2[1]/temp2[0]-temp1[1]/temp1[0])
        # print(kk)
        if kk > ttt:
            #print('kk = ',kk)
            cv2.fillConvexPoly(edge_V, points[i:i+4*step], 0)

plt.subplot(235),plt.imshow(edge_V),plt.title('edge detection')
plt.xticks([]),plt.yticks([])

edge_V_ = edge_V

plt.subplot(236),plt.imshow(original_RGB),plt.title('result')
plt.xticks([]),plt.yticks([])


edge_V = edge_V_

# kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15))  # 十字形结构
# edge_V = cv2.dilate(edge_V, kernel)  # 膨胀

maxIterator = 5000
contours, hierarchy=cv2.findContours(edge_V,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_NONE)
# for c in contours:
#     plt.plot(c[:,0,0],c[:,0,1])
finalR=[]
for k in range(len(contours)):
    points = contours[k]
    
    x_min = min(points[:,0,0])
    x_max = max(points[:,0,0])
    y_min = min(points[:,0,1])
    y_max = max(points[:,0,1])
    
    rr = max(x_max - x_min,y_max - y_min)

    temp = np.where(points[:,0,0] == x_min)
    A = [x_min,max(points[temp[0],0,1])]
        
    temp = np.where(points[:,0,0] == x_max)
    B = [x_max,min(points[temp[0],0,1])]
    
    temp = np.where(points[:,0,1] == y_min)
    C = [max(points[temp[0],0,0]),y_min]
    
    temp = np.where(points[:,0,1] == y_max)
    D = [min(points[temp[0],0,0]),y_max]
    
    # plt.plot(A[0],A[1],'ro')
    # plt.plot(B[0],B[1],'go')
    # plt.plot(C[0],C[1],'bo')
    # plt.plot(D[0],D[1],'ko')

    R1 = getM(points,A,B,C)
    R2 = getM(points,A,B,D)
    R3 = getM(points,B,C,D)
#     print('R1',R1)
#     print('R2',R2)
#     print('R3',R3)
    if len(R1)*len(R2)*len(R3)==0:
        continue
    
    R_ = [R1,R2,R3]
    
    maxM = max([R1[0],R2[0],R3[0]])
    print('maxM=',maxM)
    
    indexM = np.where(np.array([R1[0],R2[0],R3[0]]) == maxM)
    
    R = R_[np.min(indexM)]
    
    d = 1
    
    count = 0
    T = 1
    
    A = R[2]
    B = R[3]
    C = R[4]
    # plt.plot(A[0],A[1],'ro')
    # plt.plot(B[0],B[1],'go')
    # plt.plot(C[0],C[1],'bo')
    if maxM > 0.85:
        if R[-1] > 80:
            finalR.append(R)
        continue

    while True:
        print('-'*20)
        count = count + 1
        plus = random.randint(1,3)
        #d = random.randint(-5,5)
        #d=1
        if plus == 1:
            B[0] = B[0] + d
            C[1] = C[1] + d
        elif plus == 2:
            A[0] = A[0] + d
            C[1] = C[1] + d
        elif plus == 3:
            A[0] = A[0] + d
            B[1] = B[1] + d

        R_ = getM(points,A,B,C)

        if len(R_) == 0:
            continue
        CC = R_[1]
        r = R_[-1]
        
        m = R_[0]
        
        df = maxM-m
        P = getP(df,T)
        T = T*alpha
        d = d+1
        print('df=',df)
        print('T=',T)
        print('P=',P)
        if P < e:
            ff = 1

            CC1_ = R_[1]
            if (CC1_[0] +r >= width or CC1_[0] - r < 0) and ( CC1_[1] + r >= height or CC1_[1] - r < 0):
                ff = 0
            if ff==1 and len(finalR) > 0:
                for i in range(len(finalR)):
                    R__ = finalR[i]
                    
                    CC2_ = R__[1]

                    CC_ = CC1_ - CC2_
                    dis = np.sqrt(sum(np.power(CC_,2)))
                    print('dis',dis)
                    if dis <= R_[-1] + R__[-1] + tt:
                        # if R_[0] > R__[0]:
                        finalR[i] = R_
                        ff = 0
            if ff == 1:
                if R_[-1] > 80:
                    finalR.append(R_)
            break
        if count > maxIterator:
            break
print('length of final Rs=',len(finalR))
if len(finalR) > 0:
    print('start marking')
    ax = fig.add_subplot(236)
    for R in finalR:
        print('R',R)
        CC = R[1]
        r = R[-1]
        print('CC',CC)
        print('r',r)
        print('A',R[2])
        print('B',R[3])
        print('C',R[4])
        
        circ= plt.Circle((CC[0],CC[1]),r,color='r',fill = False)
        
        ax.add_patch(circ)
        # plt.plot(A[0],A[1],'ro')
        # plt.plot(B[0],B[1],'go')
        # plt.plot(C[0],C[1],'bo')
plt.show()