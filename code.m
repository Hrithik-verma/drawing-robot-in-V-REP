clearvars;
sim=remApi('remoteApi');
sim.simxFinish(-1);
clientID=sim.simxStart('127.0.0.1',19999,true,true,5000,5);
if (clientID>-1)
       disp('Connected to remote API server');
       [~,dum]= sim.simxGetObjectHandle(clientID,'IRB140_target',sim.simx_opmode_blocking);
        RGB = imread('doremon.jpg');                                                            %image input to convert to binay image 
        I = rgb2hsv(RGB);     %input image is rgb formate 
                              %if you are inputing binary or grayscale image
                              %please use any other image input method
        
        
% Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.022;
    channel1Max = 0.008;

% Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.000;
    channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
    channel3Min = 0.000;
    channel3Max = 0.657;

% Create mask based on chosen histogram thresholds
    sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
    BW = sliderBW;                                                                  %from input to till here its just convert to bnary image      
                                                                                    %this part of code can be change according to input image to get correct binary image 
    
    %flip is use to adjust how image will be drawn by  robot arm                                                                                
    %BW = flip(BW ,2);                                                                      
    BW = flip(BW ,1);
    BW = imrotate(BW,-90); %adjust how drawing looks in Vrep camera 
    figure(1)
    imshow(BW)

    id =im2double(BW);
    ibw =BW;
    [a,b]= size(ibw);
    ibw_white =1-ibw;

    [B,L] = bwboundaries(ibw_white,8,'holes');

    figure(2)
    imshow(ibw_white);
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
    end
    
    %this part of code make the motion trajectory of robot arm 
    x= [];
    y= [];
    z= [];
    count =0;
    
    for k = 1:length(B)
        boundary =B{k};
        for i=1:length(boundary(:,2))
            count = count+1;
            x(count) = boundary(i,2);
            y(count) = boundary(i,1);
            z(count) = 0;
        end
        count = count -1;
        z(count)= 30;
    end
    for m= 1:length(x)
    [returnCode]=sim.simxSetObjectPosition(clientID,dum,-1,[-0.22+(x(m)*0.0008),-0.1+(y(m)*0.0008),(z(m)*0.004)+0.515],sim.simx_opmode_blocking);
    end
    [returnCode]=sim.simxSetObjectPosition(clientID,dum,-1,[-0.4,-0.45,0.625],sim.simx_opmode_blocking); %just to move robot arm away from drawing area
end
sim.simxFinish(-1);
sim.delete();