function [harmonics,new_image,xpos] = findHH(image,threshold,min_int)
    %find most intense spot/harmonic
    %data format
    %image 2D array
    %thershold double (0.01 =1% of max included in harmonic signal)
    %min_int = noise level
    
    new_image=image;
    harmonics=zeros(size(image));
    image(image < min_int)=0;                                               %set noise to 0
    maximum=max(max(image));
    tmp=image==maximum;
    [coll,row] =find(tmp);                                                  %find maximum position
    xpos=row;
    image(image < maximum*threshold)=0;                                     %define contour of the harmonic via the threshold
    
    %starting at the maximum find all pixel within the contour:
    canidates(1,:)=[row;coll];                                              %pixel with not checked neighbours
    HH(1,:)=[row;coll];                                                     %ROI list of coordinates
    m=2;
    n=2;
    xtest=[-1,-1,-1,0,0,1,1,1];
    ytest=[-1,0,1,-1,1,-1,0,1];
    while size(canidates,1)>0 
        element=int16(rand.*(size(canidates,1)-1))+1;                       %random canidate checked       
        for kk=1:8                                                          %8 neighbours
            qx= xtest(kk)+canidates(element,1);
            qy= ytest(kk)+canidates(element,2);
            if qy<=size(image,1) && qx<=size(image,2)&&qx>0 && qy >0        %check out of bounce 
                if image(qy,qx)>0                                           %check if contour reached
                    I = sum(HH(:, 1) == qx & HH(:, 2) == qy);               %check if not in the list
                    if I==0
                        HH(n,:) =[qx,qy];
                        canidates(m,:)=[qx,qy];
                        m=m+1;
                        n=n+1;
                    end    
                end  
            end
        end
        canidates(element,:)=[];
        m=m-1;
    end
    
    for kk=1:size(HH,1)                                                     %transform to logical array
        harmonics(HH(kk,2),HH(kk,1))=1;
    end
    
    harmonics=logical(harmonics); %logical array with ROI for the harmonic
    new_image(harmonics)=0; %original image with 0 at position of harmonic
end



