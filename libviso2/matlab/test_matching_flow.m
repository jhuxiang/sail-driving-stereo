% demonstrates sparse optical flow
disp('===========================');
clear all; dbstop error; close all;



rot_x = deg2rad(-0.61);
rot_y = deg2rad(0.2);
rot_z = deg2rad(0.0);


d = [-0.91025106806, -0.01152806894, 0.01762668658]';
pitch=deg2rad(0.5);
R_pitch = [1 0 0; 0 cos(pitch) -sin(pitch); 0 sin(pitch) cos(pitch)];   
R = [0.99979991, -0.01643107, -0.01140847; 0.01654639, 0.9998122, 0.01008901; 0.01124056, -0.01027576,  0.99988402]; % rotation matrix btw 2 cams     
height=1.105;
T_O = eye(4);
T_O(1:3,1:3) = R_pitch*R;
T_O(1:3, 4) = R'*d;

fx = 2221.8;
fy = 2233.7;
cu = 623.7;
cv = 445.7;
KK = [fx 0 cu; 0 fy cv; 0 0 1]; % homogenous camera matrix
KKinv = KK^(-1);

for i = 1:100
% read images from file
% Ip_orig = imread(sprintf('/home/twangcat/Desktop/libviso2/17N_monterey/17N_a2_%d.png', i));
% I1p = rgb2gray(Ip_orig);
% I1c = rgb2gray(imread(sprintf('/home/twangcat/Desktop/libviso2/17N_monterey/17N_a1_%d.png', i)));

% Ip_orig = imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a2_%d.png', i));
% I1p = rgb2gray(Ip_orig);
% I1c = rgb2gray(imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a1_%d.png', i)));

Ip_orig = imread(sprintf('/home/twangcat/Desktop/toolbox_calib/280N_left_%d.png', i));
I1p = rgb2gray(Ip_orig);
I1c = rgb2gray(imread(sprintf('/home/twangcat/Desktop/toolbox_calib/280N_left_%d.png', i+1)));
% img_dir = '/media/Extra/StanfordHighwayData/I280_3';
% 
% I1p = rgb2gray(imread([img_dir '/' num2str(1200,'%05d') '.png']));
% I1p = imresize(I1p(401:401+531,:,:), [372,1344]);
% I1c = rgb2gray(imread([img_dir '/' num2str(1201,'%05d') '.png']));
% I1c = imresize(I1c(401:401+531,:,:), [372,1344]);
% matching parameters
param.nms_n                  = 2;   % non-max-suppression: min. distance between maxima (in pixels)
param.nms_tau                = 50;  % non-max-suppression: interest point peakiness threshold
param.match_binsize          = 50;  % matching bin width/height (affects efficiency only)
param.match_radius           = 100; % matching radius (du/dv in pixels)
param.match_disp_tolerance   = 1;   % du tolerance for stereo matches (in pixels)
param.outlier_disp_tolerance = 5;   % outlier removal: disparity tolerance (in pixels)
param.outlier_flow_tolerance = 5;   % outlier removal: flow tolerance (in pixels)
param.multi_stage            = 0;   % 0=disabled,1=multistage matching (denser and faster)
param.half_resolution        = 0;   % 0=disabled,1=match at half resolution, refine at full resolution
param.refinement             = 1;   % refinement (0=none,1=pixel,2=subpixel)

% init matcher
matcherMex('init',param);

% push back images
matcherMex('push',I1p(361:840,:));
tic
matcherMex('push',I1c(361:840,:));
disp(['Feature detection: ' num2str(toc) ' seconds']);

% match images
tic; matcherMex('match',0);
p_matched = matcherMex('get_matches',0);
disp(['Feature matching:  ' num2str(toc) ' seconds']);

p_matched(:,p_matched(3,:)>p_matched(1,:)) = [];



% close matcher
matcherMex('close');




% show matching results
disp(['Number of matched points: ' num2str(length(p_matched))]);
disp('Plotting ...');

p_matched(2,:)=p_matched(2,:)+360;
p_matched(4,:)=p_matched(4,:)+360;
plotMatch(I1p,p_matched,1);

pause
end
