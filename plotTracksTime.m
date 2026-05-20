function virtualGrid(linkedTracks, numWorms, timeStart, timeEnd, gridSize)
   figure
   
   % Create grid
   hold on
   % Vertical lines
   for x = 0:gridSize:2500
       plot([x x], [0 2500], ':', 'Color', [0.8 0.8 0.8]);
   end
   % Horizontal lines
   for y = 0:gridSize:2500
       plot([0 2500], [y y], ':', 'Color', [0.8 0.8 0.8]);
   end
   
   % Initialize visited squares matrix
   numSquaresX = ceil(2500/gridSize);
   numSquaresY = ceil(2500/gridSize);
   visitedSquares = zeros(numSquaresY, numSquaresX);
   
   % Process tracks within time window
   for i = 1:numWorms
       % Get frames and coordinates within time window
       frames = linkedTracks(i).Frames;
       timeIndices = frames >= timeStart & frames <= timeEnd;
       x = linkedTracks(i).SmoothX(timeIndices);
       y = linkedTracks(i).SmoothY(timeIndices);
       
       % Plot track
       plot(x, y)
       
       % Mark visited squares
       for j = 1:length(x)
           if ~isnan(x(j)) && ~isnan(y(j))
               gridX = floor(x(j)/gridSize) + 1;
               gridY = floor(y(j)/gridSize) + 1;
               if gridX > 0 && gridX <= numSquaresX && gridY > 0 && gridY <= numSquaresY
                   visitedSquares(gridY, gridX) = 1;
               end
           end
       end
   end
   
   % Optional: Highlight visited squares (comment out if not wanted)
   [row, col] = find(visitedSquares);
   for i = 1:length(row)
       x = (col(i)-1)*gridSize;
       y = (row(i)-1)*gridSize;
       rectangle('Position', [x y gridSize gridSize], ...
                'FaceColor', [1 0 0 0.1], ...
                'EdgeColor', 'none');
   end
   
   % Set plot limits
   xlim([0 2500])
   ylim([0 2500])
   hold off
   
   % Display number of squares visited
   numSquaresVisited = sum(visitedSquares(:));
   fprintf('Number of squares visited: %d\n', numSquaresVisited);
end