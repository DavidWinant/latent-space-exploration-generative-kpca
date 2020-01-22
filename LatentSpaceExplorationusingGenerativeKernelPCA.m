%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Latent Space Exploration using Generative Kernel PCA %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Analyse Digits MNIST 
rng(2);
% Load MNIST images
data = loadMNISTImages('train-images.idx3-ubyte')';
labels = loadMNISTLabels('train-labels.idx1-ubyte');

% Choose how many datapoints to load
digits_MNIST = data(1:20000,:);
labels_MNIST = labels(1:20000,:);
clear data;
% Determine size of image
image_size = [28,28];

% Launch GUI
GenerativeKernelPCA_GUI(digits_MNIST,labels_MNIST,image_size,@visualise_x_hat_image)
clear digits_MNIST; % Free up memory

%% Analyse Yale Faces
% Load Yale faces

paths = 'C:\Users\dwinant\Documents\Projects\Latent Space Exploration using Generative Kernel PCA\Public Matlab\CroppedYale\CroppedYale\yaleB'; 
index = 1;
for i = 1:28
    path = strcat(paths, num2str(i));
    files = dir(fullfile(path,'\*.pgm'));
    for j=1:length(files)
        clear image;
        filename = files(j).name;
        image = importdata(filename);
        if size(image) ~= [480,640]
            yalefaces(index,:) =  reshape(double(image)/255,[192*168,1]);
            index = index+1;
        end
        
    end

end
% Give Labels
labels = ones(size(yalefaces,1),1);
image_size =[192,168];

% Launch GUI
GenerativeKernelPCA_GUI(yalefaces,labels,image_size,@visualise_x_hat_image)
clear yalefaces;




