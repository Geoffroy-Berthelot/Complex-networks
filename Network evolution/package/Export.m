function Export(R)
%dump result to disk in results/ path.

destination = 'results/'; %destination folder
%The date string is included (format ISO 8601) along with strategy and
%topology:
filename = sprintf('results-%s-S%s-%s.mat', datestr(now, 30), string(R{1}.strategy), R{1}.Topology);
fprintf(1,'Serializing results...');
R_ser = serialize(R); %Then serialize it (if previously serialized).
fprintf(1,'done.\nDumping results to folder...');
savefast(strcat(destination, filename), 'R_ser'); %save it using the savefast package.
fprintf(1,'done.\n');

%or use:
%save(file_name, 'R','-v7.3');
%for a much slower saving.


