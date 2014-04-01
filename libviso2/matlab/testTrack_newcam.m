%load Tr_280south_full_003.mat;
%load Tr_280south_newcam.mat
startImg = 1;

labelImg = 241;


f     = 2271.3;
cu    = 622.0338;
cv    = 419.4885;
height = 1.106;
pitch  =0.036;
KK = [f 0 cu; 0 f cv; 0 0 1]; % homogenous camera matrix
Tc = [1 0 0 0; 0 cos(pitch) -sin(pitch) -height; 0 sin(pitch) cos(pitch) 0; 0 0 0 1];

img_dir     = '/home/twangcat/Desktop/stereo/data_5_16_2013/imgs/c';

I = imread([img_dir '/280S_c_right' num2str(labelImg,'%05d') '.png']);
imshow(I);

% label a point [x,y] in the image here
[xx,yy] = ginput(2)
x = xx(1);
y = yy(1);


Zc = f*height/cos(pitch)/(y-cv-f*tan(pitch));
Yc = (height+sin(pitch)*Zc)/cos(pitch);
Z = sin(pitch)*Yc + cos(pitch)*Zc;
X = Zc*(x-cu)/f;
Y=0;


x1 = xx(2);
y1 = yy(2);
Zc1 = f*height/cos(pitch)/(y1-cv-f*tan(pitch));
Yc1 = (height+sin(pitch)*Zc1)/cos(pitch);
Z1 = sin(pitch)*Yc1 + cos(pitch)*Zc1;
X1 = Zc1*(x1-cu)/f;
Y1=0;


% 
% Z = height*f/(y-cv)
% X = Z*(x-cu)/f
% Y = height;
% position in world frame
Pos = (Tr_total{labelImg-startImg+1})*(Tc\[X;Y;Z;1]);
Pos1 = (Tr_total{labelImg-startImg+1})*(Tc\[X1;Y1;Z1;1]);

for i = 0:-1:-100%0:1:60
    I = imread([img_dir '/280S_c_right' num2str(labelImg+i,'%05d') '.png']);
    Pos2 = (Tr_total{labelImg+i-startImg+1})\Pos;
    pos2 = KK*Pos2(1:3)/Pos2(3);
        
    I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 255;
    I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 0;
    I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
    
    
    
    Pos2 = (Tr_total{labelImg+i-startImg+1})\Pos1;
    pos2 = KK*Pos2(1:3)/Pos2(3);
    
    
    I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 0;
    I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 255;
    I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
    
    

    imshow(I);
    %imwrite(imresize(I,0.5), sprintf('reverse_viso%d.png', i));
    %rectangle('Position', [pos2(1), pos2(2), 3, 3]);
    pause;
end
