%Script to evaluate Pump Probe Data

%Imports Log file and all images
%Segments Signal and reference harmonics to extrat their respective
%intensity.

%fillout all "%--------------------" lines

%Import LOG file
clear all
Basefilename = 'PumpProbeScan_night2';                                                      %-------------------------
Folder='2021-09-15 Pump Probe';                                                             %-------------------------
%Folder for Data/Dark image Log file.....

[numRep, numDelay] =read_log_file(strcat(Folder,'\LOG_',Basefilename));
temp=importdata('temp_PPLOG_clean');
LOGdata=temp(1:numDelay,:);

%correct number of repetitions (if stopped before completion)                         
%numRep=90;                                                                                 %-----------------------
%% Define Dark image

Darkfile='darkfile.mat';                                                                    %-----------------------
%temp=(readspe_LightField(strcat(DataFolder,'\',Darkfile)));
load(strcat(Folder,'\',Darkfile));
Dark=sum(Dat,3)./size(Dat,3);

%individual treatment of every frame (false =averaging)
%usefull for low nuber of frames as the 1st image is alway different                                      
individual=false;    %false default                                                         %-----------------------
%% Define sig and ref spectrum ROI

Image_blur=4;    %select sigma (bluring of ~4 pixel)                                        %-----------------------
boarder= 125;    %rough boarder between signal and reference                                %-----------------------
harmoniSice=([15;0.95; 14;0.95]);   %size of harmonics [15;0.95; 14;0.95]                   %-----------------------

for ii=1:numRep
    filename=strcat(Folder,'\',Basefilename,'_pos',num2str(LOGdata(1,1),'%.4f'),'_ON_',num2str(ii-1),'_',num2str(LOGdata(1,2)),'msec.mat');
   	temp=LoadImage(filename,Dark,individual);
    temp_Image(ii,:,:)=sum(temp,3)./size(temp,3);
end
Image=imgaussfilt(squeeze(sum(temp_Image,1)./size(temp_Image,1)),Image_blur);  

Data_ROI=[400;size(Image,1);1;size(Image,2)]; %Relevant Detektor Region                     %-----------------------
Image=Image(Data_ROI(1):Data_ROI(2),Data_ROI(3):Data_ROI(4));

%find peaks of the High harmonics ref&sig
[A,B,C,D]=FindPeakHH(Image,boarder,harmoniSice);
number_of_HH=size(A,1); 
number_of_ref=size(C,1);
%%
figure(11)
subplot(2,1,1);
imagesc(Image')
hold on
plot(A,B,'*')
plot(C,D,'*')
hold off
title('Harmonic Positions')
%% Region Growing at peak positions

xPositions=[A;C];
yPositions=[B;D];
[SegmentLabel] = RegionGrowing(xPositions,yPositions,Image);

%calculate ROIs for sig&ref
ROI_sig =zeros(number_of_HH,size(SegmentLabel,1),size(SegmentLabel,2));
ROI_ref =zeros(number_of_ref,size(SegmentLabel,1),size(SegmentLabel,2));
for ii=1:number_of_HH
    tmp=SegmentLabel==ii;
    ROI_sig(ii,:,:)=tmp;
end
for ii=1:number_of_ref
    tmp=SegmentLabel==ii+number_of_HH;
    ROI_ref(ii,:,:)=tmp;
end

figure(11)
subplot(2,1,2);
imagesc(SegmentLabel')
title('Segmentet ROIs')
%% Import Data (Read & ROI summation)

for jj=1:numDelay
    for ii=1:numRep     
        
        %Load Pump ON data
        filename=strcat(Folder,'\',Basefilename,'_pos',num2str(LOGdata(jj,1),'%.4f'),'_ON_',num2str(ii-1),'_',num2str(LOGdata(jj,2)),'msec.mat');
        data_temp= LoadImage(filename,Dark,individual);
        data_temp=data_temp(Data_ROI(1):Data_ROI(2),Data_ROI(3):Data_ROI(4),:); %Use correct ROI  
        
        %sum signal harmonics
        for kk =1:number_of_HH
            data1=data_temp.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(data_temp,3));
            sum_data1(kk,jj,ii,:)=sum(squeeze(sum(sum(data1,1),2)),4);
        end   
        %sum reference harmonics
        for kk =1:number_of_ref
            data3=data_temp.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(data_temp,3));
            sum_data3(number_of_ref-kk+1,jj,ii,:)=sum(squeeze(sum(sum(data3,1),2)),4);
        end    
        
        
        %Load Pump OFF data
        filename=strcat(Folder,'\',Basefilename,'_pos',num2str(LOGdata(jj,1),'%.4f'),'_OFF_',num2str(ii-1),'_',num2str(LOGdata(jj,2)),'msec.mat');
        data_temp= LoadImage(filename,Dark,individual);
        data_temp=data_temp(Data_ROI(1):Data_ROI(2),Data_ROI(3):Data_ROI(4),:); %Use correct ROI
        
        %sum signal harmonics
        for kk=1:number_of_HH
            data2=data_temp.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(data_temp,3));
            sum_data2(kk,jj,ii,:)=sum(squeeze(sum(sum(data2,1),2)),4);
        end  
        %sum reference harmonics
        for kk =1:number_of_ref
            data4=data_temp.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(data_temp,3));   
            sum_data4(number_of_ref-kk+1,jj,ii,:)=sum(squeeze(sum(sum(data4,1),2)),4);
        end     
    end
    l=jj %print number
end

%save raw signal (LOGdata(:,1) = delasy [mm], sigON, sigOff, refON, refOff)
%data( pump ON/OFF  ,  Delays  ,  Rep  ,  y-Koord  ,  x-Koord(spectral)  ,  frame) 
save(strcat(Basefilename,'_Data.mat'),'LOGdata','sum_data1','sum_data2','sum_data3','sum_data4')
%%
load(strcat(Basefilename,'_Data.mat'));

T_zero=264.28;                                                                              %-----------------------
Signal=8;                                                                                   %-----------------------
Reference=3;                                                                                %-----------------------

timing=(T_zero-LOGdata(:,1)).*6.671; %convert to ps
d1=sum(sum_data1,4)./size(sum_data1,4);
d2=sum(sum_data2,4)./size(sum_data1,4);
d3=sum(sum_data3,4)./size(sum_data1,4);
d4=sum(sum_data4,4)./size(sum_data1,4);

%plot referenced Pump probe trace
figure(31)
subplot(2,1,1);
plot(sum_data1(:,1,1,1))
title('Sig Intensity')
xlabel('Sig Nr.')
subplot(2,1,2);
plot(sum_data3(:,1,1,1))
title('Ref Intensity')
xlabel('Ref Nr.')
figure(21)
subplot(2,2,1);
plot(timing,squeeze(sum((d1(Signal,:,:)./d2(Signal,:,:)),3))./size(d2,3),'*')
title('ON/ OFF')
xlabel('Delay [ps]')
subplot(2,2,2);
plot(timing,squeeze(sum((d1(Signal,:,:)./d3(Reference,:,:)),3))./size(d2,3),'*')
title('SigON/ RefON')
xlabel('Delay [ps]')
subplot(2,2,3);
plot(timing,squeeze(sum((d1(Signal,:,:))./(d2(Signal,:,:)),3))./(squeeze(sum((d3(Reference,:,:))./(d4(Reference,:,:)),3))),'*')
title('SigON/ SigOF / ( RefON/ RefOF )')
xlabel('Delay [ps]')
subplot(2,2,4);
plot(timing,squeeze(sum(sum((sum_data1(Signal,:,:,:))./(sum_data2(Signal,:,:,:)),3)./(sum((sum_data3(Reference,:,:,:))./(sum_data4(Reference,:,:,:)),3)),4))./20,'*')
title('SigON/ SigOF / ( RefON/ RefOF ), individual')
xlabel('Delay [ps]')
