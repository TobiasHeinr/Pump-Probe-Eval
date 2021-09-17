function [XposS,YposS,XposR,YposR] = FindPeakHH(Image,boarder,harmonicSize)
%This function calculates local maxima that correspont to signal and
%reference Harmonics
%Image : image
%boarder : routh bourder between signal and reference
%NumSig : number of signal harmonics
%NumReg : Number of reference harmonics
%harmonicSize : (1) Largest Signal harmonic radius (~16 pixel)
%               (2) Signal harmonic scaling (~0.95)
%               (3) Largest referense harmonic radius (in spectral dimentsion, ~ 16 pixel)
%               (4) Signal harmonic Scaling (~0.95)

% sort in signal and reference part of the image
ref_Image=Image(:,1:boarder-1);
sig_Image=Image(:,boarder:size(Image,2));

%SIGNAL PEAKS

%calculate Specrtrum
Spectrum=squeeze(sum(sig_Image,2));

pks=islocalmax(Spectrum); %Peaks (local maxima, potentially HH peak)
dps=islocalmin(Spectrum); %Dips 

xposition=linspace(1,size(Spectrum,1),size(Spectrum,1))';
pksOnly=pks.*xposition;
pksOnly=pksOnly(pksOnly>0); %peak x positions

%itterate over all potential HH peaks
for ii=1:size(pksOnly,1)
    
    tmp=pksOnly(size(pksOnly,1)-ii+1,1); %Xpos of peak, start with the largest harmonic
    
    distance1=dps.*xposition-repmat(tmp,size(dps,1),1); %distance to minima (right side)
    distance1(distance1<=0)=size(dps,1); %only positive distances
    min1=min(distance1);
    
    distance2=repmat(tmp,size(dps,1),1)-dps.*xposition;  %distance to minima (left side)
    distance2(distance2<=0)=size(dps,1); %only positive distances
    min2=min(distance2); 
    
    % if closes miimum is larger than harmonic size = harmonic peak found
    if min2>harmonicSize(1) && min1>harmonicSize(1)
        harmonicSize(1)=harmonicSize(1)*harmonicSize(2);
    else
        pksOnly(size(pksOnly,1)-ii+1,1)=0; % peak is disregardet
    end
end
XposS=pksOnly(pksOnly>0);
[temp,YposS]=max(sig_Image(XposS,:),[],2); %find coresponding y positions
YposS=YposS+boarder-1;


%Reference PEAKS

%calculate Specrtrum
Spectrum=squeeze(sum(ref_Image,2));

pks=islocalmax(Spectrum); %Peaks (local maxima, potentially HH peak)
dps=islocalmin(Spectrum); %Dips 

xposition=linspace(1,size(Spectrum,1),size(Spectrum,1))';
pksOnly=pks.*xposition;
pksOnly=pksOnly(pksOnly>0); %peak x positions

%itterate over all potential HH peaks
for ii=1:size(pksOnly,1)
    
    tmp=pksOnly(ii,1); %Xpos of peak, start with the largest harmonic
    
    distance1=dps.*xposition-repmat(tmp,size(dps,1),1); %distance to minima (right side)
    distance1(distance1<=0)=size(dps,1); %only positive distances
    min1=min(distance1);
    
    distance2=repmat(tmp,size(dps,1),1)-dps.*xposition;  %distance to minima (left side)
    distance2(distance2<=0)=size(dps,1); %only positive distances
    min2=min(distance2); 
    
    % if closes miimum is larger than harmonic size = harmonic peak found
    if min2>harmonicSize(3) && min1>harmonicSize(3)
        harmonicSize(3)=harmonicSize(3)*harmonicSize(4);
    else
        pksOnly(ii,1)=0; % peak is disregardet
    end
end
XposR=pksOnly(pksOnly>0);
[temp,YposR]=max(ref_Image(XposR,:),[],2); %find coresponding y positions



end