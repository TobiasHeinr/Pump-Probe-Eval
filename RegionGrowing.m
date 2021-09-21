function [SegmentLabel] = RegionGrowing(Xpos,Ypos,Image,threshold)
%This function performs region growing on an image for multiple starting
%postions
%
%Xpos : x position starting point for region, integer
%Ypos : y position starting point for region, integer
%Image : input image(x,y)
%threshold : cutoff intensity eg 1% of max =0.01
%
%The regions are itteratively grown starting from the highest intensity.
%The Neighbours of the pixel with the highest intensity are allocated to the region of the center pixel.
%This is repeated such that all pixels are asigned.
%The growing stops at 0 pixel intensity.


numGrowPixel=size(Xpos,1); %Number of Pixel to investigate Neighbours
SegmentIntensity=zeros(size(Image)); %Intensity (=0 default, =Image for pixels to investigate)
SegmentLabel=zeros(size(Image)); %Labeled segments
SegmentLabel2=1-SegmentLabel;

%set start points of segments
for ii=1:size(Xpos)
    SegmentIntensity(Xpos(ii),Ypos(ii))=Image(Xpos(ii),Ypos(ii));
    SegmentLabel(Xpos(ii),Ypos(ii))=ii;
    maximum(ii)=Image(Xpos(ii),Ypos(ii));
end

%start region growing until no more pixel to investigate
while numGrowPixel>0
    
    %find max intensity pixel to investigate, coordinates (xval,yval) 
    [temp,xtemp]=max(SegmentIntensity,[],1);
    [temp,yval]=max(temp,[],2);
    xval=xtemp(yval);
    
    %nearest neighbours
    xn = repmat(xval,4,1) + ([0; 1; 0; -1]); 
    yn = repmat(yval,4,1) + ([1; 0; -1; 0]);
    
    % itterate all nieghbours
    for jj=1:4
        
        % checkt if inside the image && intensity > 0 (above threshold & not segmented)
        if logical(xn(jj)>=1) && logical(yn(jj)>=1) && logical(xn(jj)<=size(Image,1)) && logical(yn(jj)<=size(Image,2)) && logical(Image(xn(jj),yn(jj)) >0)      
            SegmentIntensity(xn(jj),yn(jj))=Image(xn(jj),yn(jj)); %set Intensity =/ 0 for pixels to investigate
            numGrowPixel=numGrowPixel+1; %increase number of pixels to investigate 
            SegmentLabel(xn(jj),yn(jj))=SegmentLabel(xval,yval); %set label of segment
            if Image(xn(jj),yn(jj))<maximum(1,int16(SegmentLabel(xval,yval)))*threshold    
                SegmentLabel2(xn(jj),yn(jj))=0; 
            end    
        end
    end
    
    % substract current pixel from the pixels to investigate
    numGrowPixel=numGrowPixel-1;
    SegmentIntensity(xval,yval)=0;
    
    Image(xval,yval)=0; % outside of the threshold, this pixel will not be addet again 
    
end
SegmentLabel=SegmentLabel.*SegmentLabel2;
end
