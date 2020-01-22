function d=chi2distance(a,b)

if size(a,1)~=1
    error('The first argument should be a row vector');
end;


a=a+eps;
b=b+eps;

N=size(b,1);

arep=repmat(a,N,1);

dif=(arep-b).^2./(arep+b);
d=sum(dif,2);

end


    
