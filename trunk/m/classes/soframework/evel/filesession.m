%> The filesession identity is the "oo" object
%> 
%> To use filesession, it is expected that you will have a file named "sosetup_scene.m" on your local folder.
%>
%> Loading setups and objects from this file is the main feature of the filesession class.
%>
%> Apart from this, filesession contains a few tools (e.g. go_cube())
%>
%> @todo clean this
classdef filesession < as
    properties
        %> soitem object
        input;
        
        %> soitem object
        output;
        
        %> @ref sosetup object
        oo;
        
        %> Indicates preferred parallelization mode. 'inner' means in the reptt_blockcube, or other. 'outer' means at the dataset level.
        %> For more, check the constructor source code. 
        %>@todo obsolete
        paralleltype = 'inner';
    
        %> chooser object
        %> @todo do I use this?
        chooser;
        
        %> ='primary'. Dataset portion. See subdatasetprovider::get_subdatasets()
        %>@todo obsolete
        portion = 'primary';
    end;
    
    properties(SetAccess=protected)
        flag_parallel_ds = 0;
    end;

    properties(Access=private)
        nc_ = [];
        flag_configured = 0;
    end;

    % Constructor
    methods
        function o = filesession()
            o.oo = sosetup_scene();
            
            o = o.customize();
        end;
    end;
    
    
    methods(Sealed)
        function o = go(o)
            o = o.assert_configured();
           
            o = o.do_go();
        end;
        
        function o = assert_configured(o)
            if ~o.flag_configured
                o = o.configure();
            end;
        end;
        
        function o = configure(o)
            if ~isempty(o.oo.dataloader)
                try
                    o.nc_ = o.oo.dataloader.get_nc();
                catch ME
                    irverbose('WARNING: couldn''t load dataset, number of classes cannot be determined', 2);
                    o.nc_ = -1;
                end;
            else
                o.nc_ = -1;
            end;
            
            if o.oo.flag_parallel
                flag_outer = 0;
                switch o.paralleltype
% % % % % % % %                     case 'outer'
% % % % % % % %                         if o.get_no_datasets() > 1
% % % % % % % %                             % Even manifesting preferred outer parallelization, it only makes sense if there is more than one dataset
% % % % % % % %                             flag_outer = 1;
% % % % % % % %                         end;
                    case 'inner'
                    otherwise
                        irerror(sprintf('paralleltype "%s" not recognized', o.paralleltype));
                end;
                
% % % % % % % %                 o.flag_parallel_ds = flag_outer;
                o.oo.cubeprovider.flag_parallel = ~flag_outer;
            else
                o.flag_parallel_ds = 0;
                o.oo.cubeprovider.flag_parallel = 0;
            end;
            
            o.flag_configured = 1;
        end;
    end;
    
    methods(Abstract, Access=protected)
        o = do_go(o);
    end;
    
    % These methods may be overriden
    methods
        %> Override if you want to customize something in the "oo" property after it has been set. Also used to transfer appropriate values from "oo" into the object itself.    
        function o = customize(o)
        end;      
    end;

    
    % Set of tools to be used by inherited classes (or not)
    methods(Sealed)
        %> Returns initial diagnosissystem object
        function dia = get_initialdia(o)
            dia = diagnosissystem();
            dia.sostage_pp = o.oo.sostage_pp;
            dia.sostage_fe = o.oo.sostage_fe;
            dia.sostage_cl = o.oo.sostage_cl;
        end;

        
        %> Returns the number of classes in the dataset
        function nc = get_nc(o)
            if isempty(o.nc_)
                irerror('get_nc() cannot be called yet!');
            end;

            nc = o.nc_;
        end;
        
% % % % % % % % % % % % % %         function n = get_no_datasets(o)
% % % % % % % % % % % % % %             switch o.oo.splittype
% % % % % % % % % % % % % %                 case 'single'
% % % % % % % % % % % % % %                     n = 1;
% % % % % % % % % % % % % %                 case 'ovr'
% % % % % % % % % % % % % %                     n = o.get_nc()-1;
% % % % % % % % % % % % % %                 otherwise
% % % % % % % % % % % % % %                     irerror(sprintf('splittyle "%s" not supported', o.oo.splittype));
% % % % % % % % % % % % % %             end;
% % % % % % % % % % % % % %         end;

        %> Sets up a sostage_cl object either to utilize counterbalance, or else to use 1-fold undersampling
        function sos = setup_sostage_cl(o, sos, flag_cb)
            sos.flag_pairwise = strcmp(o.oo.splittype, 'single') && sos.flag_2class && o.get_nc() > 2;
            sos.under_randomseed = o.oo.under_randomseed;
            if flag_cb
                sos.flag_cb = 1;
                sos.flag_under = 0;
            else
                sos.flag_cb = 0;
                sos.flag_under = 1;
                sos.under_no_reps = 1;
            end;
        end;
            

        %> Common reptt_blockcube execution
        %>
        %> @param ds
        %> @param molds
        %> @param sostages
        %> @param specs Set of descriptors for each particular case. Important for when methods are chosen, then compared
        function sor = go_cube(o, ds, molds, sostages, specs)
            cube = o.oo.cubeprovider.get_cube(ds);
            cube.block_mold = molds;
            log = cube.use(ds);
            
            sor = sovalues();
            sor = sor.read_log_cube(log, []);
            sor = sor.set_field('sostage', sostages);
            sor.chooser = o.chooser;
            
            ni = numel(sostages);
            si = size(sostages);
            titles = cell(si);
            sor = sor.set_field('spec', specs);
        end;

        
        
% go straight to the dataoader now !!!% % % % % % %         %> Returns many datasets sccording to splittype
% % % % % % % %         %> @param index =1. "Index of dataset" to be passed to the dataloader
% % % % % % % %         function dss = get_dss(o, index)
% % % % % % % %             if nargin < 2 || isempty(index)
% % % % % % % %                 index = 1;
% % % % % % % %             end;
% % % % % % % %             
% % % % % % % %             ds = o.oo.dataloader.get_raw(index);
% % % % % % % %             
% % % % % % % %             ds = o.oo.subdatasetprovider.get_edgesubdataset(ds, o.portion);
% % % % % % % %             switch o.oo.splittype
% % % % % % % %                 case 'single'
% % % % % % % %                     dss = ds;
% % % % % % % %                 case 'ovr'
% % % % % % % %                     dss = o.oo.dataloader.get_ovr(ds);
% % % % % % % %                 otherwise
% % % % % % % %                     irerror(sprintf('Splittyle "%s" not recognized', o.oo.splittype));
% % % % % % % %             end;
% % % % % % % %         end;
    end;
    
    

end
