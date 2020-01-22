

function GenerativeKernelPCA_GUI(data,labels,visualise_arguments,visualise_x_hat)
% Tool to perform latent space exploration using Generative Kernel PCA with
% a graphical user interface.

% The setup of the function is as follows:
% 1. Input variables and parameters are initialized.
% 2. The generative kernel PCA model is constructed
% 3. The GUI is initialized


%%%%%%%%%%%%%%%%%%% Input Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data: Nxd matrix with N datapoints and d dimensions
% labels: labels to be used in visualising the feature space (optional)
% visualise_arguments: arguments needed for visualising the input data
% visualise_x_hat: method to visualise the input data. Can either be faces,
% graphs or images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% N is number of datapoints and d is the dimensionality of the data
[N,d] = size(data);

if nargin < 4
    labels = ones(N,1);
end

% Put each class in cell
lab = sort(unique(labels));
nmb = length(lab);
train_data_classes = cell(1,nmb);
train_labels_classes = cell(1,nmb);

for i = 1:nmb
    selec = data(labels == lab(i),:);
    idx_train = 1:size(selec,1);
    train_data_classes{i} =  selec(idx_train,:);
  
    selec = labels(labels == lab(i),:);
    idx_train = 1:size(selec,1);
    train_labels_classes{i} =  selec(idx_train,:);
end


%%%%%%%%%%%%%%%% Initialize Variables and Parameters %%%%%%%%%%%%%%%%
% Variables and Parameters are initialized here so their values are shared among the
% subfunctions 

% n_comp: (default) number of principal components used in the
% reconstruction
n_comp = 10;

% H: Nxp matrix with hidden units
H= ones(n_comp);

% h_star: newly generated component of hidden unit
h_star = 0;

% Sim_kpca: estimate of kernel matrix for newly generated points
Sim_kpca = ones(N);

% x_hat: estimate of newly generated datapoint in the input space
x_hat = ones(d,1); 

% K_c: centered kernel matrix
K_c = ones(N);

% Nscale: number of nearby points needed for the estimate of x_hat
Nscale = 20;

% Default choice for the kernel
kernel_type = 'RBF_kernel';


% Default classes to visualise
class1 = 1;
class2 = 2;

% Choose classes to train data on
if nmb == 1
    train_data = [train_data_classes{class1}];
    train_labels = [train_labels_classes{class1}];
else
    train_data = [train_data_classes{class1}; train_data_classes{class2}];
    train_labels = [train_labels_classes{class1};train_labels_classes{class2}];    
end

% sigma2: kernel bandwidth for an RBF kernel using rule of thumb
% Rule of thumb for sigma^2
sigma2 = round(d*mean(var(train_data)));


% Default principal components used as axes for the latent feature space
prin_comp_a =1;
prin_comp_b =2;

