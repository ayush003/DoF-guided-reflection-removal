function theta = threshold(img)
    [height,width] = size(img);
    theta = (1/(height*width))*sum(img(:));
end
