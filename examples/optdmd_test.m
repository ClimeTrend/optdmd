% A script to test optimized DMD (which uses variable projection) on a synthetic signal 

%% generate data if requested, otherwise load it

generate_data = false;  % set to true to generate data, false to load it from file
filename_load = "../../data/data.mat";  % file to load data from, if generate_data is false
apply_eig_constraints = false;  % set to true to apply imaginary eigenvalue constraints

if generate_data

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
    title(["Sinusoid 1, Omega=" num2str(round(omega, 3)) ", Amp=" num2str(round(a, 3))])

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
    title(["Sinusoid 2, Omega=" num2str(round(omega, 3)) ", Amp=" num2str(round(a, 3))])

    % third sinusoid

    a=3;
    c=-1.5;
    k=0.5;
    omega=5;

    signal_generator = add_sinusoid2( ...
        signal_generator, a, k, omega, c);

    figure
    contourf(signal_generator.T', ...
        signal_generator.X', ...
        signal_generator.components{3}.signal',...
        LineStyle="none")
    title(["Sinusoid 3, Omega=" num2str(round(omega, 3)) ", Amp=" num2str(round(a, 3))])


    % add noise and plot the final result

    signal_generator = add_noise( ...
        signal_generator, 0.2, 42);

    figure
    contourf(signal_generator.T', ...
        signal_generator.X', ...
        signal_generator.signal', ...
        LineStyle="none")
    title("All + Noise")

else
    disp("Loading data...")
    data = load(filename_load);
    signal = data.signal;
    t = data.t;
    x = data.x;
end

%% apply time delay before performing opt DMD

function [X_delay, t_delay] = apply_time_delay(X, t)

    X_delay = zeros(2*size(X, 1), size(X, 2)-1);

    for col = 1:size(X_delay, 2)
        X_delay(:, col) = [X(:, col); X(:, col+1)];
    end

    t_delay = t(1:end-1);

end

[X_delay, t_delay] = apply_time_delay( ...
    signal', ...
    t);

%% perform opt DMD using Algorithm 3

r = 6;
imode = 2;

if ~apply_eig_constraints
    [w, e2, b] = optdmd( ...
        X_delay, ...
        t_delay, ...
        r, ...
        imode);
else
    % this constraint forces the eigenvalues to be purely imaginary
    lbc = [zeros(r, 1); -Inf*ones(r, 1)];
    ubc = [zeros(r, 1); Inf*ones(r, 1)];
    copts = varpro_lsqlinopts('lbc',lbc,'ubc',ubc);
    [w, e2, b] = optdmd( ...
        X_delay, ...
        t_delay, ...
        r, ...
        imode, ...
        [], ...
        [], ...
        [], ...
        copts);
end

disp("Eigenvalues:")
disp(e2')
disp("Amplitudes:")
disp(b')

%% plot the DMD modes

for i = 1:r/2
    j = i*2 - 1;
    figure()
    plot(x, real(w(1:100, j)))
    title(["Omega=" num2str(round(imag(e2(j)), 3)) ", Amp=" num2str(round(b(j), 3))])
end

