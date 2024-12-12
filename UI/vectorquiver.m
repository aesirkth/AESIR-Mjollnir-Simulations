function vectorquiver(ax, pos, vec, varargin)
    quiver3(ax, pos(1,:), pos(2,:), pos(3,:), vec(1,:), vec(2,:), vec(3,:), varargin{:})
    end