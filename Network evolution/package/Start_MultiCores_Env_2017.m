function mPool = Start_MultiCores_Env_2017(override)

%Initializing multi-cores environment if needed:
physical_ = true; %will prefer physical cores over physical cores (hyperthreading is a long debate, 
%... recommendation: stick to physical cores instead of logical ones).

[~,d] = version;
y = str2double(datestr(d,'yyyy'));
if(y > 2013)
    %the worker limits was removed in 2014 version of matlab:
    %Then the number of concurent threads is supposed to be equal to the number of cores:
    %ncores = getenv('NUMBER_OF_PROCESSORS'); for older versions.
    
    ncores = feature('numcores');    %to get the number of PHYSICAL cores
    if(physical_ && override ==0)
        nworkers = ncores;
    else
        if(override ~= 0)
            nworkers = override;
        else
            Z = evalc('feature(''numcores'')'); %to get the number of LOGICAL cores
            %ncores = ... %need to parse to get LOGICAL cores.
        end
    end
else
    try
        %version former to 2014 then the upperlimit of worker is 12.
        %(limit was 4 initially, then changed to 8 in R2009a then
        %to 12 in R2011b).
        %Please change ncores to 4 or 8 if an error occur:
        ncores = 12;
    catch ierror
        error('Please change the ''ncores'' values to the correct number regarding your matlab version. Please check ''main_package.m''');
    end
end
%Forces matlab's var 'ClusterSize' to the number of cores:
%Please see in the upper section if this line fails:
fprintf(1,'detected %d cores and will use %d workers\n', ncores, nworkers);
%WARNING: set() and parpool require javamachine (don't use -nojvm on
%command line use)
%for a local use: set(parcluster('local'), 'NumWorkers', nworkers);
%Init matlab labs:
set(parcluster('local'), 'NumWorkers', nworkers);
mPool = parpool(nworkers);

