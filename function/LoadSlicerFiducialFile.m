function [positions, IDs] = LoadSlicerFiducialFile( filename )

fid = fopen(filename, 'rt');
if (fid < 0)
    error(sprintf('Cannot open file <%s>.', filename));
end

positions = [];
IDs = {};
count = 1;
while (~feof(fid))
    lineText = fgetl(fid);
    if (lineText(1) ~= '#')
        comma = strfind(lineText, ',');
        IDs{count,1} = lineText(1:comma(1)-1);
        textNum = size(lineText);
        positions(count,:) = sscanf(lineText(comma(1)+1:textNum(2)), '%f,%f,%f', [1, 3]);
        count = count + 1;
    end
end
fclose(fid);
