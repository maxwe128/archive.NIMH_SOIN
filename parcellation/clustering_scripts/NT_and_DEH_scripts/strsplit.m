function result = strsplit(in_string, delimiter)
%Splits a string into a cell array of strings by the
% delimiter specified
%
%	result = strsplit(in_string, delimiter)
%
%Nicholas Turner, 2013 - because our current version of matlab is too old

	result = {};

	while 1

		next_index = find(in_string == delimiter, 1);

		%Either no occurrences, or only the last segment remains
		if isempty(next_index)
			
			result = [result in_string];
			break

		else

			% Taking the values up until the next occurrence
			result = [result in_string(1:(next_index-1))];
			% Trimming the string to be the values after the next
			% occurrence
			in_string = in_string((next_index+1):end);

		end

	end
end