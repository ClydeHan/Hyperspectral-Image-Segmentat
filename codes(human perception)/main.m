%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Definition %%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
rng('default');
Screen('Preference', 'SkipSyncTests', 1);
load('RGB_SpecimCamera.mat') % Load the final resultant RGB Image

numberOfDifferentShifts = 10; % How many different shifts we will test per experiment (10)
numberOfRepetitionsPerShift = 5; % We will show the same shifted image (5) times
nBlocks = 4;  % We will run 4 different experiments
numberSet = (0:numberOfDifferentShifts-1); % Array [0 - 9]
nTrialsPerBlock = numberOfDifferentShifts * numberOfRepetitionsPerShift; % (50) trials per block in total. 

interTrialInterval = 0.25; % In Seconds

KbName('UnifyKeyNames');
Key1=KbName('LeftArrow'); Key2=KbName('RightArrow');
spaceKey = KbName('space'); escKey = KbName('ESCAPE');
corrkey = [80, 79];
gray = [127 127 127 ]; white = [ 255 255 255]; black = [ 0 0 0];
bgcolor = white; textcolor = black;

%%%%%%%%%%%%%%%%%% User Registration and File Creation %%%%%%%%%%%%%%%%%%%%
prompt = {'Experiment''s Name', 'Subject''s ID:', 'Age', 'Gender', 'Group'};
defaults = {'ConstantStimuli', '98', '18', 'F', 'Control'};
answer = inputdlg(prompt, 'NumberExp1', 2, defaults);
[output, subid, subage, gender, group] = deal(answer{:}); % all input variables are strings
outputname = [output gender subid group subage '.xls'];

if exist(outputname)==2 % Check to avoid overiding an existing file
    fileproblem = input('That file already exists! Rename (1), Overwrite (2), or Break (3/default)?');
    if isempty(fileproblem) | fileproblem==3
        return;
    elseif fileproblem==1
        outputname = ['Renamed' outputname];
    end
end
outfile = fopen(outputname,'w'); % open a file for writing data out

fprintf(outfile, 'subid\t subage\t gender\t group\t blockNumber\t trialNumber\t shiftAmount\t keypressed\t perceivedAsDifferent\t ReactionTime\t \n');

%%%%%%%%%%%%%%%%%%%%% Screen Parameters Definition %%%%%%%%%%%%%%%%%%%%%%%%
[mainwin, screenrect] = Screen(0, 'OpenWindow');
Screen('FillRect', mainwin, bgcolor);
center = [screenrect(3)/2 screenrect(4)/2];
centerLeft = [screenrect(3)/3 screenrect(4)/2];
centerRight = [(screenrect(3)/3)*2 screenrect(4)/2];
Screen(mainwin, 'Flip');


%%%%%%%%%%%%%%%%%%%%%%%%%%% INSTRUCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('FillRect', mainwin ,bgcolor);
Screen('TextSize', mainwin, 24);
Screen('DrawText',mainwin,['Evaluate if two images seem equal or different.'] ,center(1)-250,center(2)-100,textcolor);
Screen('DrawText',mainwin,['Press SPACE BAR to start the experiment.'] ,center(1)-250,center(2),textcolor);
Screen('Flip',mainwin );

keyIsDown=0;
while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        elseif keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end
WaitSecs(0.3);

%%%%%%%%%%%%%%%%%%%%%% THE FOUR BLOCKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 4 Blocks:
% In Block 1, we will positively shift Chroma (50 Times -> 5 times with each shift amount)
% In Block 2, we will negatively shift Chroma (50 Times -> 5 times with each shift amount)
% In Block 3, we will positively shift Hue    (50 Times -> 5 times with each shift amount)
% In Block 4, we will negatively shift Hue    (50 Times -> 5 times with each shift amount)

