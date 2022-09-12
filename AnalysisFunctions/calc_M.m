function M = calc_M(classify_on, actual_on)

if(all(size(classify_on) ~= size(actual_on)))
    actual_on = actual_on';
end

%Get locations of true positives and true negatives
TPs = classify_on & actual_on;
TNs = (~classify_on) & (~actual_on);

%Find indices where stimulus changes (flashes goes from on to off)
state_change = [0, find(diff(actual_on)), numel(actual_on)];

EPO_list = [];
ENO_list = [];

for i=1:numel(state_change)-1
    start_idx = state_change(i) + 1;
    end_idx = state_change(i+1);
    TP_count = 0;
    TN_count = 0;

    TP_flag = false;
    TN_flag = false;
    EOR_added_flag = false;

    for j=start_idx:end_idx
       if(TPs(j)==1)
           TP_count = TP_count + 1;
           TP_flag = true;

           if j == end_idx
               EPO_list(end+1) = TP_count/(end_idx+1-start_idx);
               EOR_added_flag = true;
               TP_flag = false;
               TP_count = 0;
           end

       else
           if TP_flag
               EPO_list(end+1) = TP_count/(end_idx+1-start_idx);
               EOR_added_flag = true;
           end
           TP_flag = false;
           TP_count = 0;
       end

       if(TNs(j)==1)
           TN_count = TN_count + 1;
           TN_flag = true;

            if j == end_idx
                ENO_list(end+1) = TN_count/(end_idx+1-start_idx);
                EOR_added_flag = true;
                TN_flag = false;
                TN_count = 0;
            end

       else
           if TN_flag
               ENO_list(end+1) = TN_count/(end_idx+1-start_idx);
               EOR_added_flag = true;
           end
           TN_flag = false;
           TN_count = 0;
       end

       if ~(EOR_added_flag) && j==end_idx
           if actual_on(j) == 1
               EPO_list(end+1) = 0;
           else
               ENO_list(end+1) = 0;
           end
       end
  
    end
end


%Take average EPO and ENO
EPO_ave = mean(EPO_list);
ENO_ave = mean(ENO_list);



%Harmonic mean
M = 2*EPO_ave*ENO_ave/(EPO_ave + ENO_ave);

end