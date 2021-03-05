function new_image_ = resize_image(image_,new_size_)
    new_image_ = [];
    size_ = size(image_);
    if ndims(size_) < 3
        size_ = [size_ 1];
    end
    for z_ = 1:size_(3)
        new_image_(:,:,z_) = interpn(double(image_(:,:,z_)), ...
                                     1+(0:new_size_(1)-1)'*512/new_size_(1), ...
                                     1+(0:new_size_(2)-1) *512/new_size_(2));
    end
    new_image_ = uint8(new_image_);
end