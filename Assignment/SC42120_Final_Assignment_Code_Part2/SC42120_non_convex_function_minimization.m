%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Single Variable Non-convex Function Minimization
%%% 
%%% Source code for paper: Global optimality of approximate dynamic programming and its use in non-convex function minimization
%%% Authors: Ali Heydari and S.N. Balakrishnan
%%% Journal: Applied Soft Computing, Vol. 24, 2014, pp. 291?303
%%% 
%%% Copyright 2013 by Ali Heydari (heydari.ali@gmail.com)
%%% Author Webpage: http://webpages.sdsmt.edu/~aheydari/
%%%
%%% Refer to the paper and the notations used therein for understanding this code
%%%
%%% Author of the code: 
%%% Vittorio Giammarino
%%% DSCS, Tu Delft, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear;

%% Initialization

% The function subject to minimization
c = 100;
psi = @(x) c*[2.1333*x^4 + 0.9333*x^3 - 2.1333*x^2 - 0.9333*x + 1]; % A non-convex psi to optimize

dt = 1e-4; %Sampling time of the discrete system
tf =  1; %The simulation will be performed from t=0 to this value
N = tf/dt; %Number of steps during each simulation 

% System dynamics
f = @(x) [0];
g = [1];

Q = @(x) [0*dt*x^2];
R = 1;

n = 1; m = 1; %system order and number of inputs

X_k = (rand(n,1)*2-1); %Initial states selection

% Basis functions
phi = @(x) [1 x x^2 x^3 x^4 x^5 x^6 x^7]';
dphi_dx = @(x) [0 1 2*x 3*x^2 4*x^3 5*x^4 6*x^5 7*x^6]';
sigma = @(x) [1 x x^2 x^3 x^4 x^5 x^6]';

% Initializing memory
FinalW = zeros(length(phi(X_k)),N);
FinalV = zeros(length(sigma(X_k)),N); %Scalar control, for now

%% NN Training

MaxEpochNo = 3; % Unlike Algorithm 1 of the paper, where "beta" was defined for evaluating the convergence of "Step 6", we're setting a fixed number of iterations for that successive approximation
NoOfEquations = 100; % Number of sample "x" selected for training using least squares
StateSelectionWidth = 2; % the states will be selected from interval (-StateSelectionWidth, StateSelectionWidth)

f_bar = @(x) dt*f(x); % Discretized R
g_bar = dt*g; % Discretized g
Q_bar = @(x) dt*Q(x); %Discretized Q
R_bar = dt*R; % Discretized R

tic
W = zeros(length(phi(X_k)),N,MaxEpochNo);
V = zeros(length(sigma(X_k)),N,MaxEpochNo); %Scalar control, for now

% Variables defined for least squares calculation, refer to the Appendix in the paper
RHS_J = zeros(NoOfEquations,1); %Right Half Square J
RHS_U = zeros(NoOfEquations,m); %Right Half Square U
LHS_J = zeros(NoOfEquations,length(phi(X_k))); %Left Half Square J
LHS_U = zeros(NoOfEquations,length(sigma(X_k))); %Left Half Square U

diverged = 0;

% Training process based on Algorithm 1 of the paper
for t = 0:N-1
    k = N - t; %Changing from N to 1
    W(:,k,1) = FinalW(:,k);
    V(:,k,1) = FinalV(:,k);
    if diverged == 0
        if mod(k,50)==0
            fprintf('Current time = %g\n',k);
        end 
        if k == N % Step 2
            for i=1:NoOfEquations
                X_k = (rand(1,1)*2-1) * StateSelectionWidth; %Initial states selection
                J_k_t = psi(X_k);
                RHS_J(i,:) = J_k_t;
                LHS_J(i,:) = phi(X_k)';
                RHS_U(i,:) = zeros(m,1)'; %Just to assign some values
                LHS_U(i,:) = sigma(X_k)';
            end
            if det(LHS_J'*LHS_J)==0
                fprintf('det phi = 0\n');
                break;
            end
            FinalW(:,k) = (LHS_J'*LHS_J)\LHS_J'*RHS_J;
        else % Step 3
            for i=1:NoOfEquations % Step 4
                U_k = 0;
                % Step 5
                X_k = (rand(1,1)*2-1) * StateSelectionWidth; %Initial states selection
                
                % Steps 6 and 7 of Algorithm 1 (conducting a fixed number
                % of iterations instead of using a convergence tolerance
                % beta
                % like in the paper)
                for j = 1:MaxEpochNo-1 
                    X_k_plus_1 = X_k+f_bar(X_k)+g_bar*U_k;
                    U_k = -1/2*(R_bar\g_bar)*dphi_dx(X_k_plus_1)'*FinalW(:,k+1);
                end
                RHS_U(i,:) = U_k';
                LHS_U(i,:) = sigma(X_k)';
                % Generate target for updating W
                X_k_plus_1 = X_k+f_bar(X_k)+g_bar*U_k;
                J_k_plus_1 = FinalW(:,k+1)'*phi(X_k_plus_1);
                J_k_t = Q_bar(X_k)+U_k*R_bar*U_k+J_k_plus_1;
                RHS_J(i,:) = J_k_t;
                LHS_J(i,:) = phi(X_k)';
            end
            if det(LHS_U'*LHS_U)==0
                fprintf('det sigma = 0\n');
                break;
            end
            % Step 8
            FinalV(:,k) = (LHS_U'*LHS_U)\LHS_U'*RHS_U;

            if det(LHS_J'*LHS_J)==0
                fprintf('det phi = 0\n');
                break;
            end
            % Step 9   
            FinalW(:,k) = (LHS_J'*LHS_J)\LHS_J'*RHS_J;
            %FinalW(:,k) = inv(LHS_J'*LHS_J)*LHS_J'*RHS_J;
        end

        if isnan(FinalW(:,k))
            fprintf('Training W is diverging...\n');
            diverged = 1;
            break;
        end
        if isnan(FinalV(:,k))
            fprintf('Training V is diverging...\n');
            diverged = 1;
            break;
        end
    end
end
toc
 

%% Plot Results

x=-StateSelectionWidth:dt:StateSelectionWidth;

% Compute values for function and cost function
function_value = zeros(length(x),1);
cost_function_value = zeros(length(x),1);
for i=1:length(x)
    function_value(i) = psi(x(i));
    cost_function_value(i) = FinalW(:,1)'*phi(x(i));
end
[minvalue1, minidx1] = min(function_value);
[minvalue2, minidx2] = min( cost_function_value);
percentage_error = abs((x(minidx2)-x(minidx1))/x(minidx1))*100;
% Plot
figure('NumberTitle', 'off', 'Name', 'Non-linear function')
    hold on
    plot(x,function_value)
    title('Non-linear function to optimise');
    xlabel('x');
    ylabel('\psi(x)');
    legend('\psi');

figure('NumberTitle', 'off', 'Name', 'Cost function')
    hold on
    plot(x,cost_function_value)
    title('Cost function approximation');
    xlabel('x');
    ylabel('J_0(x)');
    legend('J_0');

