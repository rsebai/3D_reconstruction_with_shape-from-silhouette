% Lecture des masques
load -ASCII metadata/matrices/RT0.mat;
load -ASCII metadata/matrices/RT1.mat;
load -ASCII metadata/matrices/RT2.mat;
load -ASCII metadata/matrices/RT3.mat;
load -ASCII metadata/matrices/K.mat

f = 46.05098342895508;

masque00001 = imread('metadata/masques/masque00000.png');
masque10001 = imread('metadata/masques/masque10000.png');
masque20001 = imread('metadata/masques/masque20000.png');
masque30001 = imread('metadata/masques/masque30000.png');

R = zeros(3,3,4);
t = zeros(3,4);

R(:,:,1) = RT0(:,1:3);
R(:,:,2) = RT1(:,1:3);
R(:,:,3) = RT2(:,1:3);
R(:,:,4) = RT3(:,1:3);

C = zeros(3,4);
C(:,1) = [0.0000; -2.0000; 0.0000];
C(:,2) = [2.0000; 0.0000; 0.0000];
C(:,3) = [0.0000; 2.0000; 0.0000];
C(:,4) = [-2.0000; 0.0000; 0.0000];

% t(:,1)= -R(:,:,1)*C(:,1);
% t(:,2)= -R(:,:,2)*C(:,2);
% t(:,3)= -R(:,:,3)*C(:,3);
% t(:,4)= -R(:,:,4)*C(:,4);

t(:,1)= RT0(:,4);
t(:,2)= RT1(:,4);
t(:,3)= RT2(:,4);
t(:,4)= RT3(:,4);


masque00001 = masque00001 > 200; % Inside of face, OR
masque10001 = masque10001 > 200; % Inside of face, OR
masque20001 = masque20001 > 200; % Inside of face, OR
masque30001 = masque30001 > 200; % Inside of face, OR


centre_cube = [0.05;0.05;0.08];
longueur_cote = 1;

masque = cat(3,masque00001,masque10001,masque20001,masque30001);

save('lapin.mat','R','t','masque','K','f','C','centre_cube','longueur_cote')