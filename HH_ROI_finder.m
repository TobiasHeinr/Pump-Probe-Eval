function [ROI,xpos] = HH_ROI_finder(image,n,threshold,noiseLevel,addPixel)
    %define ROI for n harmonic orders
    %data format
    %image 2D array
    %n number of harmonics
    %thershold 1D array length=n (0.01 =1% of max included in harmonic signal)
    %min_int = noise level in counts
    %add pixel artificially enlarge the high intensity region to extract
    %weak harmonics
    
    hh=zeros(size(image));                                                  %total harmonic ROI to substract
    xpos=zeros(n,1);
    ROI=zeros(n,size(image,1),size(image,2));                               %ROI(harmonics,image)
    kk=1;
    while kk <= n
        minimum=max(max(image))*threshold(kk);                              %minimal intensity of harmonics that can be detected (tails of intense harmonic < minimum left out)
        while minimum < max(max(image))  && kk <= n
            [tmp,image,xpos(kk)]=findHH(image,threshold(kk),noiseLevel);            %find harmonic with highest intensity
            ROI(kk,:,:)=tmp;                                
            kk=kk+1;
            hh=hh+tmp;
        end  
        hh=logical(hh);
        xq=repmat(linspace(1,size(image,2),size(image,2)),size(image,1),1);
        upper=max(max(xq(hh)));                                             %define boundaries of high intensity region
        lower=min(min(xq(hh)));                 
        if lower <= addPixel
            lower=1+addPixel;
        end    
        if upper > size(image,2)-addPixel
            upper=size(image,2)-addPixel;
        end 
        image(:,lower-addPixel:upper+addPixel)=0;                           %substract high intensity region to make low intensity harmonic excessible
    end
end