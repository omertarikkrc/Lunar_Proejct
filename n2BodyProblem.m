clear, clc, close all;
global m G n

%CONSTANTS
n=2;               % Number of the objects; 
G = 6.6742867e-11; % Universal Gravitational Constant [N*m*m/kg/kg]
% Re=6.3781366e6;  % Earth's radius
% m1=5.9721424e24; %  Earth's mass

% t=0:0.01:2*pi;     % 

m1=2e20; %kg
m2=5e20; %kg

L=1e10; %m

m=[m1 m2]; % Mass vector

Lm1=m2/(m1+m2)*L;
Lm2=m1/(m1+m2)*L;
w=sqrt(G*(m1+m2)/L^3);
   
    b01=[-Lm1 0 0];        % Initial position for m1 
    v01=[0 -w*Lm1 0];      % Initial velocity for m1 
    
    b02=[Lm2 0 0];        % Initial position for m2 
    v02=[0 w*Lm2 0];       % Initial velocity for m2 
    
% Initial Conditions Vector

b0=[b01 v01 b02 v02];

% ÇÖZÜM ARALIÐI
tspan1=2*pi/w;
tspan=[0 tspan1]; % [s] 
options = odeset('RelTol',1e-9,'AbsTol', 1e-9); 
[T,Y] = ode45(@SystemsOfEquations,tspan,b0,options);


figure 

hold on
plot(Y(:,1),Y(:,2),'r',Y(:,7),Y(:,8),'b');

L=1.5*L;
axis square
xlim([-L L]);
ylim([-L L]);

