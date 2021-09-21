%Script to evaluate Static spectra

%Substracts Darkimage from Data(e.g. TiSe2) and reference Data (e.g. Si membrane)
%fillout all "%--------------------" lines

clear all

%Folder for Data/Dark images    
Folder='Data';                                                                          %-------------------------
       
%Files
DataFile=strcat(Folder,'\TiSe2.mat');                                                   %-------------------------
ReferenceFile= strcat(Folder,'\emty.mat');                                              %-------------------------
Darkfile='dark_full.mat';                                                               %-------------------------



%temp=(readspe_LightField(strcat(DataFolder,'\',Darkfile)));
load(strcat(Folder,'\',Darkfile));
Dark=sum(Dat,3)./size(Dat,3);

%individual treatment of every frame (false =averaging)
%usefull for low nuber of frames as the 1st image is alway different                                      
individual=false;    %false default                                                     %-------------------------

%-----------------------
%% Define sig and ref spectrum ROI

Image_blur=5;    %select sigma (bluring of ~4 pixel)                                        %-----------------------
boarder= 120;    %rough boarder between signal and reference                                %-----------------------
harmoniSice=([10;0.8; 15;0.80]);   %size of harmonics [15;0.95; 14;0.95]                   %-----------------------

temp=LoadImage(ReferenceFile,Dark,individual);

Image=imgaussfilt(temp,Image_blur);  

Data_ROI=[410;size(Image,1);1;size(Image,2)]; %Relevant Detektor Region                     %-----------------------
Image=Image(Data_ROI(1):Data_ROI(2),Data_ROI(3):Data_ROI(4));

%find peaks of the High harmonics ref&sig
[A,B,C,D]=FindPeakHH(Image,boarder,harmoniSice);
number_of_HH=size(A,1); 
number_of_ref=size(C,1);

figure(11)
subplot(2,1,1);
imagesc(Image')
hold on
plot(A,B,'k*')
plot(C,D,'r*')
hold off
title('Harmonic Positions')
%% Region Growing at peak positions
start_Harmonic =14;                                                                          %-----------------------
HH=(number_of_HH+start_Harmonic-linspace(1,number_of_HH,number_of_HH)).*1.55;



xPositions=[A;C];
yPositions=[B;D];
[SegmentLabel] = RegionGrowing(xPositions,yPositions,Image,0.12);                               %-----------------------

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
%%
%Reference
data_temp= LoadImage(ReferenceFile,Dark,individual);
data_temp=data_temp(Data_ROI(1):Data_ROI(2),Data_ROI(3):Data_ROI(4),:); %Use correct ROI

%sum signal harmonics
for kk =1:number_of_HH
    data1=data_temp.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(data_temp,3));
    data1_tmp=sum(squeeze(sum(sum(data1,1),2)),4);  
    sum_data1(kk,:)=data1_tmp;
end
%sum reference harmonics
for kk =1:number_of_ref
    data3=data_temp.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(data_temp,3));
    data3_tmp=sum(squeeze(sum(sum(data3,1),2)),4);
    sum_data3(number_of_ref-kk+1,:)=data3_tmp;
end
data_final=sum(sum_data1(:,:),2);
save_empty=data_final;
save_Int_Time=Int_Time;
             
%Data
data_temp= LoadImage(DataFile,Dark,individual);
data_temp=data_temp(Data_ROI(1):Data_ROI(2),Data_ROI(3):Data_ROI(4),:); %Use correct ROI

%sum signal harmonics
for kk =1:number_of_HH
    data1=data_temp.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(data_temp,3));
    data1_tmp=sum(squeeze(sum(sum(data1,1),2)),4);  
    sum_data1(kk,:)=data1_tmp;
end
%sum reference harmonics
for kk =1:number_of_ref
    data3=data_temp.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(data_temp,3));
    data3_tmp=sum(squeeze(sum(sum(data3,1),2)),4);
    sum_data3(number_of_ref-kk+1,:)=data3_tmp;
end
data_final=sum(sum_data1(:,:),2);

%%

figure(51)
%hold on
plot(HH,data_final./Int_Time)
ylabel('Transmission')
hold on
plot(HH,save_empty./save_Int_Time)
hold off
legend('Data','Reference')
%plot(log10(abs(sum(sum_data1(:,:),2)./save)))
xlabel('Energy [eV]')
figure(52)
plot(HH,data_final./save_empty.*save_Int_Time./Int_Time)
ylabel('Rel. Transmission')
xlabel('Energy [eV]')
