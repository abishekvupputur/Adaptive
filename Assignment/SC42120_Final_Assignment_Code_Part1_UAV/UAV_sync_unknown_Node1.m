SC42120_UAV_Preconditions

%% Parameters for agents
M1 = 20;
init_pos1 = [-50 750 -75];
init_eul1 = [0.5 0.05 0.5];
init_vel1 = [25 0 0];
init_ang1 = [0 0 0];
I1 = [0.1 0 -0.01;0 0.05 0;-0.01 0 0.1];
M3 = 40;
init_pos3 = [-50 250 -150];
init_eul3 = [-0.5 -0.05 -0.5];
init_vel3 = [20 0 0];
init_ang3 = [0 0 0];
I3 = [0.4 0 -0.04;0 0.2 0;-0.04 0 0.4];


Am=[zeros(6),eye(6);-Kp,-Kv];
Bm=[zeros(6,6);eye(6,6)];
Cm=[eye(12)];
Dm=zeros(12,6);
Pm=lyap(Am',100*eye(12));
S1=eye(6);