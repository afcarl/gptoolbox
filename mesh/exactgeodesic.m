function [D,G] = exactgeodesic(V,F,id)
  % exactgeodesic - Exact Geodesic on Triangular Meshes 
  % (depends on igl_external/exactgeodesic)
  %
  % [D,G] = exactgeodesic(V,F,id)
  %
  % Inputs:
  %  V  list of vertex positions
  %  F  list of faces
  %  id starting vertex
  %
  % Outputs:
  %  D distances from id, # vertices by 1 matrix
  %  G exact gradients of D(in 3d)

global geodesic_library;                

% "release" is faster and "debug" does additional checks
geodesic_library = 'geodesic_release';      

% initialize new mesh
mesh = geodesic_new_mesh(V,F);

% initialize new geodesic algorithm
algorithm = geodesic_new_algorithm(mesh, 'exact');
source_points = {geodesic_create_surface_point('vertex',id,V(id,:))};

% propagation stage of the algorithm (the most time-consuming)
geodesic_propagate(algorithm, source_points);   
% find distances to all vertices of the mesh (actual pathes are not computed)
[~, D] = geodesic_distance_and_source(algorithm);     

G = zeros(size(V,1),3);
if nargout > 1
    % compute the gradients directions
    for i=1:size(V,1)
        destination = geodesic_create_surface_point('vertex',i,V(i,:));
        path = geodesic_trace_back(algorithm, destination);     %find a shortest path from source to destination
        if (size(path,1) >= 2)
            a = [path{1}.x path{1}.y path{1}.z];
            b = [path{2}.x path{2}.y path{2}.z];
            G(i,:) = a-b;
        end
    end
    
    % compute the gradients magnitudo
    G = normalizerow(G);
    G = repmat(D,1,3) .* G;
    
    % get rid of the nans on id
    G(id, :) = 0;
end

% delete all meshes and algorithms
geodesic_delete;                            


end