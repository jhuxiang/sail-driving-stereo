% demonstrates mono visual odometry on an image sequence
disp('===========================');
clear all; close all; dbstop error;

% parameter settings (for an example, please download
% sequence '2010_03_09_drive_0019' from www.cvlibs.net)
img_dir     = '/media/Extra/StanfordHighwayData/I280_3';
param.f      = 1441;
param.cu     =  693.82687;
param.cv     =    100.93987;
%param.f      = 2056.7;
%param.cu     =  964.79247;
%param.cv     =    543.86425;
%param.height = 1.1684;
param.height = 1.143;
param.pitch  = -0.03;
first_frame  = 1;
last_frame   = 14285;
%img_dir     = 'C:\Users\geiger\Desktop\2010_03_09_drive_0019';
% param.f      = 645.2;
% param.cu     = 635.9;
% param.cv     = 194.1;
% param.height = 1.6;
% param.pitch  = -0.08;
% first_frame  = 0;
% last_frame   = 372;

% init visual odometry
visualOdometryMonoMex('init',param);

% init transformation matrix array
Tr_total{1} = eye(4);

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
  im = imread([img_dir '/' num2str(frame,'%05d') '.png']);
  %I = rgb2gray(im);
  I = rgb2gray(imresize(im(401:401+531,:,:), [372,1344]));

  % compute egomotion
  Tr = visualOdometryMonoMex('process',I,replace);
  
  p_matched = visualOdometryMonoMex('get_matches');
  inliers = visualOdometryMonoMex('get_inliers');
  if ~isempty(inliers)
      p_matched(:,inliers+1) = [];
  end
  figure(2)
  plotMatch(I,p_matched,0);
  
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
  figure(1)
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
%save('Tr_280south_3_crop.mat', 'Tr_total');
visualOdometryMonoMex('close');