%avg = mean(train_data,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Construction of the generative kernel PCA model %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Train the model
trainGenKPCA();

function trainGenKPCA()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Train the generative model on the two chosen classses %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Perform Kernel PCA using the LS-SVM toolbox
    [Delta1,H] = kpca(train_data,kernel_type,sigma2,[],'eigs',n_comp,'o');
    H= real(H);

    % Choose first (default) hidden unit as base from which to generate new hidden units 
    h_star = H(1,:);

    % Kernel Matrices
    K = kernel_matrix(train_data,kernel_type,sigma2);
    K_c = center(K);
    
    % Regenerate Kernel Matrix
    Sim_kpca = (K_c*H*h_star')';
end

% Find estimate for datapoint
findEstimate();

function findEstimate()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find estimate for datapoint in the input space %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Find Nscale most similar datapoints using kernel as similarty measure
    [~,I] = maxk(Sim_kpca,Nscale,2);
    Scaler = zeros(size(Sim_kpca));
    linearInd = sub2ind(size(Sim_kpca),(1:size(I,1))'.*ones(size(I)),I);
    Scaler(linearInd(:)) = 1;
    Sim_kpca = Sim_kpca.*Scaler;
    weights = Sim_kpca./sum(abs(Sim_kpca),2);
    x_hat = weights*train_data;
    


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Create GUI for exploring the latent feature space %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Visualize the effect of varying 5 principal components
N_comp = 5;

% Build gui
f = figure('Name','Latent feature space exploration using Generative KPCA');
%set ( gcf, 'Color', [1 1 1] );
generated_data_axes = axes('Parent',f,'Position',[.05 .5 .45 .45]);
feature_space =  axes('Parent',f,'Position',[.55 .5 .3 .4]);

visualise_x_hat(x_hat,generated_data_axes,visualise_arguments)


% Choose range for sliders for principal components
minH(:) = round(min(H(:,1:N_comp)),5);
maxH(:) = round(max(H(:,1:N_comp)),5);


% Visualise the feature space
visualiseFeatureSpace();

function visualiseFeatureSpace()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Visualise the latent feature space along two principal components %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    FontSizeAxis = 20;
    FontSizeLabel = 18;
    FontSize = 12;

    % Show current point in latent feature space
    scatter(h_star(1,prin_comp_a),h_star(1,prin_comp_b),'r*','LineWidth',3,'Parent',feature_space)
    hold on
    
    % Show latent feature space
    if nmb == 1
        scatter(H(train_labels==lab(class1),prin_comp_a),H(train_labels==lab(class1),prin_comp_b),'Parent',feature_space);
        lgd = legend(feature_space,{'Current position','Hidden units'});
    else
        scatter(H(train_labels==lab(class1),prin_comp_a),H(train_labels==lab(class1),prin_comp_b),'*','Parent',feature_space);
        scatter(H(train_labels==lab(class2),prin_comp_a),H(train_labels==lab(class2),prin_comp_b),'d','Parent',feature_space);
        lgd = legend(feature_space,{'Current position',num2str(lab(class1)),num2str(lab(class2))});
    end   
    set(lgd,'Interpreter','latex');
    lgd.FontSize = FontSizeLabel;
    set(gca,'FontSize',FontSize)
    title(feature_space,'Latent Feature space');
    xlabel(feature_space,['Principal Component ',num2str(prin_comp_a)],'Interpreter','latex','FontSize',FontSizeAxis)
    ylabel(feature_space,['Principal Component ',num2str(prin_comp_b)],'Interpreter','latex','FontSize',FontSizeAxis)
    
    hold off % For to update the position when traversing the feature space
end


% Create slider panel
p = uipanel('Parent',f,'Title','Settings','Position',[.25 .05 .5 .35]);

% Sliders for moving along the principal components

uicontrol('Parent',p,'Style','slider','Max',maxH(1),'Min',minH(1),'Value',H(1,1),...
'Sliderstep',[0.01 0.1],'Position',[350 215 150 20],'Callback',@(src,eventdata)prin_slider_Callback(src,eventdata,1));
uicontrol('Parent',p,'Style','slider','Max',maxH(2),'Min',minH(2),'Value',H(1,2),...
'Sliderstep',[0.01 0.1],'Position',[350 165 150 20],'Callback',@(src,eventdata)prin_slider_Callback(src,eventdata,2));
uicontrol('Parent',p,'Style','slider','Max',maxH(3),'Min',minH(3),'Value',H(1,3),...
'Sliderstep',[0.01 0.1],'Position',[350 115 150 20],'Callback',@(src,eventdata)prin_slider_Callback(src,eventdata,3));
uicontrol('Parent',p,'Style','slider','Max',maxH(4),'Min',minH(4),'Value',H(1,4),...
'Sliderstep',[0.01 0.1],'Position',[350 65 150 20],'Callback',@(src,eventdata)prin_slider_Callback(src,eventdata,4));
uicontrol('Parent',p,'Style','slider','Max',maxH(5),'Min',minH(5),'Value',H(1,5),...
'Sliderstep',[0.01 0.1],'Position',[350 15 150 20],'Callback',@(src,eventdata)prin_slider_Callback(src,eventdata,5));

slider1title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[275 235 300 20],  ...
                'String','Principal component 1 = ');
slider2title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[275 185 300 20],  ...
                'String','Principal component 2 = ');
slider3title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[275 135 300 20],  ...
                'String','Principal component 3 = ');
