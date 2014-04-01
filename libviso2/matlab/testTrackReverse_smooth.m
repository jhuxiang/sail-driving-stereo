load lane1.mat
load  Tr_280N_5_16_2013_f_right.mat

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


img_dir = '/home/twangcat/Desktop/stereo/data_5_16_2013/imgs/Nf/';
startImg = 1000;

imprefix = '280N_f_right';
%for labelImg = labelstep/2+25900:labelstep:totalImg % caused error because of poor odometry?!


startlabelImg = 1000;
    for imgnum = startlabelImg:totalImg
        
        I = imread([img_dir '/' imprefix num2str(imgnum,'%05d') '.png']);
          
        % plot points on current image
        for i = 0:1:150
            x = xall(1, imgnum+i)*2;
            y = yall(1, imgnum+i)*2;
            
            Z = ((y-cv)*sin(pitch)*height+f*cos(pitch)*height)/(cos(pitch)*(y-cv)-f*sin(pitch));
            X = (cos(pitch)*Z-sin(pitch)*height)*(x-cu)/f;
            Y=0;
            
            
%             x1 = xall(2, imgnum+i);
%             y1 = yall(2, imgnum+i);
%             Zc1 = f*height/cos(pitch)/(y1-cv-f*tan(pitch));
%             Yc1 = (height+sin(pitch)*Zc1)/cos(pitch);
%             Z1 = sin(pitch)*Yc1 + cos(pitch)*Zc1;
%             X1 = Zc1*(x1-cu)/f;
%             Y1=0;
            
            % position in world frame
            Pos = (Tr_total{imgnum+i-startImg+1})*(Tc\[X;Y;Z;1]);
            %Pos1 = (Tr_total{imgnum+i-startImg+1})*(Tc\[X1;Y1;Z1;1]);
            
            
            Pos2 = Tc2\((Tr_total{imgnum-startImg+1})\Pos);
            pos2 = round(KK*Pos2(1:3)/Pos2(3));
            
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 255;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 0;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
            
            
            
%             Pos2 = inv(Tr_total{imgnum-startImg+1})*Pos1;
%             Pos3 = inv(Tc)*Pos2;
%             pos2 = round(KK*Pos3(1:3)/Pos3(3));
%             
%             
%             I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 0;
%             I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 255;
%             I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
            
        end
        
        
        imshow(I);
        drawnow;
    end
