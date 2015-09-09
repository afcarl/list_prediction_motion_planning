function [w, obj, wset] = train_multi_linear_primal_sg_hinge(features,losses,lambda, choice, w0)
%TRAIN_LINEAR_SCORER
% 
% weights = TRAIN_LINEAR_SCORER(features,losses,lambda)
% 
% features - Array size [d,N]
% losses    - Array of size [N,L]
% lambda   - Regularization constant.
% 
% weights  - Vector of size [dL,1]

[N,L] = size(losses);
d = size(features,1);

if nargin < 5
    w0 = zeros(d*L,1);
end

w = w0;
wset = w;
obj = [];
num_iter = 1000;


for i = 1:num_iter
    w_matrix = reshape(w,d,L);
    % center weights
    w_matrix_centered = bsxfun(@minus,w_matrix,mean(w_matrix,2)); % [d,L]
    argument = features'*w_matrix_centered; % [N,L]
    
    
    if(strcmp(choice,'hinge'))
        surrogate_fn =  hinge_fn(argument); %hinged_argument
        gradient_fn = (1+argument) > 0; %flag
    elseif(strcmp(choice,'square'))
        surrogate_fn = (1+argument).^2;
        gradient_fn = 2*(1 + argument);
    else
        error('No surrogate loss defined');
    end
    
    surrogate_argument = losses.*surrogate_fn;
    surrogate_gradient = losses.*gradient_fn;
    
    % build up subgradient
    subgrad_matrix = zeros(d,L);
    for j = 1:L
        subgrad_matrix(:,j) = features*surrogate_gradient(:,j);
    end
    subgrad_matrix = bsxfun(@minus,subgrad_matrix,mean(subgrad_matrix,2));
    % regularization contribution
    subgrad_matrix = subgrad_matrix+lambda*w_matrix; 
    subgrad = reshape(subgrad_matrix,d*L,1);
        
    % calc objective
    current_obj_1 = surrogate_argument;
    current_obj_1 = sum(current_obj_1(:));
    current_obj_2 = 0.5*lambda*sum(w.^2);
    current_obj = current_obj_1+current_obj_2;
    obj(end+1) = current_obj;
    
    % update w
    step = 1e-5;
    w = w-step*subgrad;
    wset = [wset w];
end

w = reshape(w,d,L);

end


function hinged_argument = hinge_fn(argument)
    hinged_argument = 1+argument;
    hinged_argument(hinged_argument < 0) = 0;
end

