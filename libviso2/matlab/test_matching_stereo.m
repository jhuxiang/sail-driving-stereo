% demonstrates sparse optical flow
disp('===========================');
clear all; %dbstop error; 
close all;


% this set of calibration params are for the old Honda Accord data.
% TODO: update them for the Q50 data.
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

for i = 1:1700
% read images from file
% Ip_orig = imread(sprintf('/home/twangcat/Desktop/libviso2/17N_monterey/17N_a2_%d.png', i));
% I1p = rgb2gray(Ip_orig);
% I1c = rgb2gray(imread(sprintf('/home/twangcat/Desktop/libviso2/17N_monterey/17N_a1_%d.png', i)));

%  Ip_orig = imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a2_%d.png', i));
%  I1p = rgb2gray(Ip_orig);
%  I1c = rgb2gray(imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a1_%d.png', i)));

Ip_orig = imread(sprintf('/scail/group/deeplearning/driving_data/twangcat/stereo_test_imgs/280N_left_%d.png', i));
I1p = rgb2gray(Ip_orig);
I1c = rgb2gray(imread(sprintf('/scail/group/deeplearning/driving_data/twangcat/stereo_test_imgs/280N_right_%d.png', i)));
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
tic
matcherMex('push',I1c);
disp(['Feature detection: ' num2str(toc) ' seconds']);

% match images
tic; matcherMex('match',0);
p_matched = matcherMex('get_matches',0);
disp(['Feature matching:  ' num2str(toc) ' seconds']);

p_matched(:,p_matched(3,:)>p_matched(1,:)) = [];



% close matcher
matcherMex('close');

p = [p_matched(1:2,:); ones(1,size(p_matched,2))];
q = [p_matched(3:4,:); ones(1,size(p_matched,2))];


Ps = KKinv*p; % Pos with respected to 1st camera, scaled so that z=1
Qs = KKinv*q; % Pos with respected to 2nd camera, scaled so that z=1

% compute actual depth
Z= (((T_O(1,1:3)*Ps-T_O(3,1:3)*bsxfun(@times, Ps, Qs(1,:))))/(T_O(3,4)-T_O(1,4))).^(-1);

% once we know depth, we can then estimate X and Y wrt camera
X = Ps(1,:).*Z;
Y = Ps(2,:).*Z;
%depth2= (((T_O(2,1:3)-Qs(2)*T_O(3,1:3))*Ps)/(T_O(3,4)-T_O(2,4))).^(-1)


% show matching results
disp(['Number of matched points: ' num2str(length(p_matched))]);
disp('Plotting ...');

%   Z(Z>300)=300;
%   Z(Z<-10)=300;
%   Z(Z<0)=0;
%   X(X>300)=300;
%   X(X<-300)=-300;
%   Y(Y>300)=300;
%   Y(Y<-300)=-300;

% filter out points 100 meters away
  max_dist = 100;
  Z = abs(Z);
  X = X(Z<max_dist);
  Y = Y(Z<max_dist);
  p_matched = p_matched(:, find(Z<max_dist))';
  Z = Z(Z<max_dist);
  
  min_height=-3;
  X = X(Y>min_height);
  p_matched = p_matched(find(Y>min_height),:);
  Z = Z(Y>min_height);
  Y = Y(Y>min_height);
  
  max_height=height-0.2;
  X = X(Y<max_height);
  p_matched = p_matched(find(Y<max_height),:);
  Z = Z(Y<max_height);
  Y = Y(Y<max_height);
  Y=Y-min_height;
  
  
  Pos = [X;Y;Z];
  max_disp  = max(Z);
  %cla,figure(1),imshow(uint8(Ip_orig)),hold on;
  for pp=1:size(p_matched,1)
    % predicted Z if the point were on the road surface
    %flatZ = ((p_matched(pp,2)-cv)*sin(pitch)*height+fy*cos(pitch)*height)/(cos(pitch)*(p_matched(pp,2)-cv)-fy*sin(pitch));
    if Y(pp)<4.2
        c = abs(Z(pp)/max_disp);
        
        %c = Y(pp)/max_disp;
        col = round([c 1-c 0]*255);
        %plot(p_matched(pp,1),p_matched(pp,2),'s', 'Color', col,'LineWidth',2,'MarkerSize',2);
        Ip_orig(p_matched(pp,2)-1,p_matched(pp,1)-1,:) = uint8(col);
        Ip_orig(p_matched(pp,2)-1,p_matched(pp,1),:) = uint8(col);
        Ip_orig(p_matched(pp,2)-1,p_matched(pp,1)+1,:) = uint8(col);
        Ip_orig(p_matched(pp,2),p_matched(pp,1)-1,:) = uint8(col);
        Ip_orig(p_matched(pp,2),p_matched(pp,1),:) = uint8(col);
        Ip_orig(p_matched(pp,2),p_matched(pp,1)+1,:) = uint8(col);
        Ip_orig(p_matched(pp,2)+1,p_matched(pp,1)-1,:) = uint8(col);
        Ip_orig(p_matched(pp,2)+1,p_matched(pp,1),:) = uint8(col);
        Ip_orig(p_matched(pp,2)+1,p_matched(pp,1)+1,:) = uint8(col);
    end
  end
  %imwrite(Ip_orig, sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/depth/%d.png',i));
  %imshow(Ip_orig);
  % figure;
  % plotMatch(I1p,p_matched,1);
    figure(1)
    % !!! replace this with your own path
    plotname=sprintf('/afs/cs/group/photo_ocr/scr/stereo_try/vis.png');
    % draws on top down plot.
    set(gcf,'Visible','off');
    plot(X',Z','.');
    axis([-20 20 0 100])
    grid minor
    print('-dpng',plotname);
    pp = imresize(imread(plotname),[960,1280]);
    img = cat(2,Ip_orig,pp);
    figure(2)
    imshow(img)
    %imwrite(img,sprintf('/afs/cs/group/photo_ocr/scr/stereo_try/%d.png', i));
end
