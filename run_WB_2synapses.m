function NMDAmodel(modFreq)
% WB model neuron with 2 synaptic current inputs
% WB model is a point neuron so units are in densities (per cm^2 for
% surface area)
% To change to a spherical neuron, multiply densities by neuron surface area
% Parameters are set in function modeleqs below

clear; clf;

t_final=800; % duration of simulation in msec
tspan = [0 t_final];

% initial conditions for model variables
v0=-64;
h0=h_inf(v0);
n0=n_inf(v0);
s10=0;
s20=0;
ICs = [v0; h0; n0; s10; s20];

% Call the solver ode15s to numerically simulate the model
% output: t = time stamp vector. 
% vars = matrix with column 1 = voltage v, 
% column 2 = h Na inactivation gate, 
% column 3 = n K-dr activation gate,
% column 4 = s synaptic current gate
options = odeset('MaxStep',1);
[t,vars] = ode15s(@modeleqs, tspan, ICs, options);

% vectors of model variables at each time step:
v = vars(:,1);
%h = vars(:,2);
%n = vars(:,3);
s1 = vars(:,4);
s2 = vars(:,5);

% determine spike times and interspike intervals
[peaks, indxs]=findpeaks(v,'MINPEAKHEIGHT',-10);
if ~isempty(indxs) 
    spiketimes=t(indxs);
end

% plot output
subplot(3,1,1);
plot(t,v,'-k','Linewidth',2);
set(gca,'Fontsize',16);
xlabel('t [ms]','Fontsize',20); ylabel('v [mV]','Fontsize',20);

subplot(3,1,2)
plot(t,s1,'-b','Linewidth',2)
set(gca,'Fontsize',16);
xlabel('t [ms]','Fontsize',20); ylabel('synapse 1 current gate','Fontsize',16);

subplot(3,1,3)
plot(t,s2,'-r','Linewidth',2)
set(gca,'Fontsize',16);
xlabel('t [ms]','Fontsize',20); ylabel('synapse 2 current gate','Fontsize',16);


function dvarsdt = modeleqs(t,vars)
% WB model point neuron equations
% activation gating of Na current is instantaneous function of voltage

    % model variables
    v = vars(1);
    h = vars(2);
    n = vars(3);
    s1 = vars(4);
    s2 = vars(5);

    c=1; % membrane capacitance in microF/cm^2
    g_k=9;  % max conductance of K-dr current (mS/cm^2)
    g_na=35; % max conductance of Na current (mS/cm^2)
    g_l=0.1; % max conductance of membrane leak current (mS/cm^2)
    v_k=-90; % reversal potential of K-dr current
    v_na=55; % reversal potential of Na current
    v_l=-65; % reversal potential of leak current
    
    i_ext=0;  % external applied current to neuron
    
    % pre-synaptic spikes
    T = 1/(modFreq/1000);

    T=50;       % period in msec of repetitive pre-synaptic spikes
    presyn_spike_width = 1.0; % (msec) if you choose a very slow synaptic rise time
    % constant, you may need to make presyn_spike_width longer to see
    % effects
    if mod(t,T) <= presyn_spike_width && t > 10.0
       q=1;
    else
       q=0;
    end

    % post-synaptic current 1 ampa current
    g_syn1=0.195;   % max conductance  (mS/cm^2)
    tau_d1=2; tau_r1=0.5; % time constants for decay and rise of synaptic current (ms)
    
    % post-synaptic current 2 nmda currnet
    g_syn2=0.0;   % max conductance  (mS/cm^2)
    tau_d2=100; tau_r2=10; % time constants for decay and rise of synaptic current (ms)

       
    dvdt = (g_k*n^4*(v_k-v) + g_na*m_inf(v)^3*h*(v_na-v) + ...
           g_l*(v_l-v) - g_syn1*s1*v - g_syn2*s2*v +i_ext)/c;
    dhdt = alpha_h(v)*(1-h)-beta_h(v)*h; 
    dndt = alpha_n(v)*(1-n)-beta_n(v)*n; 
    ds1dt = q*(1-s1)/tau_r1-s1/tau_d1;
    ds2dt = q*(1-s2)/tau_r2-s2/tau_d2;
    
    dvarsdt = [dvdt; dhdt; dndt; ds1dt; ds2dt];

end

end %% for function
