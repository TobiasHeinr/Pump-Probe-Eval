function ret = readspe(filename)
% reads WinView/WinSpec CCD files (*.spe)
% extended to header support by S. Kalbfleisch 13.12.2008
% optimized memory usage for large files, S.K. 22.03.2009


DATEMAX    = 10;      % string length of file creation date string as ddmmmyyyy\0
TIMEMAX    = 7;       % Max time store as hhmmss\0
COMMENTMAX = 80;      % User comment string max length (5 comments)
LABELMAX   = 16;      % Label string max length.
FILEVERMAX = 16;      % File version string max length.
HDRNAMEMAX = 120;     % max char str length for file name

fid = fopen(filename,'r','l');
if fid > 0
%###########################################################
% DO NOT DELETE ANY FREADS. IT WILL CRUSH THE BINARY READING
%###########################################################
    header.ControllerVersion      = fread(fid, 1,'uint16');            %    0  Hardware Version
    header.LogicOutput            = fread(fid, 1,'uint16');            %    2  Definition of Output BNC
    header.AmpHiCapLowNoise       = fread(fid, 1,'uint16');            %    4  Amp Switching Mode
    header.xDimDet                = fread(fid, 1,'uint16');            %    6  Detector x dimension of chip.
    header.mode                   = fread(fid, 1,'uint16');            %    8  timing mode
    header.exp_sec                = fread(fid, 1,'float32');           %   10  alternitive exposure, in sec.
    header.VChipXdim              = fread(fid, 1,'uint16');            %   14  Virtual Chip X dim
    header.VChipYdim              = fread(fid, 1,'uint16');            %   16  Virtual Chip Y dim
    header.yDimDet                = fread(fid, 1,'uint16');            %   18  y dimension of CCD or detector.
    temp                          = fread(fid, DATEMAX, 'uint8');      %   20  date
    header.date                   = char(temp)';                       %   20  date
    header.VirtualChipFlag        = fread(fid, 1,'uint16');            %   30  On/Off
    header.Spare_1                = fread(fid, 2, 'uint8');            %   32
    header.noscan                 = fread(fid, 1,'uint16');            %   34  Old number of scans - should always be -1
    header.DetTemperature         = fread(fid, 1,'float32');           %   36  Detector Temperature Set
    header.DetType                = fread(fid, 1,'uint16');            %   40  CCD/DiodeArray type
    header.xdim                   = fread(fid, 1,'uint16');            %   42  actual # of pixels on x axis
    header.stdiode                = fread(fid, 1,'uint16');            %   44  trigger diode
    header.DelayTime              = fread(fid, 1,'float32');           %   46  Used with Async Mode
    header.ShutterControl         = fread(fid, 1,'uint16');            %   50  Normal, Disabled Open, Disabled Closed
    header.AbsorbLive             = fread(fid, 1,'uint16');            %   52  On/Off
    header.AbsorbMode             = fread(fid, 1,'uint16');            %   54  Reference headerip or File
    header.CanDoVirtualChipFlag   = fread(fid, 1,'uint16');            %   56  T/F Cont/Chip able to do Virtual Chip
    header.ThresholdMinLive       = fread(fid, 1,'uint16');            %   58  On/Off
    header.ThresholdMinVal        = fread(fid, 1,'float32');           %   60  Threshold Minimum Value
    header.ThresholdMaxLive       = fread(fid, 1,'uint16');            %   64  On/Off
    header.ThresholdMaxVal        = fread(fid, 1,'float32');           %   66  Threshold Maximum Value
    header.SpecAutoSpectroMode    = fread(fid, 1,'uint16');            %   70  T/F Spectrograph Used
    header.SpecCenterWlNm         = fread(fid, 1,'float32');           %   72  Center Wavelength in Nm
    header.SpecGlueFlag           = fread(fid, 1,'uint16');            %   76  T/F File is Glued
    header.SpecGlueStartWlNm      = fread(fid, 1,'float32');           %   78  Starting Wavelength in Nm
    header.SpecGlueEndWlNm        = fread(fid, 1,'float32');           %   82  Starting Wavelength in Nm
    header.SpecGlueMinOvrlpNm     = fread(fid, 1,'float32');           %   86  Minimum Overlap in Nm
    header.SpecGlueFinalResNm     = fread(fid, 1,'float32');           %   90  Final Resolution in Nm
    header.PulserType             = fread(fid, 1,'uint16');            %   94  0=None, PG200=1, PTG=2, DG535=3
    header.CustomChipFlag         = fread(fid, 1,'uint16');            %   96  T/F Custom Chip Used
    header.XPrePixels             = fread(fid, 1,'uint16');            %   98  Pre Pixels in X direction
    header.XPostPixels            = fread(fid, 1,'uint16');            %  100  Post Pixels in X direction
    header.YPrePixels             = fread(fid, 1,'uint16');            %  102  Pre Pixels in Y direction
    header.YPostPixels            = fread(fid, 1,'uint16');            %  104  Post Pixels in Y direction
    header.asynen                 = fread(fid, 1,'uint16');            %  106  asynchron enable flag  0 = off
    header.datatype               = fread(fid, 1,'uint16');            %  108  experiment datatype
    %                                                                  %       0 =   FLOATING POINT
    %                                                                  %       1 =   LONG INTEGER
    %                                                                  %       2 =   INTEGER
    %                                                                  %       3 =   UNSIGNED INTEGER
    header.PulserMode             = fread(fid, 1,'uint16');            %  110  Repetitive/Sequential
    header.PulserOnChipAccums     = fread(fid, 1,'uint16');            %  112  Num PTG On-Chip Accums
    header.PulserRepeatExp        = fread(fid, 1,'uint32');            %  114  Num Exp Repeats (Pulser SW Accum)
    header.PulseRepWidth          = fread(fid, 1,'float32');           %  118  Width Value for Repetitive pulse (usec)
    header.PulseRepDelay          = fread(fid, 1,'float32');           %  122  Width Value for Repetitive pulse (usec)
    header.PulseSeqStartWidth     = fread(fid, 1,'float32');           %  126  Start Width for Sequential pulse (usec)
    header.PulseSeqEndWidth       = fread(fid, 1,'float32');           %  130  End Width for Sequential pulse (usec)
    header.PulseSeqStartDelay     = fread(fid, 1,'float32');           %  134  Start Delay for Sequential pulse (usec)
    header.PulseSeqEndDelay       = fread(fid, 1,'float32');           %  138  End Delay for Sequential pulse (usec)
    header.PulseSeqIncMode        = fread(fid, 1,'uint16');            %  142  Increments: 1=Fixed, 2=Exponential
    header.PImaxUsed              = fread(fid, 1,'uint16');            %  144  PI-Max type controller flag
    header.PImaxMode              = fread(fid, 1,'uint16');            %  146  PI-Max mode
    header.PImaxGain              = fread(fid, 1,'uint16');            %  148  PI-Max Gain
    header.BackGrndApplied        = fread(fid, 1,'uint16');            %  150  1 if background subtraction done
    header.PImax2nsBrdUsed        = fread(fid, 1,'uint16');            %  152  T/F PI-Max 2ns Board Used
    header.minblk                 = fread(fid, 1,'uint16');            %  154  min. # of strips per skips
    header.numminblk              = fread(fid, 1,'uint16');            %  156  # of min-blocks before geo skps
    header.SpecMirrorLocation     = fread(fid, 2,'uint16');            %  158  Spectro Mirror Location, 0=Not Present
    header.SpecSlitLocation       = fread(fid, 4,'uint16');            %  162  Spectro Slit Location, 0=Not Present
    header.CustomTimingFlag       = fread(fid, 1,'uint16');            %  170  T/F Custom Timing Used
    temp                          = fread(fid, TIMEMAX,'uint8');       %  172  Experiment Local Time as hhmmss\0
    header.ExperimentTimeLocal    = char(temp)';                       %  172  Experiment Local Time as hhmmss\0
    temp                          = fread(fid, TIMEMAX,'uint8');       %  179  Experiment UTC Time as hhmmss\0
    header.ExperimentTimeUTC      = char(temp)';                       %  179  Experiment UTC Time as hhmmss\0
    header.ExposUnits             = fread(fid, 1,'uint16');            %  186  User Units for Exposure
    header.ADCoffset              = fread(fid, 1,'uint16');            %  188  ADC offset
    header.ADCrate                = fread(fid, 1,'uint16');            %  190  ADC rate
    header.ADCtype                = fread(fid, 1,'uint16');            %  192  ADC type
    header.ADCresolution          = fread(fid, 1,'uint16');            %  194  ADC resolution
    header.ADCbitAdjust           = fread(fid, 1,'uint16');            %  196  ADC bit adjust
    header.gain                   = fread(fid, 1,'uint16');            %  198  gain
    temp                          = fread(fid, [COMMENTMAX 5],'uint8');%  200  File Comments
    header.Comments               = char(temp)';                       %  200  File Comments
    header.geometric              = fread(fid, 1,'uint16');            %  600  geometric ops: rotate 0x01, reverse 0x02, flip 0x04
    temp                          = fread(fid, LABELMAX,'uint8');      %  602  intensity display string
    header.xlabel                 = char(temp)';                       %  602  intensity display string
    header.cleans                 = fread(fid, 1,'uint16');            %  618  cleans
    header.NumSkpPerCln           = fread(fid, 1,'uint16');            %  620  number of skips per clean.
    header.SpecMirrorPos          = fread(fid, 2,'uint16');            %  622  Spectrograph Mirror Positions
    header.SpecSlitPos            = fread(fid, 4,'float32');           %  626  Spectrograph Slit Positions
    header.AutoCleansActive       = fread(fid, 1,'uint16');            %  642  T/F
    header.UseContCleansInst      = fread(fid, 1,'uint16');            %  644  T/F
    header.AbsorbStripNum         = fread(fid, 1,'uint16');            %  646  Absorbance Strip Number
    header.SpecSlitPosUnits       = fread(fid, 1,'uint16');            %  648  Spectrograph Slit Position Units
    header.SpecGrooves            = fread(fid, 1,'float32');           %  650  Spectrograph Grating Grooves
    header.srccmp                 = fread(fid, 1,'uint16');            %  654  number of source comp. diodes
    header.ydim                   = fread(fid, 1,'uint16');            %  656  y dimension of raw data.
    header.scramble               = fread(fid, 1,'uint16');            %  658  0=scrambled,1=unscrambled
    header.ContinuousCleansFlag   = fread(fid, 1,'uint16');            %  660  T/F Continuous Cleans Timing Option
    header.ExternalTriggerFlag    = fread(fid, 1,'uint16');            %  662  T/F External Trigger Timing Option
    header.lnoscan                = fread(fid, 1,'uint32');            %  664  Number of scans (Early WinX)
    header.lavgexp                = fread(fid, 1,'uint32');            %  668  Number of Accumulations
    header.ReadoutTime            = fread(fid, 1,'float32');           %  672  Experiment readout time
    header.TriggeredModeFlag      = fread(fid, 1,'uint16');            %  676  T/F Triggered Timing Option
    header.Spare_2                = fread(fid, 10,'uint8');            %  678
    temp                          = fread(fid, FILEVERMAX,'uint8');    %  688  Version of SW creating this file
    header.sw_version             = char(temp)';                       %  688  Version of SW creating this file
    header.type                   = fread(fid, 1,'uint16');            %  704  0=1000,1=new120,2=old120,3=130,
    %                                                                  %       st121=4,st138=5,dc131(PentaMax)=6,
    %                                                                  %       st133(MicroMax)=7,st135(GPIB)=8,
    %                                                                  %       VICCD=9, ST116(GPIB)=10,
    %                                                                  %       OMA3(GPIB)=11,OMA4=12
    header.flatFieldApplied       = fread(fid, 1,'uint16');            %  706  1 if flat field was applied.
    header.Spare_3                = fread(fid, 16,'uint8');            %  708
    header.kin_trig_mode          = fread(fid, 1,'uint16');            %  724  Kinetics Trigger Mode
    temp                          = fread(fid, LABELMAX,'uint8');      %  726  Data label.
    header.dlabel                 = char(temp)';                       %  726  Data label.
    header.Spare_4                = fread(fid, 436,'uint8');           %  742
    temp                          = fread(fid, HDRNAMEMAX,'uint8');    % 1178  Name of Pulser File with
    %                                                                  %       Pulse Widths/Delays (for Z-Slice)
    header.PulseFileName          = char(temp)';                       % 1178  Name of Pulser File with
    %                                                                  %       Pulse Widths/Delays (for Z-Slice)
    temp                          = fread(fid, HDRNAMEMAX,'uint8');    % 1298  Name of Absorbance File (if File Mode)
    header.AbsorbFileName         = char(temp)';                       % 1298  Name of Absorbance File (if File Mode)
    header.NumExpRepeats          = fread(fid, 1,'uint32');            % 1418  Number of Times experiment repeated
    header.NumExpAccums           = fread(fid, 1,'uint32');            % 1422  Number of Time experiment accumulated
    header.YT_Flag                = fread(fid, 1,'uint16');            % 1426  Set to 1 if this file contains YT data
    header.clkspd_us              = fread(fid, 1,'float32');           % 1428  Vert Clock Speed in micro-sec
    header.HWaccumFlag            = fread(fid, 1,'uint16');            % 1432  set to 1 if accum done by Hardware.
    header.StoreSync              = fread(fid, 1,'uint16');            % 1434  set to 1 if store sync used.
    header.BlemishApplied         = fread(fid, 1,'uint16');            % 1436  set to 1 if blemish removal applied.
    header.CosmicApplied          = fread(fid, 1,'uint16');            % 1438  set to 1 if cosmic ray removal applied
    header.CosmicType             = fread(fid, 1,'uint16');            % 1440  if cosmic ray applied, this is type.
    header.CosmicThreshold        = fread(fid, 1,'float32');           % 1442  Threshold of cosmic ray removal.
    header.NumFrames              = fread(fid, 1,'uint32');            % 1446  number of frames in file.
    header.MaxIntensity           = fread(fid, 1,'float32');           % 1450  max intensity of data (future)
    header.MinIntensity           = fread(fid, 1,'float32');           % 1454  min intensity of data (future)
    temp                          = fread(fid, LABELMAX,'uint8');      % 1458  y axis label.
    header.ylabel                 = char(temp)';                       % 1458  y axis label.
    header.ShutterType            = fread(fid, 1,'uint16');            % 1474  shutter type.
    header.shutterComp            = fread(fid, 1,'float32');           % 1476  shutter compensation time.
    header.readoutMode            = fread(fid, 1,'uint16');            % 1480  readout mode, full,kinetics, etc
    header.WindowSize             = fread(fid, 1,'uint16');            % 1482  window size for kinetics only.
    header.clkspd                 = fread(fid, 1,'uint16');            % 1484  clock speed for kinetics & frame transfer.
    header.interface_type         = fread(fid, 1,'uint16');            % 1486  computer interface
    %                                                                  %       (isa-taxi, pci, eisa, etc.)
    header.NumROIsInExperiment    = fread(fid, 1,'uint16');            % 1488  May be more than the 10 allowed in this header (if 0, assume 1)
    header.Spare_5                = fread(fid, 16,'uint8');            % 1490
    header.controllerNum          = fread(fid, 1,'uint16');            % 1506  if multiple controller system will
    %                                                                  %       have controller number data came from.
    %                                                                  %       this is a future item.
    header.SWmade                 = fread(fid, 1,'uint16');            % 1508  Which software package created this file
    header.NumROI                 = fread(fid, 1,'uint16');            % 1510  number of ROIs used. if 0 assume 1.
    if header.NumROI > 1
        error('More than one ROI is not supported yet.');
    end
    header.startx                 = fread(fid, 1,'uint16');            % ROI startx
    header.endx                   = fread(fid, 1,'uint16');            % ROI endx
    header.groupx                 = fread(fid, 1,'uint16');            % ROI groupx
    header.starty                 = fread(fid, 1,'uint16');            % ROI starty
    header.endy                   = fread(fid, 1,'uint16');            % ROI endy
    header.groupy                 = fread(fid, 1,'uint16');            % ROI groupy
    fseek(fid,1632,'bof');;
    temp                          = fread(fid, HDRNAMEMAX,'uint8');    % 1632  Flat field file name.
    header.FlatField              = char(temp)';                       % 1632  Flat field file name.
    temp                          = fread(fid, HDRNAMEMAX,'uint8');    % 1752  background sub. file name.
    header.background             = char(temp)';                       % 1752  background sub. file name.
    temp                          = fread(fid, HDRNAMEMAX,'uint8');    % 1872  blemish file name.
    header.blemish                = char(temp)';                       % 1872  blemish file name.
    header.file_header_ver        = fread(fid, 1,'float32');           % 1992  version of this file header
    header.YT_Info                = fread(fid, 1000,'uint8');          % 1996 -> 2996  Reserved for YT information
    header.WinView_id             = fread(fid, 1,'uint32');            % 2996  == 0x01234567 if in use by WinView
    % not implemented yet                                              % 3000 -> 3488  X axis calibration
    % not implemented yet                                              % 3489 -> 3977  Y axis calibration
    % not implemented yet                                              % 3978 -> 4097
    fseek(fid, 4098, 'bof');
    header.lastvalue              = fread(fid, 1,'uint8');             % 4098 Always the LAST value in the header
    % 4100 Bytes Total Header Size
    
    % goto data
    fseek(fid, 4100, 'bof');
    switch header.datatype
        case 0	% FLOATING POINT (4 bytes / 32 bits)
            ret.data = double(reshape(fread(fid,inf,'float32=>float32'), header.xdim, header.ydim, header.NumFrames));
        case 1	% LONG INTEGER (4 bytes / 32 bits)
            ret.data = double(reshape(fread(fid,inf,'int32=>int32'), header.xdim, header.ydim, header.NumFrames));
        case 2	% INTEGER (2 bytes / 16 bits)
            ret.data = double(reshape(fread(fid,inf,'int16=>int16'), header.xdim, header.ydim, header.NumFrames));
        case 3	% UNSIGNED INTEGER (2 bytes / 16 bits)
            max_ind=header.xdim*header.ydim*header.NumFrames;
            tmp=fread(fid,inf,'uint16=>uint16');
            ret.data = double(reshape(tmp(1:max_ind), header.xdim, header.ydim, header.NumFrames));
    end
    fclose(fid);
    
    %permute the X and Y dimensions so that an image looks like in Winview
    ret.data = permute(ret.data,[2,1,3]);
    
    % add header to ret structure
    ret.header=header;
else
    disp(['File not found - ' filename]);
    a = -1;
end%if

end
