function [voxels_parcourus,voxel_xyz] = amanatidesWooAlgorithm_AP_adapte(origins, directions, grid3D, verbose)
% A fast and simple voxel traversal algorithm through a 3D space partition (grid)
% proposed by J. Amanatides and A. Woo (1987).
%
% Input:
%    origin.
%    direction.
%    grid3D: grid dimensions (nx, ny, nz, minBound, maxBound).
% Author:
%    Jesús P. Mena-Chalco.

% Modified by Antti Pulkkinen April 2017. Function input-output modifications for use with tomography package.

%%% Modified by Groupe-2 2022. BE PI3D.

if nargin < 4,
    verbose = 0;
end;

if (verbose)
    figure;
    hold on;
    
    vmin = grid3D.minBound';
    vmax = grid3D.maxBound';
    BoxVertices = [vmax(1) vmin(2) vmin(3); vmax(1) vmax(2) vmin(3); vmin(1) vmax(2) vmin(3); vmin(1) vmax(2) vmax(3); vmin(1) vmin(2) vmax(3); vmax(1) vmin(2) vmax(3); vmin; vmax ];
    BoxFaces = [1 2 3 7; 1 2 8 6; 1 6 5 7; 7 5 4 3; 2 8 4 3; 8 6 5 4];
    h = patch('Vertices',BoxVertices,'Faces',BoxFaces,'FaceColor','yellow');
    set(h, 'FaceAlpha', 0.1);
    
    view(60,30);
    axis tight;
    xlim([-2 2])
    ylim([-2 2])
    zlim([-2 2])
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on;
end

