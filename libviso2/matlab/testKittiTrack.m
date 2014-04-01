load Tr_kitti_mono2.mat;

startImg = 0;

labelImg = 180;
f     = 645.2;
cu    = 635.9;
cv    = 194.1;
pitch = -0.06;
height = 1.6; % camera above ground, in meters

KK = [f 0 cu; 0 f cv; 0 0 1]; % homogenous camera matrix
Tc = [1 0 0 0; 0 cos(pitch) -sin(pitch) -height; 0 sin(pitch) cos(pitch) 0; 0 0 0 1];

img_dir = '/home/twangcat/Desktop/libviso2/videos/2010_03_09_drive_0019';


I = imread([img_dir '/I1_' num2str(labelImg,'%06d') '.png']);

imshow(I);


% label a point [x,y] in the image here
[x,y] = ginput(1)
Zc = f*height/cos(pitch)/(y-cv-f*tan(pitch));
Yc = (height+sin(pitch)*Zc)/cos(pitch);
Z = sin(pitch)*Yc + cos(pitch)*Zc;
X = Zc*(x-cu)/f;
Y=0;

% Z = height*f/(y-cv - f*sin(pitch));
% X = Z*(x-cu)/f;
% Z = height*f/(y-cv)
% X = Z*(x-cu)/f
% Y = height;
% position in world frame
Pos = (Tr_total{labelImg-startImg+1})*[X;Y;Z;1];
for i = 1:15
    I = imread([img_dir '/I1_' num2str(labelImg+i,'%06d') '.png']);
    % world coordinate wrt car
    Pos2 = inv(Tr_total{labelImg+i-startImg+1})*Pos;
    % world coordinate wrt camera
    Pos3 = inv(Tc)*Pos2;
%     Pos3 = [Pos2(1); (Pos2(2)+Pos2(3)*sin(pitch))/cos(pitch); Pos2(3)/cos(pitch)];
    pos2 = KK*Pos3(1:3)/Pos3(3);
    I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 255;
    %I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 0;
    %I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
    imshow(I);
    %imwrite(imresize(I,0.5), sprintf('viso%d.png', i));
    %rectangle('Position', [pos2(1), pos2(2), 3, 3]);
    pause;
end
