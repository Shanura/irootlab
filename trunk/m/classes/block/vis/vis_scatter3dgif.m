%> @brief GIF animation showing rotation of a 3D scatterplot
%> @sa data_draw_scatter_3d.m, uip_vis_scatter3dgif.m
classdef vis_scatter3dgif < vis
    properties
        %> =[1, 2, 3] Index of features to be uses as coordinates. Must be a 3-element vector.
        idx_fea = [1, 2, 3];
        %> =[] . Vector of confidence percentages (between 0 and 1) for drawing the confidence ellipsoids. If left
        %> empty, no confidence ellipsoid is drawn.
        confidences = [];
        %> =0 . Whether or not to annotate the observation names ( @c irdata::obsnames ) on the drawing. <b>Careful</b>:
        %> figure may become quite jammed and MATLAB responsively slow if there are over a thousand observations.
        flag_text = 0;
        %> =-30:8:330 . Rotation angles in degrees
        rots = -30:8:330;
        %> ='' . If not specified: scatter3d<nnnn>.gif.
        filename;
    end;
    
    methods
        function o = vis_scatter3dgif(o)
            o.classtitle = '3D Scatterplot - GIF animation';
            o.inputclass = 'irdata';
        end;
    end;
    
    methods(Access=protected)
        function [o, out] = do_use(o, obj)
            out = [];
            data_draw_scatter_3d(obj, o.idx_fea, o.confidences, o.flag_text);

            h = gca();
            p = get(h, 'Position');
%             axis off;
%             set(gca, 'Position', [0, 0, 1, 1]);
            set(gcf, 'Color', 'w');
%             set(h, 'Position', [.4, .4, .4+p(3)-p(1), .4+p(4)-p(2)]);

            msgbox('Please move and format the legend to your taste, then press Enter at the MATLAB command line.');
                
                

% ll = {};
% for i = 1:8
%     set(hh(i), 'MarkerSize', 8);
%     ll{i} = summer_idx2chemical_name2(i, 3);
% end;
% [h, shit1, shit2, shit3] = legend(hh, ll, 'Interpreter', 'Latex', 'FontSize', 28);
% 
% 
% 
% 
% h_ = get(h, 'children');
% for i = 1:length(h_)
%     hh_ = get(h_(i));
%     if hh_.Type == 'line'
%         set(h_(i),'markersize', 12);
%     end;
% end;
% 
            input('Please press Enter when ready to record animated GIF ');



% ss = {'xlim', 'ylim', 'zlim'};
% for i = 1:3
%     lim = max(abs(dslda.X(:, i)));
%     set(gca, ss{i}, [-lim, lim]);
% end;


            if isempty(o.filename)
                fn = find_filename('scatter3d', [], 'gif');
            else
                fn = o.filename;
            end;


            for i = 1:length(o.rots)
                set(gca, 'View', [o.rots(i), 30]);
                frame = getframe(gcf);


                if i == 1
                    [im, map] = rgb2ind(frame.cdata, 256, 'nodither');
                    im(1, 1, 1, length(o.rots)) = 0;
                end;
                im(:, :, 1, i) = rgb2ind(frame.cdata, map, 'nodither');
            end
            imwrite(im, map, fn, 'DelayTime', 0, 'LoopCount', inf);
        end;
    end;
end