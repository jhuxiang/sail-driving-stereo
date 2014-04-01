labelstep = 120; 


img_dir = '/home/twangcat/Desktop/stereo/data_5_16_2013/imgs/Nf/'
startImg = 1121;

totalImg = 10601;

imprefix = '280N_f_right';
imgToLabel = (startImg):labelstep:totalImg;
xx = zeros(length(imgToLabel),2);
yy = xx;
count = 1;
for labelImg = imgToLabel
    
    imgname = [img_dir '/' imprefix num2str(labelImg,'%05d') '.png'];
    fprintf(imgname);
    I = imresize(imread(imgname),0.5);
    imshow(I);
    
    
    % label a point [x,y] in the image here
    [x,y] = ginput(2);
    [x, xid] = sort(x, 'ascend');
    y = y(xid);
    xx(count, :) = x';
    yy(count, :) = y';
    count = count+1;
end
xx = xx*2;
yy = yy*2;
xall1 = spline(imgToLabel, xx(:,1)', imgToLabel(1):imgToLabel(end));
xall2 = spline(imgToLabel, xx(:,2)', imgToLabel(1):imgToLabel(end));

yall1 = spline(imgToLabel, yy(:,1)', imgToLabel(1):imgToLabel(end));
yall2 = spline(imgToLabel, yy(:,2)', imgToLabel(1):imgToLabel(end));

% xall1 = interp1(imgToLabel,xx(:,1)',imgToLabel(1):imgToLabel(end));
% xall2 = interp1(imgToLabel,xx(:,2)',imgToLabel(1):imgToLabel(end));
% yall1 = interp1(imgToLabel,yy(:,1)',imgToLabel(1):imgToLabel(end));
% yall2 = interp1(imgToLabel,yy(:,2)',imgToLabel(1):imgToLabel(end));
xall = [xall1; xall2];
yall = [yall1; yall2];
