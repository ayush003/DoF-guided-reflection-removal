function theta = threshold(img)
    [height,width] = size(img);
    theta = (1/(height*width))*sum(img(:)); % finds the initial threshold which is the average of the intensities of the pixels
end
