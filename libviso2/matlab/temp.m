global C;
pause;
for i = 1:1000
    a = imshow(rand(100));
    drawnow; 
    set(gcf, 'WindowButtonMotionFcn', @mouseMove);
    %C
end

