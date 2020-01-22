function [omega_centered] = center(omega,Kt)
% Centering

nb_data = size(omega,1);
Meanvec = mean(omega,2);
MM = mean(Meanvec);

if ~exist('Kt','var')
    omega_centered = omega-Meanvec*ones(1,nb_data)-ones(nb_data,1)*Meanvec'+MM;
else
    nt=size(Kt,2);
    MeanvecT=mean(Kt,1);
    omega_centered= Kt-Meanvec*ones(1,nt) - ones(nb_data,1)*MeanvecT+MM;
end

end

