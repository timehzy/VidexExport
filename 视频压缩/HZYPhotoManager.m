//
//  HZYPhotoManager.m
//  视频压缩
//
//  Created by Michael-Nine on 2016/10/10.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "HZYPhotoManager.h"
@import Photos;
@implementation HZYPhotoManager
+ (instancetype)sharedManager{
    static HZYPhotoManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)getPhotosWithCollectionsType:(PHAssetCollectionType)collectionsType subtype:(PHAssetCollectionSubtype)subType completeHandler:(void(^)(NSArray *images, NSArray *assets))complete{
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
        CGSize size = original ? PHImageManagerMaximumSize : CGSizeZero;
        
        // 从asset中获得图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [tempArr addObject:result];
            
        }];
    }
//    self.dataArray = tempArr;
//    self.assets = assets;
}
@end
