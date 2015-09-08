function subgrad = calc_subgrad_scp_square_loss(features_list,C,list_weights,lambda,beta)
% features_list is cell of size [1,B]. features_list{i} is [L,d]
% C is [B,L]
% list_weights is [1,L]
% beta is [d,1]

[B,L] = size(C);
d = length(beta);
subgrad = zeros(d,1);

% prediction error terms
for k = 1:B
	features = features_list{k}; % [L,d]
	% center features
	features = bsxfun(@minus,features,mean(features,1));
	scores = features*beta; % [L,1]
	level_costs = C(k,:)'; % [L,1]
	vec1 = 2*list_weights(k)*level_costs.*(1+scores); % [L,1]
	subgrad = subgrad+features'*vec1; % [d,1]
end

% regularization term
subgrad = subgrad+lambda*beta;

end