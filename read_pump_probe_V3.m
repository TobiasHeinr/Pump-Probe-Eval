%Script to evaluate Pump Probe Data

%Imports Log file and all images
%Segments Signal and reference harmonics to extrat their respective
%intensity.

%fillout all "%--------------------" lines

%Import LOG file
%clear all
Basefilename = 'PumpProbeScan_night';                                                      %-------------------------
Folder='Data';                                                             %-------------------------
%Folder for Data/Dark image Log file.....

[numRep, numDelay] =read_log_file(strcat(Folder,'\LOG_',Basefilename));
temp=importdata('temp_PPLOG_clean');
LOGdata=temp(1:numDelay,:);

%correct number of repetitions (if stopped before completion)                         
numRep=24;                                                                                 %-----------------------
%% Define Dark image

Darkfile='dark_80frames_1.mat';                                                                    %-----------------------
%temp=(readspe_LightField(strcat(DataFolder,'\',Darkfile)));
load(strcat(Folder,'\',Darkfile));
Dark=sum(Dat,3)./size(Dat,3);

%individual treatment of every frame (false =averaging)
%usefull for low nuber of frames as the 1st image is alway different                                      
individual=false;    %false default                                                         %-----------------------
%% Define sig and ref spectrum ROI

Image_blur=5;    %select sigma (bluring of ~4 pixel)                                        %-----------------------
boarder= 125;    %rough boarder between signal and reference                                %-----------------------
harmoniSice=([14;0.95; 14;0.95]);   %size of harmonics [15;0.95; 14;0.95]                   %-----------------------

for ii=1:numRep
    filename=strcat(Folder,'\',Basefilename,'_pos',num2str(LOGdata(1,1),'%.4f'),'_ON_',num2str(ii-1),'_',num2str(LOGdata(1,2)),'msec.mat');
   	temp=LoadImage(filename,Dark,individual);
    temp_Image(ii,:,:)=sum(temp,3)./size(temp,3);
end
Image=imgaussfilt(squeeze(sum(temp_Image,1)./size(temp_Image,1)),Image_blur);  

Data_ROI=[1;size(Image,1);1;size(Image,2)]; %Relevant Detektor Region                     %-----------------------
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
plot(A,B,'k*')
plot(C,D,'r*')
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
        alternate = repmat([0,1],1,size(data_temp,3)/2)';
        
        %sum signal harmonics
        for kk =1:number_of_HH
            data1=data_temp.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(data_temp,3));
            data1_tmp=sum(squeeze(sum(sum(data1,1),2)),4);
            data1_tmp=data1_tmp(alternate>0);
            sum_data1(kk,jj,ii,:)=data1_tmp;
        end   
        %sum reference harmonics
        for kk =1:number_of_ref
            data3=data_temp.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(data_temp,3));
            data3_tmp=sum(squeeze(sum(sum(data3,1),2)),4);
            data3_tmp=data3_tmp(alternate>0);            
            sum_data3(number_of_ref-kk+1,jj,ii,:)=data3_tmp;
        end    
        
        
        %Load Pump OFF data   
        alternate = repmat([1,0],1,size(data_temp,3)/2)';
        
        %sum signal harmonics
        for kk=1:number_of_HH
            data2=data_temp.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(data_temp,3));
            data2_tmp=sum(squeeze(sum(sum(data2,1),2)),4);
            data2_tmp=data2_tmp(alternate>0);              
            sum_data2(kk,jj,ii,:)=data2_tmp;
        end  
        %sum reference harmonics
        for kk =1:number_of_ref
            data4=data_temp.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(data_temp,3));   
            data4_tmp=sum(squeeze(sum(sum(data4,1),2)),4);
            data4_tmp=data4_tmp(alternate>0);              
            sum_data4(number_of_ref-kk+1,jj,ii,:)=data4_tmp;
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
Signal=5;                                                                                   %-----------------------
Reference=5;                                                                                %-----------------------

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
plot(timing,squeeze(sum(sum((sum_data1(Signal,:,:,:))./(sum_data2(Signal,:,:,:)),3)./(sum((sum_data3(Reference,:,:,:))./(sum_data4(Reference,:,:,:)),3)),4))./40,'*')
title('SigON/ SigOF / ( RefON/ RefOF ), individual')
xlabel('Delay [ps]')
