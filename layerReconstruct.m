function [IR,IB] = layerReconstruct(I,G, f_inds,b_inds)
%	Layers reconstruction using Iterative Reweighted Least Square (IRLS)
%   [ IR IB ] = layerReconstruct( I, G, edgePrB_matB, edgePrB_matF)
%   I: mixture image
%   G: derivative filter matrix (pre-computed)
%   f_inds,b_inds:  pixels labelled as belonging to reflection/background

num_iterations = 3;

w1=50;
w2=1;

[h,w]=size(I);
imgSize=h*w;

%constraints matrix
gx = G.gx;
gy = G.gy;
gxx = G.gxx;
gyy = G.gyy;


A1 = [gx;gy;gxx;gyy];
A = [A1;A1];
b = [zeros(size(A1,1),1);A1*I(:)];
f1 = [ones(imgSize*2,1)*w1;w2*ones(imgSize*2,1);w2*ones(imgSize,1)];

f2 = f1;
f1([f_inds,f_inds+imgSize])=0;
f1([b_inds,b_inds+imgSize])=100;
f2([f_inds,f_inds+imgSize])=100;
f2([b_inds,b_inds+imgSize])=0;

f1([b_inds+imgSize*2,b_inds+imgSize*3,b_inds+imgSize*4])=4;
f2([f_inds+imgSize*2,f_inds+imgSize*3,f_inds+imgSize*4])=4;

f=[f1;f2];

rinds1=find(sum(A~=0,2)==0);
rinds2=find(f==0);
inds=setdiff([1:size(A,1)],[rinds1;rinds2]);

A=A(inds,:);
b=b(inds,:);
f=f(inds);
A_mat=A;
B_mat=b;

df = spdiags(f,0,length(f),length(f));
A = df*A_mat; b=df*B_mat;
x = (A'*A)\(A'*b);

fprintf('Initial error = %g \n',sum(abs(A*x-b)));

for j=1:num_iterations
      error = abs(A_mat*x-B_mat);
      error = max(error,0.00001);
      error = 1./error;
      E = spdiags(error,0,length(f),length(f));
      x = (A'*E*A)\(A'*E*b);
      fprintf('num_iterations= %d, current error = %g \n', j, sum(abs(A*x-b)));   
end

IR=reshape(x,h,w);
IB=I-IR;