slider4title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[275 85 300 20],  ...
                'String','Principal component 4 = ');
slider5title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[275 35 300 20],  ...
                'String','Principal component 5 = ');



% Slider for the closest point for average of similarity
uicontrol('Parent',p,'Style','slider','Max',101,'Min',1,'Value',15,...
'Sliderstep',[0.01 0.1],'Position',[80 165 150 20],'Callback',@(src,eventdata)similarity_slider_Callback(src,eventdata));
similarity_title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[10 185 300 20],  ...
                'String','15 closest similar points');
      

% Pop-up menu for kernel choice
% We only considered 2 kernel choices, but can easily be extended to more kernels
uicontrol(p,'Style','popupmenu','String',{'lin_kernel','RBF_kernel'},...
                'Value',2,'Position',[80 115 130 20],'Callback',@(src,eventdata)kernel_pm_Callback(src,eventdata));
kernel_title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[10 135 300 20],  ...
                'String','Choose kernel');
            
% Slider to change the kernel bandwidth sigma^2
uicontrol('Parent',p,'Style','slider','Max',2001,'Min',1,'Value',sigma2,...
'Sliderstep',[0.001 0.01],'Position',[80 215 150 20],'Callback',@(src,eventdata)sigma_slider_Callback(src,eventdata));
slider_sigma_title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[10 235 300 20],  ...
                'String',['Sigma = ', num2str(sigma2)]);



% Pop-up menu's for class choice when multiple classes are available
if nmb > 1
    uicontrol(p,'Style','popupmenu','String',{lab},...
                    'Value',1,'Position',[80 65 130 20],'Callback',@(src,eventdata)class_pm_1_Callback(src,eventdata));
    uicontrol(p,'Style','popupmenu','String',{lab},...
                    'Value',2,'Position',[80 15 130 20],'Callback',@(src,eventdata)class_pm_2_Callback(src,eventdata));            
    class_1_pm_title = uicontrol('Style','text',             ...
                    'Parent', p,              ...
                    'Position',[10 85 300 20],  ...
                    'String','Choose starting class');            
    class_2_pm_title = uicontrol('Style','text',             ...
                    'Parent', p,              ...
                    'Position',[10 35 300 20],  ...
                    'String','Choose class for comparison');
end            

% Pop-up menu's for the axes of the feature space to visualise
uicontrol(p,'Style','popupmenu','String',{'Prin Comp 1','Prin Comp 2','Prin Comp 3','Prin Comp 4','Prin Comp 5'},...
                'Value',1,'Position',[620 165 130 20],'Callback',@(src,eventdata)axis_pm_Callback(src,eventdata,1));
            
uicontrol(p,'Style','popupmenu','String',{'Prin Comp 1','Prin Comp 2','Prin Comp 3','Prin Comp 4','Prin Comp 5'},...
                'Value',2,'Position',[620 125 130 20],'Callback',@(src,eventdata)axis_pm_Callback(src,eventdata,2));
            
feature_space_title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[550 185 300 20],  ...
                'String','Choose features to visualize');
            
% Slider to change the number of principal components used
% Minimum is 5 components to be compatible with the gui. This can be
% changed
uicontrol('Parent',p,'Style','slider','Max',106,'Min',5,'Value',n_comp,...
'Sliderstep',[0.01 0.1],'Position',[620 215 130 20],'Callback',@(src,eventdata)n_comp_slider_Callback(src,eventdata));

n_comp_title = uicontrol('Style','text',             ...
                'Parent', p,              ...
                'Position',[550 235 300 20],  ...
                'String',['Number of principal components used: ' num2str(n_comp)]);
                        

            

            
