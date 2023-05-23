function affichage_voxels(voxel_xyz,nb_voxels,grid3D)

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
    xlim([(3/2*vmin(1)) (3/2*vmax(1))])
    ylim([(3/2*vmin(2)) (3/2*vmax(2))])
    zlim([(3/2*vmin(3)) (3/2*vmax(3))])
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on;
    
    boxSize = grid3D.maxBound-grid3D.minBound;
    for i=1:nb_voxels
        xv = voxel_xyz(1,i);
        yv = voxel_xyz(2,i);
        zv = voxel_xyz(3,i);
        t1 = [(xv-1)/grid3D.nx, (yv-1)/grid3D.ny, (zv-1)/grid3D.nz ]';
        t2 = [  (xv)/grid3D.nx,  (yv)/grid3D.ny,    (zv)/grid3D.nz ]';
        
        %% Calcul des coordonnées des sommets du voxel courant
        vmin = (grid3D.minBound + t1.*boxSize)';
        vmax = (grid3D.minBound + t2.*boxSize)';
        smallBoxVertices = [vmax(1) vmin(2) vmin(3); vmax(1) vmax(2) vmin(3); vmin(1) vmax(2) vmin(3); vmin(1) vmax(2) vmax(3); vmin(1) vmin(2) vmax(3); vmax(1) vmin(2) vmax(3); vmin; vmax ];
        smallBoxFaces    = [1 2 3 7; 1 2 8 6; 1 6 5 7; 7 5 4 3; 2 8 4 3; 8 6 5 4];
    
        h = patch('Vertices', smallBoxVertices, 'Faces', smallBoxFaces, 'FaceColor', 'blue', 'EdgeColor', 'white');
        set(h,'FaceAlpha',0.2);
    end

end

