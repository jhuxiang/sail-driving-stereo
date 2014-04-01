labelstep = 2; % frame steps


img_dir = '/home/twangcat/Desktop/stereo/data_5_16_2013/imgs/Nf/';
startImg = 1021;

imprefix = '280N_f_right';

totalImg = 10601;


imgToLabel = (startImg):labelstep:totalImg;
xx = zeros(length(imgToLabel),1);
yy = xx;
count = 1;

headSkip = 100; % number of images to skip in the beginning

global C; % mouse coordinate
resizeFactor = 0.5; % downscale images to make display faster
for labelImg = imgToLabel
    
    imgname = [img_dir '/' imprefix num2str(labelImg,'%05d') '.png'];
    fprintf(imgname);
    im = imread(imgname);
    %I = im;
    I = imresize(im, resizeFactor);
    imshow(I);
    if labelImg==startImg
        pause;
    end
    
    % label a point [x,y] in the image here
    %[x,y] = ginput(2);
%     [x, xid] = sort(x, 'ascend');
%     y = y(xid);
    drawnow; 
    set(gcf, 'WindowButtonMotionFcn', @mouseMove);
    xx(count) = C(1,1);
    yy(count) = C(1,2);
    count = count+1;
end

imgToLabel(1:(headSkip/labelstep))=[];
xx(1:(headSkip/labelstep)) = [];
yy(1:(headSkip/labelstep)) = [];

xall1 = spline(imgToLabel, (xx(:)/resizeFactor)', 1:totalImg-startImg-headSkip+1);
% xall2 = spline(imgToLabel, xx(:,2)', 1:totalImg);

yall1 = spline(imgToLabel, (yy(:)*resizeFactor)', 1:totalImg-startImg-headSkip+1);
% yall2 = spline(imgToLabel, yy(:,2)', 1:totalImg);

% xall = [xall1; xall2];
% yall = [yall1; yall2];
