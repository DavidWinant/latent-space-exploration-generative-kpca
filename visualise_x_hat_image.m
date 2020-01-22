function visualise_x_hat_image(x_hat,axes,image_size)
    % Shows generated images
    % Reshape x_hat to an image
    A = reshape(x_hat,image_size);
    imshow(A,'Parent',axes)
    title(axes, 'Generated image');