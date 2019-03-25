%% Load preconditions

SC42120_UAV_Preconditions

%% Parameters for agents
M2 = 30;
init_pos2 = [-100 -1000 -100];
init_eul2 = [1 0.1 1];
init_vel2 = [5 0 0];
init_ang2 = [0 0 0];
I2 = [0.2 0 -0.02;0 0.1 0;-0.02 0 0.2];

Am = [zeros(6) eye(6); -Kp -Kv];
Bm = [zeros(6); eye(6)];
Pm = lyap(Am',100*eye(12));
S2 = eye(6)*1;
