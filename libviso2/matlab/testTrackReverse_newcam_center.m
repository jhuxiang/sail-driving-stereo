load  Tr_280S_5_16_2013_c_right.mat
labelstep = 150; % that's 1 label every 4 seconds
totalImg = length(Tr_total);

f     = 2271.3;
cu    = 622.0338;
cv    = 419.4885;
height = 1.106;
pitch  = 0.036;
KK = [f 0 cu; 0 f cv; 0 0 1]; % homogenous camera matrix
Tc = [1 0 0 0; 0 cos(pitch) -sin(pitch) -height; 0 sin(pitch) cos(pitch) 0; 0 0 0 1];
p2 = 0.005;
Tc2 = [1 0 0 0; 0 cos(p2) -sin(p2) 0; 0 sin(p2) cos(p2) 0; 0 0 0 1];


img_dir = '/home/twangcat/Desktop/stereo/data_5_16_2013/imgs/c/';
startImg = 1;

imprefix = '280S_c_right';

startlabelImg = 6000;
% I = imread([img_dir imprefix num2str(startlabelImg,'%05d') '.png']);
% imshow(I);  

for labelImg = (startlabelImg+labelstep):labelstep:totalImg
    
    

    I =imread([img_dir imprefix num2str(labelImg,'%05d') '.png']);
    
    %imshow(I);
    
    
    for imgnum = (labelImg-labelstep):labelImg
        

        I = imread([img_dir imprefix num2str(imgnum,'%05d') '.png']);
           
        % plot points on current image
        for i = 0:1:labelstep      
            x =622;
            y = size(I,1)-20;
            
%             Zc = f*height/cos(pitch)/(y-cv-f*tan(pitch));
%             Yc = (height+sin(pitch)*Zc)/cos(pitch);
%             Z = sin(pitch)*Yc + cos(pitch)*Zc;
%             X = Zc*(x-cu)/f;
%             Y=0;
%             Z = ((y-cv)*sin(pitch)*height+f*cos(pitch)*height)/(cos(pitch)*(y-cv)-f*sin(pitch));
%             X = (cos(pitch)*Z-sin(pitch)*height)*(x-cu)/f;
%             Y=0;
            Y=0;X=0;Z=1;
            
            
            % position in world frame
            Pos = (Tr_total{imgnum+i-startImg+1})*(Tc\[X;Y;Z;1]);
            
            
            Pos2 = Tc2\((Tr_total{imgnum-startImg+1})\Pos);
            pos2 = round(KK*Pos2(1:3)/Pos2(3));
            
            if pos2(1)>=4 && pos2(1)<size(I,2)-3 && pos2(2)>=4 && pos2(2)<size(I,1)-3
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 255;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 0;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
            end
            
            
            
            
        end
        
        I = imresize(I,0.5);
        imshow(I);
        drawnow;
    end
    %imwrite(I, 'reverse_viso8.png');
end
