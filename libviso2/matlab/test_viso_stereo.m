% demonstrates stereo visual odometry on an image sequence
disp('===========================');
clear all; close all; dbstop error;

% parameter settings (for an example, please download
% sequence '2010_03_09_drive_0019' from www.cvlibs.net)
%img_dir     = '/home/twangcat/Desktop/libviso2/I280stereo/';
img_dir     = '/afs/cs/group/brain/scailsave/twangcat_Desktop/Desktop/stereo/stereo/data_5_16_2013/imgs/c/';
%img_dir     = 'C:\Users\geiger\Desktop\2010_03_09_drive_0019';
croptop = 400;
cropbottom = 180;
param.f     = 2187;
param.cu    = 780;%634.1738;
param.cv    = 460.1482;
param.base  = 0.907;
first_frame = 1;
last_frame  = 6012;


% init visual odometry
visualOdometryStereoMex('init',param);

% init transformation matrix array
Tr_total{1} = eye(4);
% Tr1 = [1.0000    0.0003    0.0016    0;
%    -0.0003    1.0000    0.0007   0;
%    -0.0016   -0.0007    1.000 0;
%    0 0 0 1];

% create figure
figure('Color',[1 1 1]);
ha1 = axes('Position',[0.05,0.7,0.9,0.25]);
axis off;
ha2 = axes('Position',[0.05,0.05,0.9,0.6]);
set(gca,'XTick',-500:10:500);
set(gca,'YTick',-500:10:500);
axis equal, grid on, hold on;

% for all frames do
for frame=first_frame:last_frame
  
  % 1-index
  k = frame-first_frame+1;

  % read current images
  I1 = imread([img_dir '/280S_c_left_rectified' num2str(frame,'%05d') '.png']);
  I2 = imread([img_dir '/280S_c_right_rectified' num2str(frame,'%05d') '.png']);
  I1(1:croptop,:)=0;
  I1(end-cropbottom+1:end,:)=0;
    I2(1:croptop,:)=0;
  I2(end-cropbottom+1:end,:)=0;
%   I1 = I1(croptop+1:end-cropbottom,:);
%   I2 = I2(croptop+1:end-cropbottom,:);
  % compute and accumulate egomotion
  Tr = visualOdometryStereoMex('process',I1,I2);
  
  if k>1
    Tr_total{k} = Tr_total{k-1}/(Tr);
   % keyboard;
  end
  figure(1)
  % update image
  axes(ha1); cla;
  imagesc(I1); colormap(gray);
  axis off;
  
  % update trajectory
  axes(ha2);
  if k>1
    plot([Tr_total{k-1}(1,4) Tr_total{k}(1,4)], ...
         [Tr_total{k-1}(3,4) Tr_total{k}(3,4)],'-xb','LineWidth',1);
  end
  pause(0.01); refresh;
%     figure(2)
%   imshow(I1)
%   figure(3)
%   imshow(I2)
%   drawnow;
  
  pause(0.01); refresh;

  % output statistics
  num_matches = visualOdometryStereoMex('num_matches');
  num_inliers = visualOdometryStereoMex('num_inliers');
  disp(['Frame: ' num2str(frame) ...
        ', Matches: ' num2str(num_matches) ...
        ', Inliers: ' num2str(100*num_inliers/num_matches,'%.1f') ,' %']);
end

% release visual odometry
visualOdometryStereoMex('close');
