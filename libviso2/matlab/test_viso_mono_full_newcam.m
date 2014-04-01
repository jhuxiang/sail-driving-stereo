% demonstrates mono visual odometry on an image sequence
disp('===========================');
clear all; close all; dbstop error;

% parameter settings (for an example, please download
% sequence '2010_03_09_drive_0019' from www.cvlibs.net)
img_dir     = '/home/twangcat/Desktop/stereo/data_5_16_2013/imgs/Na';
%param.f      = 1441;
%param.cu     =  693.82687;
%param.cv     =    100.93987;
%croptop = 320;
param.f     = 2271.3;
param.cu    = 622.0338;
param.cv    = 419.4885;
param.height = 1.106;
param.pitch  = 0.036;
first_frame  = 2300;
last_frame   = 7498;

KK = [param.f 0 param.cu; 0 param.f param.cv; 0 0 1]; % homogenous camera matrix
Tc = [1 0 0 0; 0 cos(param.pitch) -sin(param.pitch) 0; 0 sin(param.pitch) cos(param.pitch) 0; 0 0 0 1];

% init visual odometry
visualOdometryMonoMex('init',param);

% init transformation matrix array
Tr_total{1} = Tc;

% create figure
figure('Color',[1 1 1]);
ha1 = axes('Position',[0.05,0.7,0.9,0.25]);
axis off;
ha2 = axes('Position',[0.05,0.05,0.9,0.6]);
set(gca,'XTick',-1000:10:1000);
set(gca,'YTick',-1000:10:1000);
axis equal, grid on, hold on;
step = 1;
% for all frames do
replace = 0;
for frame=first_frame:step:last_frame
  
  % 1-based index
  k = (frame-first_frame)/step+1;
  
  % read current images
I = rgb2gray(imread([img_dir '/280N_a_right' num2str(frame,'%05d') '.png']));
%I(1:croptop,:)=0;
  % compute egomotion
  Tr = visualOdometryMonoMex('process',I,replace);
  % accumulate egomotion, starting with second frame
  if k>1
    
    % if motion estimate failed: set replace "current frame" to "yes"
    % this will cause the "last frame" in the ring buffer unchanged
    if isempty(Tr)
      replace = 1;
      Tr_total{k} = Tr_total{k-1};
      
    % on success: update total motion (=pose)
    else
      replace = 0;
      Tr_total{k} = Tr_total{k-1}*inv(Tr);
    end
  end

  % update image
  axes(ha1); cla;
  imagesc(I); colormap(gray);
  axis off;
  
  % update trajectory
  axes(ha2);
  if k>1
    plot([Tr_total{k-1}(1,4) Tr_total{k}(1,4)], ...
         [Tr_total{k-1}(3,4) Tr_total{k}(3,4)],'-xb','LineWidth',1);
  end
  pause(0.05); refresh;

  % output statistics
  num_matches = visualOdometryMonoMex('num_matches');
  num_inliers = visualOdometryMonoMex('num_inliers');
  disp(['Frame: ' num2str(frame) ...
        ', Matches: ' num2str(num_matches) ...
        ', Inliers: ' num2str(100*num_inliers/num_matches,'%.1f') ,' %']);
end

% release visual odometry
visualOdometryMonoMex('close');
save Tr_280N_5_16_2013_a_right.mat Tr_total;