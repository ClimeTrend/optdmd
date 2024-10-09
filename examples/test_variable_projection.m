%% generate synthetic data

% create the signal that we will feed to opt DMD

signal_generator = SignalGenerator;

% first sinusoid

a=2;
k=1.5;
omega=0.5;
gamma=0;

signal_generator = add_sinusoid1( ...
    signal_generator, a, k, omega, gamma ...
    );

figure
contourf(signal_generator.T', ...
    signal_generator.X', ...
    signal_generator.components{1}.signal',...
    LineStyle="none")
title("Sinusoid 1")

% second sinusoid

a=3;
c=1.5;
omega=2.5;
k=0.5;

signal_generator = add_sinusoid2( ...
    signal_generator, a, k, omega, c);

figure
contourf(signal_generator.T', ...
    signal_generator.X', ...
    signal_generator.components{2}.signal',...
    LineStyle="none")
title("Sinusoid 2")

% add noise and plot the final result

signal_generator = add_noise( ...
    signal_generator, 0.1, 42);

figure
contourf(signal_generator.T', ...
    signal_generator.X', ...
    signal_generator.signal', ...
    LineStyle="none")
title("All + Noise")

%% apply time delay before performing opt DMD

function [X_delay, t_delay] = apply_time_delay(X, t)

    X_delay = zeros(2*size(X, 1), size(X, 2)-1);

    for col = 1:size(X_delay, 2)
        X_delay(:, col) = [X(:, col); X(:, col+1)];
    end

    t_delay = t(1:end-1);

end

[X_delay, t_delay] = apply_time_delay( ...
    signal_generator.signal', ...
    signal_generator.t);

%% perform opt DMD using Algorithm 3

r = 4;
imode = 2;
[w, e2, b] = optdmd( ...
    X_delay, ...
    t_delay, ...
    r, ...
    imode);

