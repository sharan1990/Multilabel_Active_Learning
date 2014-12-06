function [Y] = test(X,W,L,phi,opts)

%noise parameters
chi = opts.chi;
small_sigma = opts.small_sigma;
%number of update iterations
maxiter = opts.maxiter;

G = X' * X;
d = size(X,2); %#(num features)
N = size(X,1); %#(num examples)
K = size(W,2); %#(num compressed labels)

%random projection matrix
% phi = rand(K,L);

%initialization
Z(1:N) = struct('mu',zeros(K,1),'sigma',eye(K));
Y(1:N) = struct('mu',zeros(L,1),'sigma',eye(L));
a = ones(N,L) * 1e-6;
b = ones(N,L) * 1e-6;

%update equations
a0 = a;
b0 = b;

for i = 1:N
    Z(i).sigma = ((small_sigma^2 * chi^2) / (small_sigma^2 + chi^2)) * eye(K,K);
end

%test examples
concat_W = (concat_struct_attr(W,'mu'));
for i = 1:N
    
    if mod(i,10) == 0
        %fprintf('Test example: %d\n', i);
    end
    
    x_i = X(i,:);
    Wx = small_sigma^-2 * concat_W * x_i';
    
    for t = 1:maxiter
        
        %update Z(i)
        Z(i).mu = Z(i).sigma * ( Wx + ( chi^(-2) * phi * Y(i).mu)  );
        
        %find expectation of alpha_i
        a_i = a(i,:);
        b_i = b(i,:);
        E_alpha_i = a_i ./ b_i;
        
        %update Y(i)
        Y(i).sigma = pinv(diag(E_alpha_i) + (phi' * phi) / (chi^2));
        Y(i).mu = ( Y(i).sigma * phi' * Z(i).mu ) / (chi^2);
        
        %update a,b
        a = a0 + 0.5;
        
        b_old = b(:);
        b(i,:) = b0(i,:) + 0.5 * ((diag(Y(i).sigma) + (Y(i).mu).^2))';
        
        if mod(t,10) == 0
%             fprintf('Iteration: %d\n', t);
            if norm(b(:) - b_old) < 1e-5
                break;
            end
        end
        
        
        
    end
    
end

end
