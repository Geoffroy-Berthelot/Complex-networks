function Terminate_MultiCore_Env_2017(mpool)

%Force closing:
%parpool close force local;
delete(mpool);

