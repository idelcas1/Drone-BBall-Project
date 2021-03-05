function [F, performance_log] = animate_drone_bball(sim_data,plot_options)

% t: time vector
% u = [T_L,T_R]: control input normalized by mg
% X = [x,y,theta]: position states
% X_d = [x_d,y_d,theta_d]: desired position states
% d = [d_x,d_y,d_theta]: airflow velcoity and curl disturbances
% C = [C_x,C_y,C_z]: camera position
% um_frames: number of frames for movie

% fig: figure number to use
% zoom: global zoom adjustment


figure(plot_options.fig)
set(gcf,'Visible','on')
clf

if plot_options.full_screen
    set(gcf,'WindowState','maximized')
%     pause(5) % takes time for the window to resize and for get to return correct size
    axis('equal') % not sure if this works
    gcf_pos = get(gcf,'Position');
    plot_size = gcf_pos(3:4) - 40;
else
    plot_size = round([1 17/24]*plot_options.window_size);
    set(gcf,'WindowState','normal')
    gcf_pos = get(gcf,'Position');
    set(gcf,'Position',[gcf_pos(1:2) plot_size+40])
end

ax = [-12 12 0 17];

line_scale = plot_size(1)/1440;
ax_scale = plot_options.resolution * plot_size ./ (ax*[-1 1 0 0;0 0 -1 1]');

% simplified drone geometry
r = .475; %.25; % half width of full drone
h = .35; %.1; % height of props
w = .2; %.1;  % half width of props
drone = [-r+w -r-w -r -r r r r+w r-w;...
            h    h  h  0 0 h  h   h];


% Drone icon made by Freepik from www.flaticon.com
[I_drone_A, ~, alpha_drone] = imread('graphics/drone_A.png');
[I_drone_B, ~, ~] = imread('graphics/drone_B.png');
XY_drone = 0.75*[1 -1;-1 1];
I_drone_A   = resize_image(I_drone_A  ,round(abs(diff(XY_drone).*ax_scale)));
I_drone_B   = resize_image(I_drone_B  ,round(abs(diff(XY_drone).*ax_scale)));
alpha_drone = resize_image(alpha_drone,round(abs(diff(XY_drone).*ax_scale)));

% EMP icon made by Freepik from www.flaticon.com
[I_emp, ~, alpha_emp] = imread('graphics/emp.png');
XY_emp = 0.25*[1 -1;-1 1];
I_emp     = resize_image(I_emp    ,round(abs(diff(XY_emp).*ax_scale)));
alpha_emp = resize_image(alpha_emp,round(abs(diff(XY_emp).*ax_scale)));

% Hoop icon made by prettycons from >www.flaticon.com
[I_backboard, ~, alpha_backboard] = imread('graphics/backboard.png');
alpha_backboard = round(alpha_backboard*.5);
[I_hoop, ~, alpha_hoop] = imread('graphics/hoop.png');
XY_hoop = 1.2*[1 -1;-1 1];
I_backboard     = resize_image(I_backboard    ,.5*round(abs(diff(XY_hoop).*ax_scale)));
alpha_backboard = resize_image(alpha_backboard,.5*round(abs(diff(XY_hoop).*ax_scale)));
I_hoop          = resize_image(I_hoop         ,.5*round(abs(diff(XY_hoop).*ax_scale)));
alpha_hoop      = resize_image(alpha_hoop     ,.5*round(abs(diff(XY_hoop).*ax_scale)));

% Ball icon made by Pixel perfect from https://www.flaticon.com
[I_ball, ~, alpha_ball] = imread('graphics/ball.png');
XY_ball = .3*[1 -1;-1 1];
I_ball          = resize_image(I_ball         ,round(abs(diff(XY_ball).*ax_scale)));
alpha_ball      = resize_image(alpha_ball     ,round(abs(diff(XY_ball).*ax_scale)));

num_frames = round(sim_data.t(end)*plot_options.fps)+1; % capture evenly spaced frames at given fps
F(num_frames) = struct('cdata',[],'colormap',[]);

% t_even = 7.0:.1:8.5; % for troubleshooting

t_even      = interp1([1 num_frames], sim_data.t([1 end]), 1:num_frames);
X_drone_even     = interp1(sim_data.t, sim_data.X_drone_t,      t_even)';
X_hook_even      = interp1(sim_data.t, sim_data.X_hook_t,       t_even)';
X_ball_even      = interp1(sim_data.t, sim_data.X_ball_t,       t_even)';
X_emp_even       = interp1(sim_data.t, sim_data.X_emp_t,        t_even)';
emp_visible_even = interp1(sim_data.t, sim_data.emp_visible_t,  t_even)';
stunned_even     = interp1(sim_data.t, sim_data.stunned_t,      t_even)';
score_even       = interp1(sim_data.t, sim_data.score_t,        t_even)';

X_d_even    = interp1(sim_data.t,     sim_data.X_d_t,      t_even)';
u_even      = interp1(sim_data.t,     sim_data.u_t,        t_even)';

R = @(th_) [cos(th_) sin(th_);-sin(th_) cos(th_)];

performance_log = zeros(num_frames,3);
tic; % time statement

for fr = 1:num_frames
    clf
       
    set(gcf,'Visible','on')
    hold on
           
    axis(ax)
    
    plot([-12 12 12 -12 -12],[0 0 16 16 0],'k','LineWidth',2*line_scale) % draw ground
    plot([-4 0 4;-4 0 4],[0 16],'k--','LineWidth',2*line_scale) % draw ground

    performance_log(fr,1) = toc; tic; % time statement
    
    image(I_backboard,'AlphaData', alpha_backboard, ...
        'XData',XY_hoop(:,1)+mean(sim_data.p_hoop(1,1:2)),...
        'YData',XY_hoop(:,1)+mean(sim_data.p_hoop(2,1:2))+.33);
    image(I_backboard,'AlphaData', alpha_backboard, ...
        'XData',XY_hoop(:,1)+mean(sim_data.p_hoop(1,3:4)),...
        'YData',XY_hoop(:,1)+mean(sim_data.p_hoop(2,3:4))+.33);
       
    I_ball_r = imrotate(I_ball,X_ball_even(5,fr)*180/pi);
    alpha_ball_r = imrotate(alpha_ball,X_ball_even(5,fr)*180/pi);
    XY_ball_r = XY_ball.*size(I_ball_r(:,:,1))./size(I_ball(:,:,1));
    image(I_ball_r,'AlphaData', alpha_ball_r, ...
        'XData', XY_ball_r(:,1)+X_ball_even(1,fr), ...
        'YData', XY_ball_r(:,1)+X_ball_even(3,fr));
    
    image(I_hoop,'AlphaData', alpha_hoop, ...
        'XData',XY_hoop(:,1)+mean(sim_data.p_hoop(1,1:2)),...
        'YData',XY_hoop(:,1)+mean(sim_data.p_hoop(2,1:2))+.33);
    image(I_hoop,'AlphaData', alpha_hoop, ...
        'XData',XY_hoop(:,1)+mean(sim_data.p_hoop(1,3:4)),...
        'YData',XY_hoop(:,1)+mean(sim_data.p_hoop(2,3:4))+.33);
    
    performance_log(fr,2) = toc; tic; % time statement

    for dr = 0:1
        
        if plot_options.design_mode && (dr == 0)
%             plot(X_d_even(1+dr*6,1:fr),X_d_even(3+dr*6,1:fr),'m--','LineWidth',1*line_scale)
%             plot(X_drone_even(1+dr*6,1:fr),X_drone_even(3+dr*6,1:fr),'k--','LineWidth',1*line_scale)
            
            ind = logical(sim_data.t<t_even(fr));
            plot(sim_data.X_d_t(ind,1+dr*6),sim_data.X_d_t(ind,3+dr*6),'m--','LineWidth',1*line_scale)
            plot(sim_data.X_drone_t(ind,1+dr*6),sim_data.X_drone_t(ind,3+dr*6),'k--','LineWidth',1*line_scale)
            
            XY_drone_r = R(X_d_even(5+dr*6,fr))*XY_drone;
            I_drone_r = imrotate(I_drone_A,X_d_even(5+dr*6,fr)*180/pi);
            alpha_drone_r = imrotate(alpha_drone,X_d_even(5+dr*6,fr)*180/pi);
            XY_drone_r = XY_drone.*size(I_drone_r(:,:,1))./size(I_drone_A(:,:,1));
            image(I_drone_r,'AlphaData', 0.5*alpha_drone_r, ...
                'XData',XY_drone_r(:,1)+X_d_even(1+dr*6,fr),...
                'YData',XY_drone_r(:,1)+X_d_even(3+dr*6,fr));
            
%             drone_d_plot = R(X_d_even(5+dr*6,fr))*drone + X_d_even([1 3]+dr*6,fr);
%             plot(drone_d_plot(1,:),drone_d_plot(2,:),'m','LineWidth',4*line_scale)

            u_scaled = .5*u_even;

            T_L_plot = R(X_drone_even(5+dr*6,fr))*[-r -r;h h+u_scaled(1+dr*2,fr)] + X_drone_even([1 3]+dr*6,fr);
            plot(T_L_plot(1,:),T_L_plot(2,:),'m','LineWidth',line_scale*8)

            T_R_plot = R(X_drone_even(5+dr*6,fr))*[r r;h h+u_scaled(2+dr*2,fr)] + X_drone_even([1 3]+dr*6,fr);
            plot(T_R_plot(1,:),T_R_plot(2,:),'m','LineWidth',line_scale*8)
        end
    
        performance_log(fr,3+5*dr) = toc; tic; % time statement

        if emp_visible_even(1+dr,fr)
            I_emp_r = imrotate(I_emp,X_emp_even(5+dr*6,fr)*180/pi+45);
            alpha_emp_r = imrotate(alpha_emp,X_emp_even(5+dr*6,fr)*180/pi+45);
            XY_emp_r = XY_emp.*size(I_emp_r(:,:,1))./size(I_emp(:,:,1));
            image(I_emp_r,'AlphaData', alpha_emp_r, ...
                'XData',XY_emp_r(:,1)+X_emp_even(1+dr*6,fr),...
                'YData',XY_emp_r(:,1)+X_emp_even(3+dr*6,fr));
        end
        
        performance_log(fr,4+5*dr) = toc; tic; % time statement

        if stunned_even(1+dr,fr)
            n_s = 5; % number of sparks
            for spark = 1:n_s
                spark_angle = 2*pi/n_s*rem(round(t_even(fr)+sqrt(spark),1)*pi^2.3*17,1)+2*pi/n_s*spark;
                I_emp_r =     imrotate(I_emp,    (X_drone_even(5+dr*6,fr)+spark_angle)*180/pi+45);
                alpha_emp_r = imrotate(alpha_emp,(X_drone_even(5+dr*6,fr)+spark_angle)*180/pi+45);
                XY_emp_r = XY_emp.*size(I_emp_r(:,:,1))./size(I_emp(:,:,1));
                spark_pos = R(X_drone_even(5+dr*6,fr))*[0.6*cos(spark_angle);-0.25*sin(spark_angle)];
                image(I_emp_r,'AlphaData', alpha_emp_r, ...
                    'XData',XY_emp_r(:,1)+X_drone_even(1+dr*6,fr)+spark_pos(1),...
                    'YData',XY_emp_r(:,1)+X_drone_even(3+dr*6,fr)+spark_pos(2));
            end
        end
    
        performance_log(fr,5+5*dr) = toc; tic; % time statement

        XY_drone_r = R(X_drone_even(5+dr*6,fr))*XY_drone;
        if dr == 0
            I_drone_r = imrotate(I_drone_A,X_drone_even(5+dr*6,fr)*180/pi);
        else
            I_drone_r = imrotate(I_drone_B,X_drone_even(5+dr*6,fr)*180/pi);

        end
        alpha_drone_r = imrotate(alpha_drone,X_drone_even(5+dr*6,fr)*180/pi);
        XY_drone_r = XY_drone.*size(I_drone_r(:,:,1))./size(I_drone_A(:,:,1));
        image(I_drone_r,'AlphaData', alpha_drone_r, ...
            'XData',XY_drone_r(:,1)+X_drone_even(1+dr*6,fr),...
            'YData',XY_drone_r(:,1)+X_drone_even(3+dr*6,fr));

        performance_log(fr,6+5*dr) = toc; tic; % time statement

        p_tether_r = R(X_drone_even(5+dr*6,fr))*sim_data.p_tether;
        plot([X_drone_even(1+dr*6,fr)+p_tether_r(1) X_hook_even(1+dr*6,fr)], ...
             [X_drone_even(3+dr*6,fr)+p_tether_r(2) X_hook_even(3+dr*6,fr)],'k','LineWidth',2*line_scale)
        plot(X_hook_even(1+dr*6,fr),X_hook_even(3+dr*6,fr),'k.','MarkerSize',20*line_scale);
        
        performance_log(fr,7+5*dr) = toc; tic; % time statement

    end
    
%     for hoop = 1:size(sim_data.p_hoop,2)
%         plot(sim_data.p_hoop(1,hoop),sim_data.p_hoop(2,hoop),'k.','MarkerSize',20)
%     end

    text(-7,16.6,[plot_options.drone_1_name ': ' num2str(score_even(1,fr),'%1.0f')],'Color','b','HorizontalAlignment', 'center','FontSize',42*line_scale)
    text( 7,16.6,[plot_options.drone_2_name ': ' num2str(score_even(2,fr),'%1.0f')],'Color','r','HorizontalAlignment', 'center','FontSize',42*line_scale)
    text( 0,16.6,num2str(sim_data.t_max - t_even(fr),'%1.1f'),'HorizontalAlignment', 'center','FontSize',48*line_scale)
%     text( 0,16.5,['Time: ' num2str(60 - t_even(fr),'%1.1f')],'HorizontalAlignment', 'center','FontSize',32*line_scale)       
    
    axis('equal')
    axis(ax)
    set(gca,'Units','pixels')
    set(gca,'Position',[20 20 plot_size])
    grid off
    set(gca,'Xtick',xticks,'Ytick',yticks)
    set(gca,'Color','none')
    set(gca,'XColor', 'none','YColor','none')
%     set(gca,'Visible','off')
    
    if fr == 1
        if sim_data.message == 1
            text(-5,6.5,plot_options.drone_1_name,'Color','b','HorizontalAlignment', 'center','FontSize',64*line_scale)
            text( 0,5,'vs','Color','k','HorizontalAlignment', 'center','FontSize',64*line_scale)
            text( 5,3.5,plot_options.drone_2_name,'Color','r','HorizontalAlignment', 'center','FontSize',64*line_scale)
        elseif sim_data.message == 2
            text( 0.1,8,'Halftime','Color','k','HorizontalAlignment', 'center','FontSize',64*line_scale)
        elseif sim_data.message == 3
            text( 0,8,'Sudden Death!','Color','k','HorizontalAlignment', 'center','FontSize',64*line_scale)
        end
    elseif fr == num_frames
        if sim_data.message == 1
            text( 0.1,8,'Halftime','Color','k','HorizontalAlignment', 'center','FontSize',64*line_scale)
        elseif sim_data.message == 2
            if score_even(1,fr) > score_even(2,fr)
                text(10,11,[plot_options.drone_1_name ' Wins!'],'Color','b','HorizontalAlignment', 'right','FontSize',80*line_scale)
            elseif score_even(1,fr) < score_even(2,fr)
                text(-10,11,[plot_options.drone_2_name ' Wins!'],'Color','r','HorizontalAlignment', 'left','FontSize',80*line_scale)
            else
                text( 0,3.5,'We''re going into Overtime!','Color','k','HorizontalAlignment', 'center','FontSize',64*line_scale)
            end
        elseif sim_data.message == 3
            if score_even(1,fr) > score_even(2,fr)
                text(10,11,[plot_options.drone_1_name ' Wins!'],'Color','b','HorizontalAlignment', 'right','FontSize',80*line_scale)
            elseif score_even(1,fr) < score_even(2,fr)
                text(-10,11,[plot_options.drone_2_name ' Wins!'],'Color','r','HorizontalAlignment', 'left','FontSize',80*line_scale)
            else
                text( 0,3.5,'Tie Game!','Color','k','HorizontalAlignment', 'center','FontSize',64*line_scale)
            end
        end
    end
    
    drawnow; % Ensure plot is updated each pass of for loop
    if plot_options.save_movie
    	F(fr) = getframe; % Disable video creation to speed up
    end
    
    performance_log(fr,13) = toc; tic; % time statement

end

    function new_image_ = resize_image(image_,new_size_)
        new_image_ = [];
        size_ = size(image_);
        if ndims(size_) < 3
            size_ = [size_ 1];
        end
        for z_ = 1:size_(3)
            new_image_(:,:,z_) = interpn(double(image_(:,:,z_)), ...
                                         1+(0:new_size_(1)-1)'*512/new_size_(1), ...
                                         1+(0:new_size_(2)-1) *512/new_size_(2));
        end
        new_image_ = uint8(new_image_);
    end

    function new_image_ = map2pixels(image_,new_size_)
        new_image_ = [];
        size_ = size(image_);
        if ndims(size_) < 3
            size_ = [size_ 1];
        end
        image_double_ = double(image_);
        for z_ = 1:size_(3)
            new_image_(:,:,z_) = interpn(image_(:,:,z_), ...
                                         1+(0:new_size_(1)-1)'*512/new_size_(1), ...
                                         1+(0:new_size_(2)-1) *512/new_size_(2));
        end
        new_image_ = uint8(new_image_);
    end
end