for a = 1:nBlocks
    Screen('FillRect', mainwin, bgcolor);
    Screen('TextSize', mainwin, 24);
    Screen('DrawText', mainwin, ['LEFT ARROW if the images seem EQUAL.'], center(1)-250, center(2)-100, textcolor);
    Screen('DrawText', mainwin, ['RIGHT ARROW if the images seem DIFFERENT.'], center(1)-250, center(2), textcolor);

    Screen('DrawText', mainwin, ['CLICK to start block ' num2str(a) ' out of ' num2str(nBlocks) ' blocks.'], center(1)-250, center(2)+100, textcolor);
    Screen('Flip', mainwin);
    GetClicks;
    WaitSecs(1);
    
    trialorder = Shuffle(1:nTrialsPerBlock); % Randomize trial order before each block
    
    for i = 1:nTrialsPerBlock
        currentTrialDigit = numberSet(mod(trialorder(i),numberOfDifferentShifts)+1); % Randomly choose a shift amount
        
        if(a == 3) %In Block 3, we will positively shift Chroma
            s = currentTrialDigit * 2; % Each step will be +2 in Chroma
            [shifted_RGB, MEAN_CIE76, MEAN_SCIELABDeltaE] = shiftChroma(RGB,s);

        elseif(a == 4) %In Block 4, we will negatively shift Chroma
            s = currentTrialDigit * -2; % Each step will be -2 in Chroma
            [shifted_RGB, MEAN_CIE76, MEAN_SCIELABDeltaE] = shiftChroma(RGB,s);

        elseif(a == 1) %In Block 1, we will positively shift Hue
            s = currentTrialDigit * 4; % Each step will be +4 in Hue
            [shifted_RGB, MEAN_CIE76, MEAN_SCIELABDeltaE] = shiftHue(RGB,s);

        else %In Block 2, we will negatively shift Hue
            s = currentTrialDigit * -4; % Each step will be -4 in Hue
            [shifted_RGB, MEAN_CIE76, MEAN_SCIELABDeltaE] = shiftHue(RGB,s);

        end
        
        originalTexture = Screen('MakeTexture', mainwin, RGB*255);
        shiftedTexture = Screen('MakeTexture', mainwin, shifted_RGB*255);
        sizeImage = size(RGB);
        % Calculate the position of the images on the screen
        sizeImage = sizeImage./1.5; % This reduce the size of the images to fit them to small screens
        coordinatesOfLeftImage = [centerLeft(1)-(sizeImage(1)/2),centerLeft(2)-(sizeImage(2)/2),centerLeft(1)+(sizeImage(1)/2),centerLeft(2)+(sizeImage(2)/2)];
        coordinatesOfRightImage = [centerRight(1)-(sizeImage(1)/2),centerRight(2)-(sizeImage(2)/2),centerRight(1)+(sizeImage(1)/2),centerRight(2)+(sizeImage(2)/2)];

        % Show the screen to the observer
        Screen('FillRect', mainwin ,bgcolor);
        Screen('TextSize', mainwin, 24);
        Screen('DrawText', mainwin, ['             LEFT ARROW if EQUAL                       RIGHT ARROW if DIFFERENT'], center(1)-450, center(2)-250, textcolor);
        % Also, we need to swap left-right randomly to avoid bias
        if(randi(2)-1)
            Screen('DrawTexture', mainwin, originalTexture, [], coordinatesOfLeftImage);
            Screen('DrawTexture', mainwin, shiftedTexture, [], coordinatesOfRightImage);
        else
            Screen('DrawTexture', mainwin, originalTexture, [], coordinatesOfRightImage);
            Screen('DrawTexture', mainwin, shiftedTexture, [], coordinatesOfLeftImage);
        end
        Screen('Flip', mainwin); 
      
        % Now, record the user response
        timeStart = GetSecs;keyIsDown=0; correct=0; rt=0;
        while 1
                [keyIsDown, secs, keyCode] = KbCheck;
                FlushEvents('keyDown');
                if keyIsDown
                    nKeys = sum(keyCode);
                    if nKeys==1
                        if keyCode(Key1)||keyCode(Key2)
                            rt = 1000.*(GetSecs-timeStart);
                            keypressed=find(keyCode);
                            Screen('Flip', mainwin);
                            break;
                        elseif keyCode(escKey)
                            ShowCursor; fclose(outfile);  Screen('CloseAll'); return
                        end
                        keyIsDown=0; keyCode=0;
                    end
                end
         end
         if keypressed==Key1 % No perceived difference
                perceivedAsDifferent=0;
         elseif keypressed==Key2 % Perceived difference
                perceivedAsDifferent=1;
         end
        
        Screen('FillRect', mainwin ,bgcolor); Screen('Flip', mainwin);
        
        % Save data to the file
        fprintf(outfile, '%s\t %s\t %s\t %s\t %d\t %d\t %d\t %d\t %d\t %f\t \n', subid, ...,
            subage, gender, group, a, i, s, keypressed, perceivedAsDifferent, rt);
        WaitSecs(interTrialInterval);
    end
end

Screen('CloseAll');
fclose(outfile);
fprintf('\n You have completed this experiment. Thank you!');



