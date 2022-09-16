clear all
rng default;
NUM_ELEM=1000000;
NUM_DIMENSION=3;
NUM_CLUSTER=10;
disp(["Clusterizzo " + NUM_ELEM + " elementi " + NUM_DIMENSION + "dimensioni in " + NUM_CLUSTER + " cluster" ]);
X=randn(NUM_ELEM,NUM_DIMENSION);
clusterdata(X,'MaxClust',NUM_CLUSTER);

opts = statset('Display','final');
%[idx,C] = kmeans(X,NUM_CLUSTER,'Distance','sqeuclidean', 'Replicates',5,'Options',opts);
%linkage(X,'ward')
%linkage(X,'method','single','savememory','on')
%linkage(X,'complete')
