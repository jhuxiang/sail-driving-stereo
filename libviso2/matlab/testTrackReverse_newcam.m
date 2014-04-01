%load Tr_280south_newcam.mat
labelstep = 120; % that's 1 label every 4 seconds
totalImg = length(Tr_total);

f     = 2271.3;
cu    = 622.0338;
cv    = 419.4885;
height = 1.106;
pitch  = 0.036;
KK = [f 0 cu; 0 f cv; 0 0 1]; % homogenous camera matrix
Tc = [1 0 0 0; 0 cos(pitch) -sin(pitch) -height; 0 sin(pitch) cos(pitch) 0; 0 0 0 1];
p2 = 0.005;
Tc2 = [1 0 0 0; 0 cos(p2) -sin(p2) 0 ; 0 sin(p2) cos(p2) 0; 0 0 0 1];
img_dir = '/home/twangcat/Desktop/stereo/data_5_16_2013/imgs/c/';
startImg = 1;

imprefix = '280S_c_right';

startlabelImg = 8000;
I = imread([img_dir imprefix num2str(startlabelImg,'%05d') '.png']);
imshow(I);
% label a point [x,y] in the image here
[prevx,prevy] = ginput(2);    

for labelImg = (startlabelImg+labelstep):labelstep:totalImg
    
    

    I =imread([img_dir imprefix num2str(labelImg,'%05d') '.png']);
    imshow(I);
    
    
    % label a point [x,y] in the image here
    [currx,curry] = ginput(2);
    
    for imgnum = (labelImg-labelstep):labelImg
        

        I = imread([img_dir imprefix num2str(imgnum,'%05d') '.png']);
        
        
        %linearly interpolate user annotations       
        xx = prevx+(currx-prevx)*(imgnum-labelImg+labelstep)/labelstep;
        yy = prevy+(curry-prevy)*(imgnum-labelImg+labelstep)/labelstep;      
        % plot points on current image
        for i = 0:1:labelstep      
            x = xx(1);
            y = yy(1);
            

            Z = ((y-cv)*sin(pitch)*height+f*cos(pitch)*height)/(cos(pitch)*(y-cv)-f*sin(pitch));
            X = (cos(pitch)*Z-sin(pitch)*height)*(x-cu)/f;
            Y=0;
            
            
            x1 = xx(2);
            y1 = yy(2);

            
            Z1 = ((y1-cv)*sin(pitch)*height+f*cos(pitch)*height)/(cos(pitch)*(y1-cv)-f*sin(pitch));
            X1 = (cos(pitch)*Z1-sin(pitch)*height)*(x1-cu)/f;
            Y1=0;
            
            % position in world frame
            Pos = (Tr_total{imgnum+i-startImg+1})*(Tc\[X;Y;Z;1]);
            Pos1 = (Tr_total{imgnum+i-startImg+1})*(Tc\[X1;Y1;Z1;1]);
            
            
            Pos2 = Tc2\((Tr_total{imgnum-startImg+1})\Pos);
            pos2 = round(KK*Pos2(1:3)/Pos2(3));
            
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 255;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 0;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
            
            
            
            Pos2 = Tc2\((Tr_total{imgnum-startImg+1})\Pos1);
            pos2 = round(KK*Pos2(1:3)/Pos2(3));
            
            
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
