clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Chargement des données et Calcul de l'intersection
%%% !!! LANCER calcul_voxels.m SI PAS ENCORE FAIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nb_camera = 4;
C1_indices = [];
C2_indices = [];
C1_XYZ = [];
chemin_data = "metadata/";
for n=1:nb_camera
    load(chemin_data+"C1_voxels_sils_"+int2str(n)+".mat")
    load(chemin_data+"C1_voxels_silsXYZ_"+int2str(n)+".mat")
    if n==1
        C1_indices = voxel_indices;
        C1_XYZ = voxel_xyz;
    else
        [C1_indices,~,iy] = intersect(C1_indices,voxel_indices);
        C1_XYZ =  voxel_xyz(:,iy);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Affichage de l'enveloppe voxélisée
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scaleX = 0.332147;
scaleY = 0.4321470;
scaleZ = 0.3921470;
pas = 0.05; %% A MODIFIER SELON LE PAS DE CALCUL DES VOXELS
[x,y,z] = meshgrid(-scaleX:pas:scaleX,-scaleY:pas:scaleY,-scaleZ:pas:scaleZ);
grid3D.nx = length(x(1,:,1));
grid3D.ny = length(y(:,1,1));
grid3D.nz = length(z(1,1,:));
grid3D.minBound = [min(x(1,:,1)), min(y(:,1,1)), min(z(1,1,:))]';
grid3D.maxBound = [max(x(1,:,1)), max(y(:,1,1)), max(z(1,1,:))]';
affichage_voxels(C1_XYZ,length(C1_XYZ),grid3D);
title(['Enveloppe voxélisée'])

