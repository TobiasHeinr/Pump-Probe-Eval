function [sorted_delays,sorted_data] = sort_PP_data(delays,data)
    %sorting pump probe data with random delays

    %data format
    %sorted_delays,delays 1D array
    %sorted_data,data 1D-3D array (#delay,#frame,#HH)
   
    [sorted_delays, index] = sort(delays);
    sorted_data=data(index,:,:);    
end