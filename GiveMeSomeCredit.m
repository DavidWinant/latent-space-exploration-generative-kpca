%%%%%%%%% Analyze Give Me Some Credit %%%%%%%%

load('loan_data.mat');
load('DataDictionary.mat');

data = loan_data(1:20000,3:end);
labels = loan_data(1:20000,2);
%%
input_data = normalize(data);

x_labels = DataDictionary(2:end);
% Launch GUI
GenerativeKernelPCA_GUI(input_data,labels,x_labels,@visualise_x_hat_graph)

%% Weight of Evidence
clear all;
data = readtable('cs-training.csv');
%%
sc = creditscorecard(data,'IDVar','Var1');
sc = autobinning(sc);
bininfo(sc,'age')


