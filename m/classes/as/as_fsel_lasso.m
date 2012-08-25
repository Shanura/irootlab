%> LASSO feature selection
classdef as_fsel_lasso < as_fsel
    properties
        %> Number of features to be selected
        nf_select;
        %> Dataset
        data;
    end;

    methods
        function o = as_fsel_lasso()
            o.classtitle = 'LASSO';
        end;
    end;
    
    
    methods
        function log = go(o)
            ds = o.data(1);
            if ds.nc > 2
                irerror('LASSO feature selection works with 2-class datasets only!');
            end;
            
            Y = ds.classes*2-1;
            L = abs(lasso(ds.X, Y, -o.nf_select, false));
            
            % Sorts in descending order of importance and trims
            coeff = abs(L);
            coeff = coeff(:)';
            [vv, ii] = sort(coeff, 'descend');
            if numel(ii) > o.nf_select
                ii = ii(1:o.nf_select);
            end;
            grades = zeros(1, ds.nf);
            grades(ii) = coeff(ii);
            
            

            log = log_as_fsel();
            log.grades = grades;
            log.fea_x = ds.fea_x;
            log.xname = ds.xname;
            log.xunit = ds.xunit;
            log.yname = 'LASSO coefficient';
            log.v = ii;
        end;
    end;
end