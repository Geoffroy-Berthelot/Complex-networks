%CLEAN_ script that handles all chunks of the program-------------

%rmpath('package'); %for some reason, it will throw a NULL.pointer.exception on Apple systems (!!!!?)
rmpath('toolboxes/MIT_Toolbox');

if(param.is_parallel)
    %Init parallel pool:
    Terminate_MultiCore_Env_2017(mPool);
end