g = 9.81; % (m/s^2)

m = 1; % (kg) mass of drone
r = 0.5; % moment arm of thrust
r_M_R = 0.25*r; % (m) collision moment arm
% J = 1/3*m*r^2; % (kg-m^2) rotational moment of inertia
J = 1/4*m*r^2 + 1/12*m*(2*(r+r_M_R))^2;

T_max = 4*m*g; % (N) max thrust
T_tau = 0.1; % (s) time constant of  motor spin up

b = .25*m; % (kg/m) quadratic drag coeff
b_th = .1*J; % (kg-m^2) rotational drag coeff

k_F_R = m * 10000; % (N/m) ground collision stiffness
b_F_R = m * 20; % (N-s/m) ground collision damping

mu_f = .2; % coefficient of friction between ball/drone
mu_f_gnd = 0.5; % coefficient of friction between drone/ground
k_f = 4; % onset rate of coulomb friction 

m_ball = .5; % (kg) mass of ball
r_ball = .3; % (m) radius of ball
J_ball = 2/5*m_ball*r_ball^2; % (kg-m^2) rotational moment of inertia
b_ball = .02*m_ball; % (kg/m) quadratic drag coeff
b_th_ball = .05*J_ball; % (kg-m^2) rotational drag coeffb_ball = .05*m_ball; % (kg/m) linear drag of of ball

k_F_R_ball = m_ball * 10000; % (N/m) ground collision stiffness
b_F_R_ball = m_ball * 10; % (N-s/m) ground collision damping

m_hook = 0.1*m; % (kg) mass of ball
r_hook = 0.1; % (m) effective magnetic distance when in contact with ball
b_hook = 0.05*m_hook; % (kg/m) linear drag coeff
B_hook = r_hook^2*6*m_ball*g; % (N-m^2) strength of magnet
k_F_R_hook = m_hook * 10000; % (N/m) ground collision stiffness
b_F_R_hook = m_hook * 100; % (N-s/m) ground collision damping

L_tether = 1.0; % (m) tether length
k_tether = 40; % (N/m) tether stiffness
b_tether = 1; % (N-s/m) tether damping

k_F_hook = 10000; % (N/m) tether stiffness
b_F_hook = 100;

k_F_hoop = m_ball * 5000; % (N/m) hoop stiffness
b_F_hoop = m_ball * 50;

k_x_net = 200*m_ball*g;
b_x_net = 80*m_ball*g;
k_y_net = .5*m_ball*g;
b_y_net = .4*m_ball*g;

p_0 = [-5; 5]; % initial position of each drone (mirrored)
theta_0 = 0 * pi/180; % (rad) initial angle

p_dot_0 = [0; 0]; % (m/s) initial [x;y] velocity
theta_dot_0 = 0; % (rad/s) initial angular velocity

drone = struct([]);

drone(1).X_0 = [p_0(1) p_dot_0(1) p_0(2) p_dot_0(2) theta_0 theta_dot_0]';
drone(2).X_0 = drone(1).X_0 .* [-1 -1 1 1 -1 -1]'; % mirrored

T_0 = m*g; % (N) initial thrust

p_ball_0 = [0; r_ball]; % (m) initial [x;y] position

p_ball_dot_0 = [0; 12]; % (m/s) initial [x;y] velocity (jump ball)

p_tether = [0; -0.259]; % (m) position of tether attatchment (matches graphic)

p_emp = [0; -.4]; % (m) emp cannon location
p_emp_dot = [0; -5]; % (m/s) emp velocity

p_hoop = [7.5 8; 8.5 8; -8.5 8; -7.5 8]';

clear F

video_fps = 10;

plot_options.fig = 1; % reserve figure 1 for animations

if ~isfield(plot_options,'drone_1_name')
    drone_1_name = inputdlg('Enter the name of Drone 1:');
    plot_options.drone_1_name = drone_1_name{1};
end

if ~isfield(plot_options,'drone_2_name')
    drone_2_name = inputdlg('Enter the name of Drone 2:');
    plot_options.drone_2_name = drone_2_name{1};
end

if ~isfield(plot_options,'fps')
    fps = inputdlg('Enter FPS for preview:');
    plot_options.fps = str2num(fps{1});
end

if ~exist('create_video_file','var')
    create_video_file = 0; % default option
end

if ~exist('model','var')
    % model = 'Drone_BBall_Friendly.slx'; % use the friendly match model
    model = 'Drone_BBall_Developer.slx'; % use the developer model
end

plot_options.resolution = 4;   % image resolution scale (default = 4)
if plot_options.fps < video_fps % if playing l
    plot_options.save_movie = 0;   % disable this for faster video
end
plot_options.design_mode = 0;  % 1 = Designer Mode (show thrust and flight paths)
plot_options.full_screen = 0;  % doesn't work the first time if figure not already open
plot_options.window_size = 720;

