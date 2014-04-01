load Tr_280south_full_crop_003.mat;
labelstep = 120; % that's 1 label every 4 seconds
totalImg = length(Tr_total);

% labelImg = 1;
f = 1441.3; % focal length
cu = 693.82687; % principle point
cv = 100.93987;  % all in units of pixels.
% f = 2056.7; % focal length
% cu = 964.79247; % principle point
% cv = 543.86425;  % all in units of pixels.
height = 1.1684; % camera above ground, in meters
pitch = -0.0;
KK = [f 0 cu; 0 f cv; 0 0 1]; % homogenous camera matrix
Tc = [1 0 0 0; 0 cos(pitch) -sin(pitch) -height; 0 sin(pitch) cos(pitch) 0; 0 0 0 1];

img_dir = '/media/Extra/StanfordHighwayData/I280southPNG';
startImg = 400;

%for labelImg = labelstep/2+25900:labelstep:totalImg % caused error because of poor odometry?!
startlabelImg = 1+11200;
im = imread([img_dir '/I280South_' num2str(startlabelImg,'%05d') '.png']);
%I = im;
I = imresize(im(401:401+531,:,:), [372,1344]);
imshow(I);
% label a point [x,y] in the image here
[prevx,prevy] = ginput(2);    

for labelImg = (startlabelImg+labelstep):labelstep:totalImg
    
    
    im = imread([img_dir '/I280South_' num2str(labelImg,'%05d') '.png']);
    %I = im;
    I = imresize(im(401:401+531,:,:), [372,1344]);
    imshow(I);
    
    
    % label a point [x,y] in the image here
    [currx,curry] = ginput(2);
    
    for imgnum = (labelImg-labelstep):labelImg
        
        im = imread([img_dir '/I280South_' num2str(imgnum,'%05d') '.png']);
        %I = im;
        I = imresize(im(401:401+531,:,:), [372,1344]);
        
        
        %linearly interpolate user annotations       
        xx = prevx+(currx-prevx)*(imgnum-labelImg+labelstep)/labelstep;
        yy = prevy+(curry-prevy)*(imgnum-labelImg+labelstep)/labelstep;      
        % plot points on current image
        for i = 0:1:labelstep      
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
            
            % position in world frame
            Pos = (Tr_total{imgnum+i-startImg+1})*[X;Y;Z;1];
            Pos1 = (Tr_total{imgnum+i-startImg+1})*[X1;Y1;Z1;1];
            
            
            Pos2 = inv(Tr_total{imgnum-startImg+1})*Pos;
            Pos3 = inv(Tc)*Pos2;
            pos2 = round(KK*Pos3(1:3)/Pos3(3));
            
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 255;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 0;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
            
            
            
            Pos2 = inv(Tr_total{imgnum-startImg+1})*Pos1;
            Pos3 = inv(Tc)*Pos2;
            pos2 = round(KK*Pos3(1:3)/Pos3(3));
            
            
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 0;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 255;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
            
        end
        
        
        imshow(I);
        drawnow;
    end
    prevx = currx;
    prevy = curry;
    %imwrite(I, 'reverse_viso8.png');
end
