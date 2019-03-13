%% Load preconditions

SC42120_UAV_Preconditions

%% Parameters for agents
M1 = 20;
init_pos1 = [-50 750 -75];
init_eul1 = [0.5 0.05 0.5];
init_vel1 = [25 0 0];
init_ang1 = [0 0 0];
I1 = [0.1 0 -0.01;0 0.05 0;-0.01 0 0.1];

M2 = 30;
init_pos2 = [-100 -1000 -100];
init_eul2 = [1 0.1 1];
init_vel2 = [5 0 0];
init_ang2 = [0 0 0];
I2 = [0.2 0 -0.02;0 0.1 0;-0.02 0 0.2];

M3 = 40;
init_pos3 = [-50 250 -150];
init_eul3 = [-0.5 -0.05 -0.5];
init_vel3 = [20 0 0];
init_ang3 = [0 0 0];
I3 = [0.4 0 -0.04;0 0.02 0;-0.04 0 0.4];

M4 = 50;
init_pos4 = [-100 0 -200];
init_eul4 = [-1 -0.1 -1];
init_vel4 = [10 0 0];
init_ang4 = [0 0 0];
I4 = [0.8 0 -0.08;0 0.4 0;-0.08 0 0.8];

%% Construct D
D1 = [eye(3)*M1 zeros(3); zeros(3) I1];
D2 = [eye(3)*M2 zeros(3); zeros(3) I2];
D3 = [eye(3)*M3 zeros(3); zeros(3) I3];
D4 = [eye(3)*M4 zeros(3); zeros(3) I4];