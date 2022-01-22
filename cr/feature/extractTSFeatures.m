function [features, validIndices] = extractTSFeatures(ptCloudIn, varargin)
% Parse and check inputs
[searchMethod, numNeighbors, radius, keyInds, weight] = validateAndParseInputs(ptCloudIn, varargin{:});
[ptCloud, validIndices] = removeInvalidPoints(ptCloudIn);

if isempty(ptCloud.Normal)
    % Atleast 3 valid points are needed for normal computation
    coder.internal.errorIf(ptCloud.Count < 3, 'lidar:extractLidarFeatures:notEnoughPoints');
    ptCloud.Normal = surfaceNormalImpl(ptCloud, 6);
end
% Throw error if there is any nan or Inf in normal
coder.internal.errorIf(any(isnan(ptCloud.Normal(:))) || any(isinf(ptCloud.Normal(:))), 'lidar:extractLidarFeatures:invalidNormal');

if(~isempty(keyInds))
    % Get valid key indices
    [newvalidIndices, ~, newkeyInds]  = intersect(keyInds, validIndices, 'stable');
    keyInds = cast(newkeyInds', class(keyInds));
    validIndices = cast(newvalidIndices, class(validIndices));
else
    % If key indices are empty, consider all point indices as key indices
    keyInds = uint32(1:ptCloud.Count);
end

if(isempty(keyInds))
    % If there are no valid points return features as empty
    features = zeros(1, 0);
    validIndices = zeros(1, 0);
else
    % Compute features
    features = TSExtractor(ptCloud, searchMethod, numNeighbors, radius, keyInds,weight);
end

% -------------------------------------------------------------------------
% Process PointCloud and extract descriptor for each point in it.
% -------------------------------------------------------------------------
function tsFeatures = TSExtractor(ptCloudIn, searchMethod, numNeighbors, radius, keyInds,weight)

numNeighbors = double(numNeighbors);
radius       = double(radius);

newCloud = pointCloud(double(ptCloudIn.Location), 'Normal', double(ptCloudIn.Normal));

% Estimate features
tsFeatures = extractTS(newCloud, keyInds,numNeighbors,weight);

% -------------------------------------------------------------------------
% Parse inputs
% -------------------------------------------------------------------------
function [searchMethod, numNeighbors, radius, keyInds, weights] = validateAndParseInputs(ptCloudIn, varargin)

validateattributes(ptCloudIn, {'pointCloud'}, {'scalar'}, mfilename, 'ptCloudIn');
% Validate and parse optional inputs
if isSimMode()
    % Setup parser
    parser = inputParser;
    parser.CaseSensitive = false;
    parser.FunctionName  = mfilename;
    % Set defaults values
    defaults = struct(...
        'NumNeighbors', 50, ...
        'Radius',       0.05, ...
        'indices',      [],...
        'weights',      0.2,...
        'row',          [],...
        'col',          []);

    parser.addParameter('NumNeighbors', defaults.NumNeighbors, @(x)validateattributes(x, {'numeric'}, ...
        {'nonnan', 'finite', 'nonsparse', 'scalar', 'positive', 'integer'}, mfilename, 'NumNeighbors'));
    parser.addParameter('Radius', defaults.Radius, @(x)validateattributes(x, {'numeric'}, ...
        {'nonnan', 'finite', 'nonsparse', 'scalar', 'positive'}, mfilename, 'Radius'));
    parser.addOptional('Weights', defaults.weights, @(x)validateattributes(x, {'numeric'}, ...
            {'nonnan', 'nonsparse', 'nonempty', 'positive','scalar'}, mfilename, 'weights'));

    if  ~bitget(nargin, 1)
        % Check for key indices
        parser.addOptional('indices', defaults.indices, @(x)validateattributes(x, {'numeric'}, ...
            {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'indices'));
        % Get values from inputs
        parser.parse(varargin{:});
        radius       = parser.Results.Radius;
        keyInds      = uint32(parser.Results.indices);
        numNeighbors = parser.Results.NumNeighbors;
        weights = parser.Results.Weights;
        % Error out if any keyInds value is greater than number of points
        % in input point cloud
        if max(keyInds) > ptCloudIn.Count
            error(message('lidar:extractLidarFeatures:invalidKeyIndices', ptCloudIn.Count));
        end
        % Error out if duplicate keyindices are provided.
        [~, uniqueIdx] = unique(keyInds, 'stable');
        if any(setdiff( 1:numel(keyInds), uniqueIdx ))
            error(message('lidar:extractLidarFeatures:duplicateKeyIndices'));
        end

    else
        % Check for key indices
        parser.addOptional('row', defaults.row, @(x)validateattributes(x, {'numeric'}, ...
            {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'row'));
        parser.addOptional('column', defaults.col, @(x)validateattributes(x, {'numeric'}, ...
            {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'column'));
        % Get values from inputs
        parser.parse(varargin{:});
        row          = parser.Results.row;
        column       = parser.Results.column;
        radius       = parser.Results.Radius;
        numNeighbors = parser.Results.NumNeighbors;
        weights = parser.Results.Weights;

        isrowSpecified = ~ismember('row', parser.UsingDefaults);
        iscolSpecified = ~ismember('column', parser.UsingDefaults);
        if (isrowSpecified && iscolSpecified)
            % Error out if point cloud is not organized
            if ismatrix(ptCloudIn.Location)
                error(message('vision:pointcloud:organizedPtCloudOnly'));
            end
            % Error out if there is size mismatch in row and column
            if(any(size(row) ~= size(column)))
                error(message('lidar:extractLidarFeatures:rowColumnSizeMismatch'));
            end

            [r,c,~] = size(ptCloudIn.Location);
            % Validare row and column
            if(max(row) > r)
                error(message('lidar:extractLidarFeatures:invalidRow', r));
            end
            if(max(column) > c)
                error(message('lidar:extractLidarFeatures:invalidColumn', c));
            end
        end
        % Convert row and column to linear indices and check for
        % duplicates
        keyInds = uint32(sub2ind([size(ptCloudIn.Location, 1), size(ptCloudIn.Location, 2)], row, column));
        [~, uniqueIdx] = unique(keyInds, 'stable');
        if(any(setdiff( 1:numel(keyInds), uniqueIdx )))
            error(message('lidar:extractLidarFeatures:duplicateRowColumn'));
        end
    end
    % Find search method
    isRadiusSpecified = ~ismember('Radius', parser.UsingDefaults);
    isKSpecified      = ~ismember('NumNeighbors', parser.UsingDefaults);

    if (isRadiusSpecified && isKSpecified)
        searchMethod = "HybridSearch";
    elseif(isRadiusSpecified)
        searchMethod = "RadiusSearch";
    else
        searchMethod = "KNNSearch";
    end

else
    pvPairs = struct(...
        'NumNeighbors', uint32(0), ...
        'Radius',       uint32(0));
     defaults = struct(...
        'NumNeighbors', 50, ...
        'Radius',       0.05);
    popt = struct(...
        'CaseSensitivity', false, ...
        'StructExpand',    true, ...
        'PartialMatching', true);

    paramIdx = coder.internal.indexInt(0);
    if  ~bitget(nargin, 1)
        % Check for indices
        validateattributes(varargin{1}, {'numeric'}, {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'indices');
        keyInds = uint32(varargin{1});
        paramIdx = coder.internal.indexInt(2);
        % Error out if any keyInds value is greater than number of points
        % in input point cloud
        coder.internal.errorIf(max(keyInds) > ptCloudIn.Count, 'lidar:extractLidarFeatures:invalidKeyIndices', ptCloudIn.Count);
        % Error out if duplicate keyindices are provided.
        [~, uniqueIdx] = unique(keyInds, 'stable');
        coder.internal.errorIf(any(setdiff( 1:numel(keyInds), uniqueIdx )), 'lidar:extractLidarFeatures:duplicateKeyIndices');

    else
        if (nargin > 1)
            numOptInputs = 0;
            for n = 1 : length(varargin)
                if ischar(varargin{n}) || isstring(varargin{n})
                    paramIdx = coder.internal.indexInt(n);
                    break;
                end
                numOptInputs = numOptInputs + 1;
            end
            switch (numOptInputs)
                case 0
                    inputData = lower(varargin{1});
                    % Validate row
                    if ~((startsWith('numneighbors', inputData)==1) || (startsWith('radius', inputData)==1))
                        validateattributes(varargin{1}, {'numeric'}, ...
                            {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'row');
                    else
                        keyInds = zeros(1, 0,'uint32');
                    end
                case 1
                    % Validate row and column
                    validateattributes(varargin{1}, {'numeric'}, ...
                            {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'row');

                    inputData = lower(varargin{2});
                    if ~((startsWith('numneighbors', inputData)==1) || (startsWith('radius', inputData)==1))
                        validateattributes(varargin{2}, {'numeric'}, ...
                            {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'column');
                    else
                        keyInds = zeros(1, 0, 'uint32');
                    end
                otherwise
                     validateattributes(varargin{1}, {'numeric'}, ...
                        {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'row');
                    validateattributes(varargin{2}, {'numeric'}, ...
                        {'nonnan', 'finite', 'nonsparse', 'nonempty', 'positive', 'integer', 'vector'}, mfilename, 'column');
                    row    = varargin{1};
                    column = varargin{2};
                    [r,c,~] = size(ptCloudIn.Location);
                    % Check whether input point cloud is organized or not
                    coder.internal.errorIf(ismatrix(ptCloudIn.Location), 'vision:pointcloud:organizedPtCloudOnly');
                    % Error out if there is size mismatch in row and column
                    coder.internal.errorIf(any(size(row) ~= size(column)), 'lidar:extractLidarFeatures:rowColumnSizeMismatch');
                    % Error out if the row and column are invalid
                    coder.internal.errorIf(max(row) > r, 'lidar:extractLidarFeatures:invalidRow', r);
                    coder.internal.errorIf(max(column) > c, 'lidar:extractLidarFeatures:invalidColumn', c);
                    % Convert row and column to linear indices and check for duplicates
                    keyInds = uint32(sub2ind([size(ptCloudIn.Location, 1), size(ptCloudIn.Location, 2)], row, column));
                    [~, uniqueIdx] = unique(keyInds, 'stable');
                    coder.internal.errorIf(any(setdiff( 1:numel(keyInds), uniqueIdx )), 'lidar:extractLidarFeatures:duplicateRowColumn');
            end
        else
            keyInds = zeros(1, 0, 'uint32');
        end
    end
    if(paramIdx ~= 0)
        optarg = eml_parse_parameter_inputs(pvPairs, popt, varargin{paramIdx:end});

        numNeighbors = eml_get_parameter_value(optarg.NumNeighbors, defaults.NumNeighbors, varargin{paramIdx:end});
        radius       = eml_get_parameter_value(optarg.Radius, defaults.Radius, varargin{paramIdx:end});

        validateattributes(radius, {'numeric'}, {'nonnan', 'finite', 'nonsparse', 'scalar', 'positive'}, mfilename, 'Radius');
        validateattributes(numNeighbors, {'numeric'}, {'nonnan', 'finite', 'nonsparse', 'scalar', 'positive', 'integer'}, mfilename, 'NumNeighbors');

        isRadiusSpecified = optarg.Radius ~= 0;
        isKSpecified      = optarg.NumNeighbors ~= 0;
        % Find search method
        if (isRadiusSpecified && isKSpecified)
            searchMethod = "HybridSearch";
        elseif(isRadiusSpecified)
            searchMethod = "RadiusSearch";
        else
            searchMethod = "KNNSearch";
        end
    else
        numNeighbors = defaults.NumNeighbors;
        radius       = defaults.Radius;
        searchMethod = "KNNSearch";
    end

end

%==========================================================================
function flag = isSimMode()
flag = isempty(coder.target);