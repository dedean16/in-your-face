% relaxgaps test
close all; clear; clc

f = figure;

% Create some sort of continuous matrix
n = 30;
[X,Y] = meshgrid(1:n,1:n);
M = sin(sqrt(0.2*X.^2 + 0.3*Y.^2)) + 1.5;

subplot(2,2,1); imagesc(M)
title('Matrix with values')

% Create matrix containing 'gaps' (0's in matrix of 1's)
gaps = 0.5 + 0.5 * sign(cos(0.2*X+0.002.*X.^2) .* sin(0.05*Y+0.01.*Y.^2) + 0.5);
subplot(2,2,2); imagesc(gaps);
title('Create gaps')

% Matrix with gaps
Mg = M.*gaps;
subplot(2,2,3); imagesc(Mg)
title('Matrix with gaps')

% Relax, they're only gaps
gv      = 0;                    % Gap value
a       = 1.5;                  % overshoot parameter
imax    = 400;                  % Max iterations
dmax    = 0.001;                % Target convergence value
vis     = false;                % Visualisation
[Mf,its] = relaxgaps(Mg,gv,a,imax,dmax,vis);

% Plot
figure(f)
subplot(2,2,4); imagesc(Mf)
title(sprintf('Filled matrix, iterations: %i',its))


% === Test relaxation for different a values ===
% Set test range for a
na   = 50;                      % Number of a values to test
amin = 0.1;                     % Min a value
amax = 1.9;                     % Max a value
vis = false;                    % Visualisation

as = linspace(amin,amax,na);    % Create a test value array
itss = [];

% Test a values
for a = as
    [Mf,its] = relaxgaps(Mg,gv,a,imax,dmax,vis);
    itss = [itss its];
end

% Plot
figure;
plot(as,itss,'.-')
xlabel('a values')
ylabel('iterations')
title('''a'' value vs iterations needed')
