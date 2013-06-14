%> CUSTOM
classdef goer_fearchsel__fisher__ldc < goer_1i
    methods
        %> Constructor
        function o = setup(o)

            o.classname = 'fearchsel_fisher';
        end;

        function d = customize_session(o, d)
            % Make your experiments here
            d.oo.fearchsel_fisher_nf_max = 80;
        end;
    end;
end