sim_data.p_tether       = p_tether;
sim_data.p_hoop         = p_hoop;

P1 = sim(model,'StopTime','60'); % play first half
sim_data.message        = 1; % Introduce Teams and end with Halftime
sim_data.t_max          = 60;
sim_data.t              = P1.t;
sim_data.X_drone_t      = P1.X_drone_t;
sim_data.X_hook_t       = P1.X_hook_t;
sim_data.X_ball_t       = P1.X_ball_t;
sim_data.X_emp_t        = P1.X_emp_t;
sim_data.stunned_t      = P1.stunned_t;
sim_data.score_t        = P1.score_t;
sim_data.emp_visible_t  = double(P1.emp_visible_t);
sim_data.u_t            = P1.T_t/(.5*m*g);
sim_data.X_d_t          = P1.X_d_t;

sim_data_P1 = sim_data;

FP1 = animate_drone_bball(sim_data,plot_options);

P2 = sim(model,'StopTime','60'); % play second half
sim_data.message        = 2; % End with Declaration of Winner

sim_data.t_max          = 60;
sim_data.t              = P2.t;
sim_data.X_drone_t      = P2.X_drone_t;
sim_data.X_hook_t       = P2.X_hook_t;
sim_data.X_ball_t       = P2.X_ball_t;
sim_data.X_emp_t        = P2.X_emp_t;
sim_data.stunned_t      = P2.stunned_t;
sim_data.score_t        = P1.score_t(end,:) + P2.score_t;
sim_data.emp_visible_t  = double(P2.emp_visible_t);
sim_data.u_t            = P2.T_t/(.5*m*g);
sim_data.X_d_t          = P2.X_d_t;

sim_data.p_tether       = p_tether;
sim_data.p_hoop         = p_hoop;

sim_data_P2 = sim_data;

FP2 = animate_drone_bball(sim_data,plot_options);

overtime = 0;
if sim_data.score_t(end,1) == sim_data.score_t(end,2) % if tied after second half
    overtime = 1;
    while true
        OT = sim(model,'StopTime','30'); % play overtime
        if sum(OT.score_t(end,:)) % if a basket was scored during overtime
            break
        end
    end
    % log data only for last overtime period played
    time_to_stop = min(30,1+OT.t(find(sum(OT.score_t,2),1))) % stop 1 second after basket scored
    ind = OT.t <= time_to_stop;
    
    sim_data.message        = 3; % OT Messaging

    sim_data.t_max          = 30;
    sim_data.t              = OT.t(ind);
    sim_data.X_drone_t      = OT.X_drone_t(ind,:);
    sim_data.X_hook_t       = OT.X_hook_t(ind,:);
    sim_data.X_ball_t       = OT.X_ball_t(ind,:);
    sim_data.X_emp_t        = OT.X_emp_t(ind,:);
    sim_data.stunned_t      = OT.stunned_t(ind,:);
    sim_data.score_t        = P1.score_t(end,:) + P2.score_t(end,:) + OT.score_t(ind,:);
    sim_data.emp_visible_t  = double(OT.emp_visible_t(ind,:));
    sim_data.u_t            = OT.T_t(ind,:)/(.5*m*g);
    sim_data.X_d_t          = OT.X_d_t(ind,:);

    sim_data_OT = sim_data;
    
    FOT = animate_drone_bball(sim_data,plot_options);
else
    FOT = [];
end

% replay animation at video_fps and save frames for video

if create_video_file
    if plot_options.fps < video_fps
        plot_options.fps = video_fps;
        plot_options.save_movie = 1;
        FP1 = animate_drone_bball(sim_data_P1,plot_options);
        FP2 = animate_drone_bball(sim_data_P2,plot_options);
        if overtime
            FOT = animate_drone_bball(sim_data_OT,plot_options);
        end
    end
end

F = [repmat(FP1(1),[1 plot_options.fps*2]) FP1 repmat(FP1(end),[1 plot_options.fps*1])];
F = [F repmat(FP2(1),[1 plot_options.fps*1]) FP2 repmat(FP2(end),[1 plot_options.fps*1])];
if ~isempty(FOT)
    F = [F repmat(FOT(1),[1 plot_options.fps*1]) FOT repmat(FOT(end),[1 plot_options.fps*1])];
end

if create_video_file
    for n = 1:length(F)
        F(n).cdata = F(n).cdata(1:1020,1:1440,1:3);
    end

    v = VideoWriter(['QC_BB_' plot_options.drone_1_name '_v_' plot_options.drone_2_name]);
    v.FrameRate = plot_options.fps;
    v.Quality = 25;
    open(v)
    writeVideo(v,F)
    close(v)
end