
startImg = 1000;
labelstep = 120;
imprefix = '280N_f_right';
startlabelImg = 1000;
load data_for_david.mat

Cnt = 1;
    
    for imgnum = 1000:1120
        I = imread([imprefix num2str(imgnum,'%05d') '.png']);
        % plot points on current image
        for i = 0:1:labelstep
            Pos2 = allLeftLane{Cnt}(i+1);
            pos2 = round(KK*Pos2(1:3)/Pos2(3));
            
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 255;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 0;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;

            Pos2 = allLeftLane{Cnt}(i+1);
            
            pos2 = round(KK*Pos2(1:3)/Pos2(3));
            
            
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 1) = 0;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 2) = 255;
            I(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3, 3) = 0;
            
        end
        
        
        imshow(I);
        drawnow;
        Cnt = Cnt+1;
    end


