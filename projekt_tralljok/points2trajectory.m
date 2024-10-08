function fun = points2trajectory(v)

if sum(v(1,1) ~= v(1,:)) ~= 0; x_interpolator = @(iq) interp1(1:width(v), v(1,:), iq, 'spline');
else;                          x_interpolator = @(iq) v(1,1);
end
if sum(v(2,1) ~= v(2,:)) ~= 0; y_interpolator = @(iq) interp1(1:width(v), v(2,:), iq, 'spline');
else;                          y_interpolator = @(iq) v(2,1);
end
if sum(v(3,1) ~= v(3,:)) ~= 0; z_interpolator = @(iq) interp1(1:width(v), v(3,:), iq, 'spline');
else;                          z_interpolator = @(iq) v(3,1);
end



fun = @(iq)temp(iq);

    function [vq] = temp(iq)
        if     iq < 1;         vq = v(:,1)   + (iq - 1       )*(v(:,2)   - v(:,1)    );
        elseif iq > width(v);  vq = v(:,end) + (iq - width(v))*(v(:,end) - v(:,end-1));
        else;                  vq = [x_interpolator(iq);
                                     y_interpolator(iq);
                                     z_interpolator(iq)];
        end


    end

end