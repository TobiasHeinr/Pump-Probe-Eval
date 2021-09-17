function [ num_rep2 , num_delay2 ] = read_log_file( file_name )
%This function reads the pump probe Log files

%file_name  : Log file_name

%Return:
% num_rep2 : Number of repetitions
%num_delay2 : Number of delay positions

fid = fopen(file_name); %open dat file

%read lines and extract header Information
dataString=strings;
i=1;
temp=fgetl(fid);
temp=fgetl(fid);
temp=fgetl(fid);
num_rep=str2num(fgetl(fid));
temp=fgetl(fid);
num_delay=str2num(fgetl(fid));
temp=fgetl(fid);
temp=fgetl(fid);

while (length(temp)) ~= 0
    if (length(temp)) ~=0
        if temp(1) == '['
            dataString(i) = ' ';
        else
            dataString(i) = temp;
        end
    else
        dataString(i) = temp;
    end
    i=i+1;
    temp=fgetl(fid);
end
fclose(fid);

%write clean file without headers
filePh = fopen('temp_PPLOG_clean','w');
rows=size(dataString,2);
for r=1:rows
    fprintf(filePh,'%s\n',dataString(1,r));
end
fclose(filePh);
num_delay2 =num_delay;
num_rep2 = num_rep;
end

