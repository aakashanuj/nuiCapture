import sys
NO_CLASSES = int(sys.argv[1])
f=open('perf_output.txt','r')
data=f.readlines()
count=0
total = 0
m = [[0 for x in xrange(NO_CLASSES + 1)] for x in xrange(NO_CLASSES + 1)] 
for line in data:
    line = line.strip()
    predicted,actual = line.strip().split(' ')
    actual = int(actual)
    predicted = int(predicted)
    print actual,predicted
    if(actual==predicted):
        count = count + 1
    total = total + 1
    m[actual][predicted] = m[actual][predicted] + 1 
for i in range(0,NO_CLASSES + 1):
    list=[]
    for j in range(0,NO_CLASSES + 1):
        list.append(m[i][j])
    print list
    
print "Accuracy",count*1.0/total * 100
countp = 0
countr = 0
p_total=0
r_total=0
for i in range(1,NO_CLASSES + 1):
    p_def = 0
    r_def = 0
    p=0
    r=0
    num = m[i][i]
    den = 0
    for j in range(1,NO_CLASSES + 1):
        den = den + m[j][i]
    if(den!=0):
        #print "Precision",num*1.0/den * 100
        p = num*1.0/den * 100
        p_def = 1
    
    num = m[i][i]
    den = 0
    for j in range(1,NO_CLASSES + 1):
        den = den + m[i][j]
    if(den!=0):
        #print "Recall",num*1.0/den * 100
        r_def = 1
        r = num*1.0/den * 100
        
    if(p_def==1 and r_def==1):
        p_total = p_total + p
        r_total = r_total + r
        countp = countp+1
        countr = countr+1
        
print p_total*1.0/countp
print r_total*1.0/countr