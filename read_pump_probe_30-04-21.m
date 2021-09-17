clear all

%Log File in the same folder
Basefilename = "PumpProbeScan_night3"	%-----------------------
%Data % Darkimage in this folder
DataFolder="data";	%-----------------------
[numRep, numDelay] =read_log_file(strcat('LOG_',Basefilename));
temp=importdata('temp_PPLOG_clean');
LOGdata=temp(1:numDelay,:);
%correct number of repetitions                         
%numRep=100;     %-----------------------
save('dalays_scan.mat','LOGdata')
%%
%define Dark images
%numDark=10; %-----------------------

% for ii=1:numDark
%     Darkfile=strcat('dark',num2str(ii),'-55msec.spe');  %-----------------------
%     temp=(readspe_LightField(strcat(DataFolder,'\',Darkfile)));
%     Dark=temp.data./numDark;
% end

%ONE Dark image
numDark=1; %-----------------------
Darkfile=strcat('dark45msec.spe');  %-----------------------
temp=(readspe_LightField(strcat(DataFolder,'\',Darkfile)));
Dark=temp.data/numDark;


%individual treatment of every frame (false =averaging)
%usefull for low nuber of frames as the 1st image is alway different
individual=true;    %-----------------------
individual=false;    %-----------------------

%%
%define HH ROI positions

for ii=1:numRep
    filename=strcat(DataFolder,'\',Basefilename,'_pos',num2str(LOGdata(1,1),'%.4f'),'_ON_',num2str(ii-1),'_',num2str(LOGdata(1,2)),'msec.spe');
   	temp_Image(ii,:,:)=sum(LoadImage(filename,Dark,individual),3);
end
temp_Image2(ii,:,:,:)=LoadImage(filename,Dark,individual);
temp2_Image=squeeze(sum(temp_Image,1)./(size(temp_Image,1)*size(temp_Image2,4)));
temp3_Image=imgaussfilt(temp2_Image,4); %select sigma %-----------------------

MinPos=islocalmin(sum(temp3_Image,2)).*linspace(1,size(temp3_Image,1),size(temp3_Image,1))';
boarder=sum(MinPos(int16(size(MinPos,1)*0.1):int16(size(MinPos,1)*0.9),1))
ref_Image=temp2_Image(1:boarder-1,:);
sig_Image=temp2_Image(boarder:size(temp2_Image,1),:);
figure(11)
imagesc(sig_Image)
figure(12)
imagesc(ref_Image)
%%

number_of_HH=12;     %-----------------------
number_of_ref=8;    %-----------------------
precission=ones(1,number_of_HH).*0.0305;  %select precission %-----------------------
precission=ones(1,number_of_HH).*0.0105;  %select precission %-----------------------

[ROI,xpos]=HH_ROI_finder(sig_Image,number_of_HH,precission,30,1); %select noise, add pixel %-----------------------
for i=1:size(ROI,1)
    ROI(i,:,:)=imgaussfilt(ROI(i,:,:),1.5);  %select sigma %-----------------------
    ROI(i,:,:)=ROI(i,:,:)>0;
end

figure(3)
imagesc(squeeze(sum(ROI,1)));%.*sig_Image)
[xpos,ROI_sig]=sort_PP_data(xpos,ROI);

precission=ones(1,number_of_ref).*0.012; %select precission %-----------------------
[ROI,xpos]=HH_ROI_finder(ref_Image,number_of_ref,precission,41,3);  %select noise, add pixel %-----------------------
for i=1:size(ROI,1)
    ROI(i,:,:)=imgaussfilt(ROI(i,:,:),1.5);  %select sigma %-----------------------
    ROI(i,:,:)=ROI(i,:,:)>0;
end
figure(4)
imagesc(squeeze(sum(ROI,1)));%.*ref_Image)
[xpos,ROI_ref]=sort_PP_data(xpos,ROI);

%%

for jj=1:numDelay
    for ii=1:numRep
        filename=strcat(DataFolder,'\',Basefilename,'_pos',num2str(LOGdata(jj,1),'%.4f'),'_ON_',num2str(ii-1),'_',num2str(LOGdata(jj,2)),'msec.spe');
        data_temp= LoadImage(filename,Dark,individual);
        if size(data_temp,3) <LOGdata(jj,3)
            addData=repmat(data_temp(:,:,size(data_temp,3)),1,1,LOGdata(jj,3)-size(data_temp,3));
            data_temp=cat(3,data_temp,addData);
        end    
        ref_data=data_temp(1:boarder-1,:,:);
        sig_data=data_temp(boarder:size(temp2_Image,1),:,:);
        for kk =1:number_of_HH
            data1=sig_data.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(sig_data,3));
            sum_data1(kk,jj,ii,:)=sum(squeeze(sum(sum(data1,1),2)),4);
        end   
        for kk =1:number_of_ref
            data3=ref_data.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(ref_data,3));
            sum_data3(number_of_ref-kk+1,jj,ii,:)=sum(squeeze(sum(sum(data3,1),2)),4);
        end    
        
        filename=strcat(DataFolder,'\',Basefilename,'_pos',num2str(LOGdata(jj,1),'%.4f'),'_OFF_',num2str(ii-1),'_',num2str(LOGdata(jj,2)),'msec.spe');
        data_temp= LoadImage(filename,Dark,individual);
        if size(data_temp,3) <LOGdata(jj,3)
            addData=repmat(data_temp(:,:,size(data_temp,3)),1,1,LOGdata(jj,3)-size(data_temp,3));
            data_temp=cat(3,data_temp,addData);
        end  
        ref_data=data_temp(1:boarder-1,:,:);
        sig_data=data_temp(boarder:size(temp2_Image,1),:,:);
        for kk=1:number_of_HH
            data2=sig_data.*repmat(squeeze(ROI_sig(kk,:,:)),1,1,size(sig_data,3));
            sum_data2(kk,jj,ii,:)=sum(squeeze(sum(sum(data2,1),2)),4);
        end   
        for kk =1:number_of_ref
            data4=ref_data.*repmat(squeeze(ROI_ref(kk,:,:)),1,1,size(ref_data,3));   
            sum_data4(number_of_ref-kk+1,jj,ii,:)=sum(squeeze(sum(sum(data4,1),2)),4);
        end     
    end
    l=jj
end
save('27-04-21_data.mat','sum_data1','sum_data2','sum_data3','sum_data4')
%LOGdata(:,1) delasy [mm]
%data( pump ON/OFF  ,  Delays  ,  Rep  ,  y-Koord  ,  x-Koord(spectral)  ,  frame) 
%%
% eval_data1=reshape(sum_data1,size(sum_data1,1),size(sum_data1,2),size(sum_data1,3)*size(sum_data1,4));
% eval_data2=reshape(sum_data2,size(sum_data2,1),size(sum_data2,2),size(sum_data2,3)*size(sum_data2,4));
% eval_data3=reshape(sum_data3,size(sum_data3,1),size(sum_data3,2),size(sum_data3,3)*size(sum_data3,4));
% eval_data4=reshape(sum_data4,size(sum_data4,1),size(sum_data4,2),size(sum_data4,3)*size(sum_data4,4));
% 
% %%
% 
 T_zero=264.3073;
  %T_zero=264.24;
timing=(T_zero-LOGdata(:,1)).*6.671;
 d1=sum(sum_data1,4)./10;
 d2=sum(sum_data2,4)./10;
 d3=sum(sum_data3,4)./10;
 d4=sum(sum_data4,4)./10;
 figure(271)
 plot(LOGdata(:,1),squeeze(sum((d1(4,:,:)./d2(4,:,:)),3)),'.')
 figure(472)
 plot(timing,squeeze(sum((d1(4,:,:))./(d2(4,:,:)),3))./(squeeze(sum((d3(3,:,:))./(d4(3,:,:)),3))),'.')
 figure(373)
 plot(LOGdata(:,1),squeeze(sum((d2(4,:,:))./(d4(4,:,:)),3)),'.')
 
 
 x=timing;
 y=(squeeze(sum((d1(5,:,:))./(d2(5,:,:)),3))./(squeeze(sum((d3(4,:,:))./(d4(4,:,:)),3))))';
  %y=y+(squeeze(sum((d1(3,:,:))./(d2(3,:,:)),3))./(squeeze(sum((d3(4,:,:))./(d4(4,:,:)),3))))';
  %y=y+(squeeze(sum((d1(4,:,:))./(d2(4,:,:)),3))./(squeeze(sum((d3(5,:,:))./(d4(4,:,:)),3))))';
 [x2,y2]=sort_PP_data(x,y);
 figure(99)
 plot(x2,y2)
 
 %x2=binning_data(x2,5);
 %y2=binning_data(y2,5);
  figure(999)
  
  

myfittype = fittype('c+a*exp(-x*b)',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b','c'});
f = fit(x2(10:53),y2(10:53),myfittype,'StartPoint',[-1 0.7 -0.1]);


y2_fit=f.a.*exp(-x2.*f.b)+f.c;
  
  
 %y2=y2-y2_fit; 
  
 plot(x2,y2)

 %%
 L=43;
 Fs=2.0000e+13;
 Y=fft(y2(10:53));
 P2 = abs(Y/L);
 P1 = P2(1:L/2+1);
 P1(2:end-1) = 2*P1(2:end-1);
 f = Fs*(0:(L/2))/L;
 figure(10)
 plot(f,P1)
 
 
 
 
 
 
 
 
 %%
 test=squeeze(sum((d2(3,:,:))./(d4(3,:,:)),3));
 test=sum(d2(3,:,:),3);
 avg=sum(test)/75;
 stdv=sqrt(sum((test-repmat(avg,1,75)).^2))/avg/75
 
 
 %%
% 
% A=d1(3,:,:)./d2(3,:,:);
% B=d3(4,:,:)./d4(4,:,:);
% figure(371)
% plot(LOGdata(:,1),squeeze(sum((A-B)./(A+B),3))/6,'.')
% %A=(A+d1(5,:,:)./d2(5,:,:))/2;
% %B=(B+d3(6,:,:)./d4(6,:,:))/2;
% hold on
% plot(LOGdata(:,1),squeeze(sum((A-B)./(A+B),3))/6,'.')
% hold off
% C=squeeze(sum((A-B)./(A+B),3))/size(A,3);
% 
% 
% %C(C<-1*10^-4)=0.00016;
% T_zero=264.3073;
% timing=(T_zero-LOGdata(:,1)).*6.671;
% figure(673)
% semilogx(timing,C,'*')
% [sorted_delays,sorted_data] = sort_PP_data(squeeze(timing),C');
% sorted_data_2=binning_data(sorted_data,2);
% % 
% % sum(sorted_data(1:18))/18;
% % sum(sorted_data(19:40))/22;
% % sum(sorted_data(41:63))/23;
% 
% 
% 
% %testing(1)=sum(sorted_data(1:9))/9;
% %testing(2)=sum(sorted_data(10:18))/9;
% % testing(3)=sum(sorted_data(19:30))/12;
% % testing(4)=sum(sorted_data(31:41))/11;
% % testing(5)=sum(sorted_data(42:52))/11;
% % testing(6)=sum(sorted_data(53:63))/11;
% % testing_delay(1)=sum(sorted_delays(1:9))/9;
% % testing_delay(2)=sum(sorted_delays(10:18))/9;
% % testing_delay(3)=sum(sorted_delays(19:30))/12;
% % testing_delay(4)=sum(sorted_delays(31:41))/11;
% % testing_delay(5)=sum(sorted_delays(42:52))/11;
% % testing_delay(6)=sum(sorted_delays(53:63))/11;
% 
% %plot(squeeze(d1(6,4,:)))
% %hold on
% %plot(squeeze(d2(6,4,:)))
% %hold off
% %plot(squeeze(d2(3,4,:)))
% %plot(squeeze(d4(4,4,:)))
% 
% % hold on
% % plot(testing_delay,testing,'r')
% % hold off
% ylabel('Relative transmission \DeltaT/T')
% xlabel('Pump-probe delay [ps]')
% title('27th harmonic ')
% %%
% 
% sum_data1_shift=sum_data1(1:size(sum_data3,1),:,:,:);
% sum_data2_shift=sum_data2(1:size(sum_data4,1),:,:,:);
% sum_data3_shift=circshift(sum_data3,-1,4);
% sum_data4_shift=circshift(sum_data4,-1,4);
% 
% relative1=sum(sum_data1_shift./sum_data3_shift,4)./20;
% relative2=sum(sum_data2_shift./sum_data4_shift,4)./20;
% 
% 
% figure(61)
% plot(LOGdata(:,1),squeeze(sum((relative1(5,:,:)./relative2(5,:,:)),3))./24,'.')
% 
% %%
% sum(squeeze(sum((d1(4,:,:)./d3(5,:,:))./(d2(4,:,:)./d4(5,:,:)),3))./25)/60
% sum(squeeze(sum((d1(4,:,:))./(d2(4,:,:)),3))./25)/60
% 
% %%
% data_temp=sum(sum(data,4),6);
% ratio=squeeze(sum(2*(data_temp(1,:,:,:,:)-data_temp(2,:,:,:,:))./(data_temp(1,:,:,:,:)+data_temp(2,:,:,:,:)),3)./size(data_temp,3));
%     plot(LOGdata(:,1),squeeze(sum(ratio,2)./904),'.')
% 
% 
