function datasetToODGT(dataset, copy_files)
    %copy_files is a bool set only if the files need to be copied. If not,
    %you can just use this function to create the odgt files.
    %dataset is a directory of images and annotations with the following
    %structure:
    %training
    %--image_2
    %--gt_image_2
    
    
    imgfolder = {dir(dataset + "/training/image_2").folder};
    imgfolder = imgfolder{1};
    
    segfolder = {dir(dataset + "/training/gt_image_2").folder};
    segfolder = segfolder{1};
    
    imgs = {dir(dataset + "/training/image_2").name};
    segs = {dir(dataset + "/training/gt_image_2").name};
    
    train_eval_idx = load('train_eval_indices.mat');
    train_eval_idx = train_eval_idx.train_eval_indices;
    
    %construct folders:
    %data
    %--annotations
    %----training
    %----validation
    %--images
    %----training
    %----validation
    
    mkdir kitti_data/annotations/training
    mkdir kitti_data/annotations/validation
    
    mkdir kitti_data/images/training
    mkdir kitti_data/images/validation
    
    train_odgt_imgs = {};
    train_odgt_segs = {};
    valid_odgt_imgs = {};
    valid_odgt_segs = {};
    
    train_odgt_w = {};
    train_odgt_h = {};
    valid_odgt_w = {};
    valid_odgt_h = {};
    
    for i = 3:size(imgs, 2)
        if train_eval_idx(i-2)
            %Copy to images/training
            if copy_files
                copyfile(imgfolder+"\"+imgs{i}, "kitti_data/images/training")
                copyfile(segfolder+"\"+segs{i}, "kitti_data/annotations/training")
            end
            
            %Add to training odgt array
            train_odgt_imgs{end + 1} = "kitti_data/images/training/" + imgs{i};
            train_odgt_segs{end + 1} = "kitti_data/annotations/training/" + segs{i};
            
            train_odgt_w{end+1} = imfinfo(imgfolder+"\"+imgs{i}).Width;
            train_odgt_h{end+1} = imfinfo(imgfolder+"\"+imgs{i}).Height;
            
        else
            %Copy to images/validation
            if copy_files
                copyfile(imgfolder+"\"+imgs{i}, "kitti_data/images/validation")
                copyfile(segfolder+"\"+segs{i}, "kitti_data/annotations/validation")
            end
            %Add to validation odgt
            valid_odgt_imgs{end + 1} = "kitti_data/images/validation/" + imgs{i};
            valid_odgt_segs{end + 1} = "kitti_data/annotations/validation/" + segs{i};
            
            valid_odgt_w{end+1} = imfinfo(imgfolder+"\"+imgs{i}).Width;
            valid_odgt_h{end+1} = imfinfo(imgfolder+"\"+imgs{i}).Height;
            
        end
    end
    
    disp('done copying. Writing odgt files...');
    
    train_fid = fopen('kitti_data/training.odgt', 'w');
    for i = 1:size(train_odgt_imgs, 2)
        fprintf(train_fid, ...
            '{"fpath_img": "%s", "fpath_segm": "%s", "width": %d, "height": %d}\n', ...
            train_odgt_imgs{i}, ...
            train_odgt_segs{i}, ...
            train_odgt_w{i}, ...
            train_odgt_h{i});
    end
    fclose(train_fid);

    valid_fid = fopen('kitti_data/validation.odgt', 'w');
    for i = 1:size(valid_odgt_imgs, 2)
        fprintf(valid_fid, ...
            '{"fpath_img": "%s", "fpath_segm": "%s", "width": %d, "height": %d}\n', ...
            valid_odgt_imgs{i}, ...
            valid_odgt_segs{i}, ...
            valid_odgt_w{i}, ...
            valid_odgt_h{i});
    end
    fclose(valid_fid);

    disp('finished creating odgt files');

end