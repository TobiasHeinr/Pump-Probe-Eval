function [Image_Data] = LoadImage(Filename,Dark_Image,individual_dark)
    %loading and preprocessing Images
    temp=(readspe_LightField(Filename));
    data_temp=temp.data;
    if size(Dark_Image,3)==size(data_temp,3) &&individual_dark
        data_temp=data_temp-Dark_Image;
    else
        avg_Dark=sum(Dark_Image,3)./size(Dark_Image,3);
        data_temp=data_temp-repmat(avg_Dark,1,1,size(data_temp,3));
    end 
    line=sum(sum(Dark_Image,1),3);
    [intensity,position]=max(line);
    data_temp(:,position-1,:)=data_temp(:,position-2,:);
    data_temp(:,position+1,:)=data_temp(:,position+2,:);
    data_temp(:,position,:)=data_temp(:,position+2,:)./2+data_temp(:,position-2,:)./2;
    %Image_Data=data_temp-repmat(min(min(data_temp,[],1),[],2),size(data_temp,1),size(data_temp,2),1);
    Image_Data=data_temp;
end



