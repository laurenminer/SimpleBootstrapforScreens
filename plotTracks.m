function plotTracks(linkedTracks, Ring, numWorms)
    hold on 
    for i = 1:numWorms
        x = linkedTracks(i).SmoothX;
        y = linkedTracks(i).SmoothY;
        plot(x,y)
    end 
    plot(Ring.RingX, Ring.RingY,':','Color','black')
end