% Groupe-2
voxels_parcourus = [];
voxel_xyz = [];
nb_origins = size(origins,2);
for p=1:nb_origins
    origin = origins(:,p);
    direction = directions(:,p);
    center = origin - direction;
    
    %%% Affichage pixel image
    if (verbose) plot3(origin(1), origin(2), origin(3), 'k.', 'MarkerSize', 15); end
    %%% Affichage centre caméra
    if p == 1
        if (verbose) plot3(center(1), center(2), center(3), 'y.', 'MarkerSize', 20); end
    end
    %%% Affichage rayon
    %quiver3(origin(1), origin(2), origin(3), direction(1), direction(2), direction(3), 10);

    [flag, tmin] = rayBoxIntersection(origin, direction, grid3D.minBound, grid3D.maxBound);
  
    if (flag==0)

        if verbose
            disp('\n The ray does not intersect the grid');
        end;

        % A. Pulkkinen.
        voxel_indices = [];

    else
        if (tmin<0)
            tmin = 0;
        end;

        % A. Pulkkinen. Initialize the matrix where indices are collected.
        voxel_indices = NaN*size(1,grid3D.nx*grid3D.ny*grid3D.nz);
        voxelCounter = 1;

        start   = origin + tmin*direction;
        boxSize = grid3D.maxBound-grid3D.minBound;

        if (verbose)
            plot3(start(1), start(2), start(3), 'r.', 'MarkerSize', 15);
        end;

        x = floor( ((start(1)-grid3D.minBound(1))/boxSize(1))*grid3D.nx )+1;
        y = floor( ((start(2)-grid3D.minBound(2))/boxSize(2))*grid3D.ny )+1;
        z = floor( ((start(3)-grid3D.minBound(3))/boxSize(3))*grid3D.nz )+1;

        if (x==(grid3D.nx+1));  x=x-1;  end;
        if (y==(grid3D.ny+1));  y=y-1;  end;
        if (y==0);  y=y+1;  end;
        if (z==(grid3D.nz+1));  z=z-1;  end;

        if (direction(1)>=0)
            tVoxelX = (x)/grid3D.nx;
            stepX = 1;
        else
            tVoxelX = (x-1)/grid3D.nx;
            stepX = -1;
        end;

        if (direction(2)>=0)
            tVoxelY = (y)/grid3D.ny;
            stepY = 1;
        else
            tVoxelY = (y-1)/grid3D.ny;
            stepY = -1;
        end;

        if (direction(3)>=0)
            tVoxelZ = (z)/grid3D.nz;
            stepZ = 1;
        else
            tVoxelZ = (z-1)/grid3D.nz;
            stepZ = -1;
        end;
        
        voxelMaxX  = grid3D.minBound(1) + tVoxelX*boxSize(1);
        voxelMaxY  = grid3D.minBound(2) + tVoxelY*boxSize(2);
        voxelMaxZ  = grid3D.minBound(3) + tVoxelZ*boxSize(3);

        tMaxX      = tmin + (voxelMaxX-start(1))/direction(1);
        tMaxY      = tmin + (voxelMaxY-start(2))/direction(2);
        tMaxZ      = tmin + (voxelMaxZ-start(3))/direction(3);

        voxelSizeX = boxSize(1)/grid3D.nx;
        voxelSizeY = boxSize(2)/grid3D.ny;
        voxelSizeZ = boxSize(3)/grid3D.nz;

        tDeltaX    = voxelSizeX/abs(direction(1));
        tDeltaY    = voxelSizeY/abs(direction(2));
        tDeltaZ    = voxelSizeZ/abs(direction(3));

        while ( (x<=grid3D.nx)&&(x>=1) && (y<=grid3D.ny)&&(y>=1) && (z<=grid3D.nz)&&(z>=1) )
            
            % A. Pulkkinen. Collect indices into a matrix. Notice that the
            % indexing is different in MatLab meshgrid matrices and in
            % Amanatide and Woo voxels and thus the x-y swap here.
            voxel_indices(voxelCounter) = y + (x-1)*grid3D.ny + (z-1)*grid3D.ny*grid3D.nx; voxelCounter = voxelCounter + 1;
            
            % Groupe-2
            if ~ismember(voxel_indices(voxelCounter-1),voxels_parcourus)
                voxel_xyz = [voxel_xyz [x;y;z]];
                if (verbose)
                    fprintf('\nIntersection: voxel = [%d %d %d]', [x y z]);

                    t1 = [(x-1)/grid3D.nx, (y-1)/grid3D.ny, (z-1)/grid3D.nz ]';
                    t2 = [  (x)/grid3D.nx,  (y)/grid3D.ny,    (z)/grid3D.nz ]';

                    vmin = (grid3D.minBound + t1.*boxSize)';
                    vmax = (grid3D.minBound + t2.*boxSize)';

                    smallBoxVertices = [vmax(1) vmin(2) vmin(3); vmax(1) vmax(2) vmin(3); vmin(1) vmax(2) vmin(3); vmin(1) vmax(2) vmax(3); vmin(1) vmin(2) vmax(3); vmax(1) vmin(2) vmax(3); vmin; vmax ];
                    smallBoxFaces    = [1 2 3 7; 1 2 8 6; 1 6 5 7; 7 5 4 3; 2 8 4 3; 8 6 5 4];

                    h = patch('Vertices', smallBoxVertices, 'Faces', smallBoxFaces, 'FaceColor', 'blue', 'EdgeColor', 'white');
                    set(h,'FaceAlpha',0.2);
                end
            end
            

            % ---------------------------------------------------------- %
            % check if voxel [x,y,z] contains any intersection with the ray
            %
            %   if ( intersection )
            %       break;
            %   end;
            % ---------------------------------------------------------- %

            if (tMaxX < tMaxY)
                if (tMaxX < tMaxZ)
                    x = x + stepX;
                    tMaxX = tMaxX + tDeltaX;
                else
                    z = z + stepZ;
                    tMaxZ = tMaxZ + tDeltaZ;
                end;
            else
                if (tMaxY < tMaxZ)
                    y = y + stepY;
                    tMaxY = tMaxY + tDeltaY;
                else
                    z = z + stepZ;
                    tMaxZ = tMaxZ + tDeltaZ;
                end;
            end;
        end;

        % A. Pulkkinen. Trim the matric containing the voxel indices.
        voxel_indices = voxel_indices(isfinite(voxel_indices));

        % Groupe-2
        intersec = ~ismember(voxel_indices,voxels_parcourus);
        voxels_parcourus = [voxels_parcourus voxel_indices(intersec)];
    end
   
end;

end




