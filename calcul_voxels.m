% cc;
clear all
close all

%%% Variables pour activer/désactiver des parties dans le script
calcul_voxel = false; % créer les fichiers .mat dans ./metadata
verbose = false;  % affichage complet figures/console du calcul des voxels 
                  % (!!! Execution plus longue !!!)
affichage_voxel = true; % affichage plus rapide des résultats du calcul des voxels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Chargement des données
%%% !!! LANCER read_data.m SI ABSENCE DU "lapin.mat"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load lapin;

numCameras = size(masque,3);
for n=1:numCameras
    Ps{n} = [R(:,:,n) t(:,n)];
    Ps{n} = [eye(3,2) [1 1 1]']*Ps{n};
    sils{n} = masque(:,:,n);
    c_old{n} = C(:,n);
    [u,v] = ind2sub(size(sils{n}),find(sils{n}));
    classes_sils{n} = [v u];
    [u,v] = ind2sub(size(sils{n}),find(sils{n} == 0));
    classes_hors_sils{n} = [v u];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Définition et voxelisation de la boite englobante
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scaleX = 0.332147;
scaleY = 0.4321470;
scaleZ = 0.3921470;
pas = 0.05;
[x,y,z] = meshgrid(-scaleX:pas:scaleX,-scaleY:pas:scaleY,-scaleZ:pas:scaleZ);

grid3D.nx = length(x(1,:,1));
grid3D.ny = length(y(:,1,1));
grid3D.nz = length(z(1,1,:));
grid3D.minBound = [min(x(1,:,1)), min(y(:,1,1)), min(z(1,1,:))]';
grid3D.maxBound = [max(x(1,:,1)), max(y(:,1,1)), max(z(1,1,:))]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calcul des voxels parcourus par les différent rayons 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inv_K = inv(K);
if calcul_voxel
    for n=1:numCameras
        % Transformation des pixels dans le repère monde et calcul de la distance
        pixels = classes_sils{n};
        pixels = pixels(1:end,:);
        P_camera = (10^-2)*f*inv_K*[pixels ones(size(pixels,1),1)]';
        origins =transpose(R(:,:,n))*(P_camera - t(:,n));
        c = c_old{n};
        c = repmat(c',size(origins,2),1);
        directions = origins - c' ;
        
        % Calcul
        [voxel_indices,voxel_xyz] = amanatidesWooAlgorithm_AP_adapte(origins, directions, grid3D, verbose);

        % Enregistrer les résultats
        save("metadata/C1_voxels_sils_"+int2str(n)+".mat",'voxel_indices'); %indices voxels
        save("metadata/C1_voxels_silsXYZ_"+int2str(n)+".mat",'voxel_xyz'); %coordonnées voxels
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Affichage des voxels
%%% !!! calcul_voxel = true SI LES ".mat" SONT ABSENTS DE "./metadata"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if affichage_voxel
    for n=1:numCameras
        load("metadata/C1_voxels_sils_"+int2str(n)+".mat");
        load("metadata/C1_voxels_silsXYZ_"+int2str(n)+".mat");
        affichage_voxels(voxel_xyz,length(voxel_indices),grid3D);
        title(['Voxels du masque ',num2str(n)])
    end
end

