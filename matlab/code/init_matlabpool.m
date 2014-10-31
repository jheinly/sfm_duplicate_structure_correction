function [] = init_matlabpool(num_threads)
    
    addpath('../ParforProgMon')
    
    if matlabpool('size') ~= num_threads
        my_cluster = parcluster('local');
        my_cluster.NumWorkers = num_threads;
        saveProfile(my_cluster);

        if matlabpool('size') > 0
            matlabpool close
        end

        matlabpool('open', num_threads);

        pctRunOnAll javaaddpath ../ParforProgMon/java
    end
    
end % function
