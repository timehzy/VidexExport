//
//  HZYVideoExport.h
//  视频压缩
//
//  Created by Michael-Nine on 2016/10/10.
//  Copyright © 2016年 Michael. All rights reserved.
//

@import Foundation;
@import Photos;

typedef NS_ENUM(NSUInteger, HZYVideoExportPreset) {
    HZYVideoExportPresetLowQuality,
    HZYVideoExportPresetMediumQuality,
    HZYVideoExportPresetHighestQuality,
    HZYVideoExportPreset640x480,
    HZYVideoExportPreset960x540,
    HZYVideoExportPreset1280x720,
    HZYVideoExportPreset1920x1080,
    HZYVideoExportPreset3840x2160,
    HZYVideoExportPresetAppleM4A
};

@interface HZYVideoExport : NSObject
/**
 快速导出视频，若要进行详细的参数配置，使用对象方法，并在初始化对象后进行参数赋值

 @param asset    一个PHAsset对象，可以通过PHAssetCollection类的fetch方法获取
 @param url      导出文件的url，最好以.mp4结尾
 @param progress 导出的进度
 @param complete 完成回调
 */
+ (void)exportVideo:(PHAsset *)asset outputURL:(NSString *)url progress:(void(^)(CGFloat outputProgress))progress completeHandler:(void(^)(NSError *error))complete;
- (void)exportVideo:(PHAsset *)asset outputURL:(NSString *)url progress:(void(^)(CGFloat outputProgress))progress completeHandler:(void(^)(NSError *error))complete;
- (void)cancel;
#pragma mark - 属性
//导出视频的压缩质量
@property (assign, nonatomic) HZYVideoExportPreset preset;

    //TODO:待实现的功能
    //是否允许从iCloud下载视频
    @property (assign, nonatomic) BOOL allowDownloadFromiCloud;
    //如果视频被编辑过，导出编辑后的还是原始的视频，默认原始
    @property (assign, nonatomic) BOOL editedVersion;
    //如果有同名文件，是否删除，默认删除
    @property (assign, nonatomic) BOOL deleteSameFile;
    //从照片库取出的视频版本（注意⚠️：只有导出视频为编辑后的即editedVersion属性为YES时此属性才会生效）
    @property (assign, nonatomic) PHVideoRequestOptionsDeliveryMode deliveryMode;
@end
