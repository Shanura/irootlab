%>@ingroup ioio
%>@file
%>@brief Wraps over mYm to recover from the "MySQL server has gone away" error
function r = irquery(varargin)
try
    r = mym(varargin{:});
catch ME
    if any(strfind(ME.message, 'gone away')) || any(strfind(ME.message, 'ost connection')) || any(strfind(ME.message, 'ot connected'))
        assert_connected_to_cells();
        r = mym(varargin{:}); % tries again
    else
        rethrow(ME);
    end;
end;
