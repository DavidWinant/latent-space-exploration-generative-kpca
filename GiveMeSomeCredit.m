%%%%%%%%% Analyze Give Me Some Credit %%%%%%%%

load('loan_data.mat');
load('DataDictionary.mat');

data = loan_data(1:20000,3:end);
labels = loan_data(1:20000,2);
%%
data = normalize(data);

x_labels = DataDictionary;
% Launch GUI
GenerativeKernelPCA_GUI(data,labels,x_labels,@visualise_x_hat_graph)


