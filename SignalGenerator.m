classdef SignalGenerator
    % A class to generate synthetic spatio-temporal signals.

    properties
        nx = 100; % Number of spatial points
        nt = 500; % Number of temporal points
        x_min = -5; % Minimum spatial coordinate
        x_max = 5; % Maximum spatial coordinate
        t_min = 0; % Minimum temporal coordinate
        t_max = 50; % Maximum temporal coordinate
        x % Spatial coordinate vector
        t % Temporal coordinate vector
        X % Spatial coordinate matrix
        T % Temporal coordinate matrix
        signal % Synthesized spatio-temporal signal
        components % List of signal components
    end

    methods
        function obj = SignalGenerator(nx, nt, x_min, x_max, t_min, t_max)
            % Constructor to initialize spatio-temporal grid
            if nargin > 0
                obj.nx = nx;
                obj.nt = nt;
                obj.x_min = x_min;
                obj.x_max = x_max;
                obj.t_min = t_min;
                obj.t_max = t_max;
            end
            obj.x = linspace(obj.x_min, obj.x_max, obj.nx);
            obj.t = linspace(obj.t_min, obj.t_max, obj.nt);
            [obj.X, obj.T] = meshgrid(obj.x, obj.t);
            obj.signal = zeros(obj.nt, obj.nx);
            obj.components = {};
        end

        function obj = add_sinusoid1(obj, a, k, omega, gamma)
            % Generate a sinusoidal signal of the form:
            % a*sin(k*x - omega*t)*exp(gamma*t)

            if nargin < 2, a = 1; end
            if nargin < 3, k = 0.1; end
            if nargin < 4, omega = 1; end
            if nargin < 5, gamma = 0; end

            signal = sin(k*obj.X - omega*obj.T) .* exp(gamma*obj.T);
            spatial_norm = vecnorm(signal, 2, 2);  % L2 norm along spatial axis
            signal = signal ./ spatial_norm; % Normalize along the spatial dimension
            signal = a * signal;
            comp.type = 'sinusoid1';
            comp.a = a;
            comp.k = k;
            comp.omega = omega;
            comp.gamma = gamma;
            comp.signal = signal;
            obj.components{end+1} = comp;
            obj.signal = obj.signal + signal;
        end

        function obj = add_sinusoid2(obj, a, k, omega, c)
            % Generate a sinusoidal signal of the form:
            % a*(exp(-k*(x+c)^2)*cos(omega*t))

            if nargin < 2, a = 1; end
            if nargin < 3, k = 0.2; end
            if nargin < 4, omega = 1; end
            if nargin < 5, c = 0; end

            spatial_signal = exp(-k*(obj.X + c).^2);
            area = trapz(obj.x, spatial_signal(1, :)); % Area under curve
            signal = a * (spatial_signal / area) .* cos(omega * obj.T);
            comp.type = 'sinusoid2';
            comp.a = a;
            comp.k = k;
            comp.omega = omega;
            comp.c = c;
            comp.signal = signal;
            obj.components{end+1} = comp;
            obj.signal = obj.signal + signal;
        end

        function obj = add_trend(obj, mu, trend)
            % Generate a linear trend in time of the form:
            % mu + trend*t

            if nargin < 2, mu = 0.2; end
            if nargin < 3, trend = 0.01; end

            signal = obj.T * trend + mu;
            comp.type = 'trend';
            comp.mu = mu;
            comp.trend = trend;
            comp.signal = signal;
            obj.components{end+1} = comp;
            obj.signal = obj.signal + signal;
        end

        function obj = add_noise(obj, noise_std, random_seed)
            % Add Gaussian noise to the signal

            if nargin < 2, noise_std = 0.1; end
            if nargin >= 3, rng(random_seed); end % Set random seed for reproducibility

            noise = noise_std * randn(size(obj.signal));
            obj.signal = obj.signal + noise;
        end
    end
end
