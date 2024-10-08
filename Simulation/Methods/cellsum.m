%function outsum = cellsum(C)
%outsum = arrayfun(@(varargin) sum(cell2mat(varargin)), C{:});
%end

function outsum = cellsum(C)
outsum = zeros(size(C{1}));
for index = 1:numel(C)
outsum = outsum + C{index};
end
end