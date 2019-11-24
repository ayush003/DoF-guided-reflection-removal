function [gx,gy,gxx,gyy,gxy] = GradMat(w,h)
% function to return the gradient matrix 
D = [1,-1];    
filtSz = 1;
sz = w*h;

indexGx1 = zeros(sz*2,1);
indexGx2 = zeros(sz*2,1);
valueGx = zeros(sz*2,1);
indexGy1 = zeros(sz*2,1);
indexGy2 = zeros(sz*2,1);
valueGy = zeros(sz*2,1);

x=1;
y=1;

for disp = 0 : filtSz
    for i = 1:w-1
        for j = 1:h
            indexGx1(x) = sub2ind([h w],j,i);
            indexGx2(x) = sub2ind([h w],j,i+disp);
            valueGx(x) = D(disp+1);
            x = x+1;
        end
    end
    for j=1:h-1
        for i=1:w
            indexGy1(y) = sub2ind([h w],j,i);
            indexGy2(y) = sub2ind([h w],j+disp,i);
            valueGy(y) = D(disp+1);
            y = y+1;
        end
    end
end
x = x-1; y = y-1;
indexGx1 = indexGx1(1:x);
indexGx2 = indexGx2(1:x);
indexGy1 = indexGy1(1:y);
indexGy2 = indexGy2(1:y);
valueGx = valueGx(1:x);
valueGy = valueGy(1:y);

gx = sparse(indexGx1,indexGx2,valueGx,sz,sz);
gy = sparse(indexGy1,indexGy2,valueGy,sz,sz);
gxx = gx'*gx;
gyy = gy'*gy;
gxy = gx*gy;
nzgxx = sum(gxx~=0,2);
nzgyy = sum(gyy~=0,2);
nzgxy = sum(gxy~=0,2);
fzgxx = nzgxx ~= 3;
fzgyy = nzgyy ~= 3;
fzgxy = nzgxy ~= 4;
gxx(fzgxx,:)=0;
gyy(fzgyy,:)=0;
gxy(fzgxy,:)=0;
end
