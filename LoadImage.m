function [Image_Data] = LoadImage(Filename,Dark_Image,individual_dark)
    %This function performes load and darkimage correction of data images
    %
    %Filename : Filename in .mat format
    %Dark_Image : 2D or 3D Dark image array
    %individual_dark : for 3 D datasets individual referencing
    %
    load(Filename); %load
    Image_Data_raw=double(Dat); %convert int16 to double
    
    
    if size(Dark_Image,3)==size(Image_Data_raw,3) &&individual_dark
        Image_Data=Image_Data_raw-Dark_Image;
    else
        avg_Dark=sum(Dark_Image,3)./size(Dark_Image,3);
        Image_Data=Image_Data_raw-repmat(avg_Dark,1,1,size(Image_Data_raw,3));
    end 
end