function prin_slider_Callback(hObject,eventdata,prin_comp)
    % Slider to vary the hidden units along the principal components
    
    gen_comp = get(hObject,'Value');
    h_star(1,prin_comp) = gen_comp; %set first h_star value

    if prin_comp == 1
        set(slider1title,'String',['Principal component 1 = ' num2str(gen_comp)]);
    elseif prin_comp == 2
        set(slider2title,'String',['Principal component 2 = ' num2str(gen_comp)]);
    elseif prin_comp == 3
        set(slider3title,'String',['Principal component 3 = ' num2str(gen_comp)]);
    elseif prin_comp == 4
        set(slider4title,'String',['Principal component 4 = ' num2str(gen_comp)]);
    elseif prin_comp == 5
        set(slider5title,'String',['Principal component 5 = ' num2str(gen_comp)]);
    end

    % Re-estimate new x_hat
    Sim_kpca = (K_c*H*h_star')';
    findEstimate();
    visualise_x_hat(x_hat,generated_data_axes,visualise_arguments);
    visualiseFeatureSpace();

end

function kernel_pm_Callback(src,eventdata)
    % Choose kernel function
    choice = get(src,'Value');
    if choice == 1
        kernel_type = 'lin_kernel';
        sigma2 = [];
    elseif choice == 2
        kernel_type = 'poly_kernel';
    else
        kernel_type = 'RBF_kernel';
        sigma2 = 50;
    end
    trainGenKPCA();
    findEstimate();
    visualise_x_hat(x_hat,generated_data_axes,visualise_arguments);
    visualiseFeatureSpace();
end

function axis_pm_Callback(src,eventdata,axis)
    % Choose which principal component to be used as axis when plotting
    % feature space
    if axis == 1
        prin_comp_a = get(src,'Value');
    elseif axis == 2
        prin_comp_b = get(src,'Value');
    end
    visualiseFeatureSpace();
end

function similarity_slider_Callback(src,eventdata)
    % Callback function to get the number of nearby points for the average
    Nscale = round(get(src,'Value'));
    src.Value = Nscale;
    set(similarity_title,'String',[num2str(Nscale) ' closest similar points']);
    findEstimate();
    visualise_x_hat(x_hat,generated_data_axes,visualise_arguments);
end

function class_pm_1_Callback(src,eventdata)
    % Callback function to choose which class of data is used as starting
    % point
    class1 = get(src,'Value');

    train_data = [train_data_classes{class1}; train_data_classes{class2}];
    train_labels = [train_labels_classes{class1};train_labels_classes{class2}];
    trainGenKPCA();
    findEstimate();
    visualise_x_hat(x_hat,generated_data_axes,visualise_arguments);   
    visualiseFeatureSpace();
    

end

function class_pm_2_Callback(src,eventdata)
    % Callback function to choose which class of data is used for
    % comparison
    class2 = get(src,'Value');
    train_data = [train_data_classes{class1}; train_data_classes{class2}];
    train_labels = [train_labels_classes{class1};train_labels_classes{class2}];
    
    trainGenKPCA();
    findEstimate();
    
    visualiseFeatureSpace();
    

end

function sigma_slider_Callback(src,eventdata)
    if not(strcmp(kernel_type,'lin_kernel')) 
        sigma2 = get(src,'Value');
        set(slider_sigma_title,'String',['Sigma = ' num2str(sigma2)]);
    end
    trainGenKPCA();
    findEstimate();
    visualise_x_hat(x_hat,generated_data_axes,visualise_arguments);
    visualiseFeatureSpace();
    
    
end


function n_comp_slider_Callback(src,eventdata)
    n_comp = round(get(src,'Value'));
    src.Value = n_comp;
    set(n_comp_title,'String',['Number of principal components used: ' num2str(n_comp)]);
    trainGenKPCA();
    findEstimate();
    visualise_x_hat(x_hat,generated_data_axes,visualise_arguments);
    visualiseFeatureSpace();
end
end            
