%% ADC value liveplotting & logging.
%
% Reads ADC values from the M2 microcontroller.
% Plots the data realtime in a subplot.
% Logged into ADC_Log[time, ADC_Value] variable.
% Hit Ctrl-C to quit the program
%
% By Nick McGill [https://github.com/technick29]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Initialize program and USB port
% Close any existing open port connections
% For the first time running, comment this.
% if(exist('M2USB'))
%     fclose(M2USB);
% else
%     fclose(instrfindall);
% end

clear all
close all



%% VARIABLES
maxPoints = 20;         % Max number of data points displayed at a time.
t = 1:1:maxPoints;      % Create an evenly spaced matrix for X-axis.
ADC_Log = zeros(1,2);   % ADC data points logged here in format: [time ADC_Value]
ADC_live_plot_log = zeros(maxPoints,1); % Create an array to store ADC values.

ADC_RANGE = 2^10;   % 10-bit ADC
LOGFREQUENCY = 10;  % Log the ADC value every certain number of times.  Lower = more data points.



%% SERIAL
%----> for ***WINDOZE***
% M2USB = serial('COMX','Baudrate', 9600);
% *** Use the device manager to check where the microcontroller is plugged
% into.

%----> for ***MAC***
M2USB = serial('/dev/tty.usbmodem411','Baudrate',9600);
% *** Check where your device is by opening terminal and entering the command:
% 'ls /dev/tty.usb' and tab-completing.

fopen(M2USB);       % Open up the port to the M2 microcontroller.
flushinput(M2USB);  % Remove anything extranneous that may be in the buffer.

% Send initial packet to get first set of data from microcontroller
fwrite(M2USB,1);% Send a packet to the M2.
time = 0;       % Set the start time to 0.
i = 1;          % Set i to 1, the indexer.
tic;            % Start timer.



%% Run program forever
try
while 1
    
    %% Read in data and send confirmation packet
    m2_buffer = fgetl(M2USB);   % Load buffer
    fwrite(M2USB,1);            % Confirmation packet
    
    %% Parse microcontroller data
	% Expecting data in the form: [uint ADC1]
    m2_ADC = hex2dec(m2_buffer(1:4));
    time = toc; % Stamp the time the value was received
    
    % Remove the oldest entry.    
    ADC_live_plot_log = circshift(ADC_live_plot_log,-1);
    
    % Store most recent data at the end of the array
    ADC_live_plot_log(maxPoints,:) = m2_ADC;
    
    %% Plotting
    figure(1);
    clf;
    hold on
    
    plot(t, ADC_live_plot_log(:,1),':or');
    title('ADC Value');
    xlabel('Time');
    ylabel('ADC Value (LSBs)');
    axis([0 maxPoints 0 ADC_RANGE]);
    grid on
    pause(.04);
                                   
    hold off
    
    i=i+1;  % Incrememnt indexer
    %% Logging
    if(rem(i,LOGFREQUENCY) == 0)
        ADC_Log = [ADC_Log; time m2_ADC];
    end
    
end

catch
    %Close serial object
    fclose(M2USB);
end