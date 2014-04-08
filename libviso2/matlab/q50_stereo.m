%{
========================================================
Performs parse matching with Q50 car camera calibrations.
Authors: Tao, Pranav
++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%}

disp('===========================');
clear all; %dbstop error; 
close all;

%Distortion coefficients
d = [-0.5873763710461054, 0.00012196510170337307, 0.08922401781210791]';
%R    
R = [0.9999355343485463, -0.00932576944123699, 0.006477435558612815; 0.009223923954826548, 0.9998360945238545, 0.015578938158992275; -0.006621659456863392, -0.01551818647957998, 0.9998576596268203];

T_O = eye(4);
T_O(1:3,1:3) = R;
T_O(1:3, 4) = R'*d;


KKLeft = [2254.7629881361104 0.0 655.5568389543264; 0.0 2266.3053663916653 488.8502207665989; 0.0, 0.0, 1.0];
KKLeftinv = KKLeft^(-1);
KKRight = [2250.7203235684196 0.0 648.9587583746263; 0.0 2263.7523809342106 450.2497022795749; 0.0 0.0 1.0];
KKRightinv = KKRight^(-1);

for i = 100:200 %change to start and end images
% read images from file
Ip_orig = imread(sprintf('/scail/group/deeplearning/driving_data/andriluka/IMAGES/driving_data_sameep/4-2-14-monterey/4-2-14-monterey-split_0_17N_a1/4-2-14-monterey-split_0_17N_a1_000%d.jpeg', i));
I1p = rgb2gray(Ip_orig);
I1c = rgb2gray(imread(sprintf('/scail/group/deeplearning/driving_data/andriluka/IMAGES/driving_data_sameep/4-2-14-monterey/4-2-14-monterey-split_0_17N_a2/4-2-14-monterey-split_0_17N_a2_000%d.jpeg', i)));

% matching parameters
param.nms_n                  = 2;   % non-max-suppression: min. distance between maxima (in pixels)
param.nms_tau                = 50;  % non-max-suppression: interest point peakiness threshold
param.match_binsize          = 50;  % matching bin width/height (affects efficiency only)
param.match_radius           = 140; % matching radius (du/dv in pixels)
param.match_disp_tolerance   = 1;   % du tolerance for stereo matches (in pixels)
param.outlier_disp_tolerance = 5;   % outlier removal: disparity tolerance (in pixels)
param.outlier_flow_tolerance = 5;   % outlier removal: flow tolerance (in pixels)
param.multi_stage            = 0;   % 0=disabled,1=multistage matching (denser and faster)
param.half_resolution        = 0;   % 0=disabled,1=match at half resolution, refine at full resolution
param.refinement             = 1;   % refinement (0=none,1=pixel,2=subpixel)

% init matcher
matcherMex('init',param);

% push back images
matcherMex('push',I1p);
matcherMex('push',I1c);

% match images
matcherMex('match',0);
p_matched = matcherMex('get_matches',0);
p_matched(:,p_matched(3,:)>p_matched(1,:)) = [];

% close matcher
matcherMex('close');

p = [p_matched(1:2,:); ones(1,size(p_matched,2))];
q = [p_matched(3:4,:); ones(1,size(p_matched,2))];

Ps = KKLeftinv*p; % Pos with respected to 1st camera, scaled so that z=1
Qs = KKRightinv*q; % Pos with respected to 2nd camera, scaled so that z=1

% get X,Y,Z
Z = (((T_O(1,1:3)*Ps-T_O(3,1:3)*bsxfun(@times, Ps, Qs(1,:))))/(T_O(3,4)-T_O(1,4))).^(-1);
X = Ps(1,:).*Z;
Y = Ps(2,:).*Z;

% show matching results
disp(['Number of matched points: ' num2str(length(p_matched))]);
disp('Plotting ...');

% filter out points 100 meters away
  max_dist = 100;
  Z = abs(Z);
  X = X(Z<max_dist);
  Y = Y(Z<max_dist);
  p_matched = p_matched(:, find(Z<max_dist))';
  Z = Z(Z<max_dist);
 
%filter out anything below 3 meters
  min_height=-3;
  X = X(Y>min_height);
  p_matched = p_matched(find(Y>min_height),:);
  Z = Z(Y>min_height);
  Y = Y(Y>min_height);

%filter to filter out the road. Warning: currently set to 0. Change to a
%higher number if needed.
  max_height=0.0;
  X = X(Y<max_height);
  p_matched = p_matched(find(Y<max_height),:);
  Z = Z(Y<max_height);
  Y = Y(Y<max_height);
  Y=Y-min_height;
  
  Pos = [X;Y;Z];
  max_disp  = max(Z);
  for pp=1:size(p_matched,1)
    if Y(pp)<4.2
        c = abs(Z(pp)/max_disp);
        col = round([c 1-c 0]*255);
        for(i =-3:3)
            for(j = -3:3)
                Ip_orig(p_matched(pp,2)+ i,p_matched(pp,1)+ j,:) = uint8(col);
            end
        end
    end
  end
  
  %draw the plot
  figure(1)
  hFig= figure(1);
  subplot(2,1,1)
  plot(X',Z','.');
  title({'top-down view'});
  axis([-20 20 0 100])
  axis square
  subplot(2,1,2)
  imshow(Ip_orig)
end
