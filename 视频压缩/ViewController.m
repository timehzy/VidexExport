//
//  ViewController.m
//  视频压缩
//
//  Created by Michael-Nine on 2016/10/9.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "KZVideoPlayer.h"
#import "HZYVideoExport.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) UICollectionView *collectionView;
@property (copy, nonatomic) NSArray *dataArray;
@property (copy, nonatomic) PHFetchResult<PHAsset *> * assets;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumLineSpacing = 16;
    layout.minimumInteritemSpacing = 8;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 600) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[AVCollectionViewCell class] forCellWithReuseIdentifier:@"aa"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    // Do any additional setup after loading the view, typically from a nib.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"aa" forIndexPath:indexPath];
//    UIImageView *view = [[UIImageView alloc]initWithImage:self.dataArray[indexPath.item]];
//    [cell.contentView addSubview:view];
    cell.image = self.dataArray[indexPath.item];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = [self.assets objectAtIndex:indexPath.item];
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/video123.mp4"];

    [HZYVideoExport exportVideo:asset outputURL:path progress:^(CGFloat outputProgress) {
        NSLog(@"%f", outputProgress);
    } completeHandler:^(NSError *error){
        if (error) {
            NSLog(@"%@", error);
        }else{            
            KZVideoPlayer *player = [[KZVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, 200, 200) videoUrl:[NSURL fileURLWithPath:path] showLoadIndicator:NO autoPlay:YES];
            player.center = self.view.center;
            UIView *view = [[UIView alloc]initWithFrame:self.view.bounds];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTaped:)]];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.8];
            [self.view addSubview:view];
            [view addSubview:player];
            NSError *fileError;
            NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&fileError];
            if (error) {
                NSLog(@"%@", fileError);
            }else{
                NSLog(@"%@", fileAttr);
            }
        }
    }];
}

- (void)videoTaped:(UITapGestureRecognizer *)gesture{
    [gesture.view removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    UIImagePickerController *pc = [UIImagePickerController new];
//    pc.delegate = self;
//    pc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentViewController:pc animated:YES completion:nil];
    
    PHFetchResult<PHAssetCollection *> *ac = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
    for (PHAssetCollection *collection in ac) {
        [self enumerateAssetsInAssetCollection:collection original:NO];
    }
}

/**
 *  遍历相簿中的所有图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        // 是否要原图
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
    
        // 从asset中获得图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [tempArr addObject:result];
            
        }];
    }
    self.dataArray = tempArr;
    self.assets = assets;
    [self.collectionView reloadData];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSURL *videoUrl = info[UIImagePickerControllerReferenceURL];
    NSLog(@"%@", videoUrl);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

@interface AVCollectionViewCell ()
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation AVCollectionViewCell
- (instancetype)init{
    if (self = [super init]) {
        [self configView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        [self configView];
    }
    return self;
}

- (void)configView{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}

@end
