//
//  HZYVideoExport.m
//  视频压缩
//
//  Created by Michael-Nine on 2016/10/10.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "HZYVideoExport.h"

@interface HZYVideoExport ()
@property (copy, nonatomic) NSString *outputURL;
@property (copy, nonatomic) NSString *avPreset;
@property (strong, nonatomic) PHVideoRequestOptions *options;
@property (strong, nonatomic) AVAssetExportSession *session;
@property (strong, nonatomic) NSTimer *timer;
@property (copy, nonatomic) void(^progressBlock)(CGFloat progress);
@end

@implementation HZYVideoExport
- (instancetype)init{
    if (self = [super init]) {
        _options = [PHVideoRequestOptions new];
        _options.networkAccessAllowed = NO;
        _options.version = PHVideoRequestOptionsVersionCurrent;
        _options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        _avPreset = AVAssetExportPresetMediumQuality;
        _deleteSameFile = YES;
    }
    return self;
}

- (void)requestExportSession:(PHAsset *)asset completionHandler:(void(^)(NSError *error))complete{
    [[PHImageManager defaultManager]requestExportSessionForVideo:asset options:self.options exportPreset:self.avPreset resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        //检测是否有同名文件
        if (self.deleteSameFile) {
            if ([[NSFileManager defaultManager]fileExistsAtPath:self.outputURL]) {
                NSError *error;
                if (![[NSFileManager defaultManager] removeItemAtPath:self.outputURL error:&error]) {
                    NSLog(@"%@", error);
                }
            }
        }
        [[NSFileManager defaultManager]createFileAtPath:self.outputURL contents:nil attributes:nil];
        self.session = exportSession;
        exportSession.outputURL = [NSURL fileURLWithPath:self.outputURL];
        exportSession.outputFileType = @"public.mpeg-4";
        exportSession.shouldOptimizeForNetworkUse = YES;
        self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(progressCheck) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSDefaultRunLoopMode];
        [self.timer fire];
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"%@", exportSession.error);
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil);
//                    NSError *error;
//                    NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:self.outputURL error:&error];
//                    if (error) {
//                        NSLog(@"%@", error);
//                    }else{
//                        NSLog(@"%@", fileAttr);
//                    }
                });
            }else{
                complete(exportSession.error);
            }
        }];
    }];
}

- (void)progressCheck{
    self.progressBlock(self.session.progress);
    if (self.session.progress == 1) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

+ (void)exportVideo:(PHAsset *)asset outputURL:(NSString *)url progress:(void (^)(CGFloat))progress completeHandler:(void (^)(NSError *error))complete{
    HZYVideoExport *export = [self new];
    export.outputURL = url;
    export.progressBlock = progress;
    [export requestExportSession:asset completionHandler:^(NSError *error){
        complete(error);
    }];
}

- (void)exportVideo:(PHAsset *)asset outputURL:(NSString *)url progress:(void (^)(CGFloat))progress completeHandler:(void (^)(NSError *error))complete{
    self.outputURL = url;
    self.progressBlock = progress;
    [self requestExportSession:asset completionHandler:^(NSError *error){
        complete(error);
    }];
}

- (void)cancel{
    if (self.session) {
        [self.session cancelExport];
    }
}

- (void)setPreset:(HZYVideoExportPreset)preset{
    switch (preset) {
        case HZYVideoExportPresetLowQuality:
            self.avPreset = AVAssetExportPresetLowQuality;
            break;
        case HZYVideoExportPresetMediumQuality:
            self.avPreset = AVAssetExportPresetMediumQuality;
            break;
        case HZYVideoExportPresetHighestQuality:
            self.avPreset = AVAssetExportPresetHighestQuality;
            break;
        case HZYVideoExportPreset640x480:
            self.avPreset = AVAssetExportPreset640x480;
            break;
        case HZYVideoExportPreset960x540:
            self.avPreset = AVAssetExportPreset960x540;
            break;
        case HZYVideoExportPreset1280x720:
            self.avPreset = AVAssetExportPreset1280x720;
            break;
        case HZYVideoExportPreset1920x1080:
            self.avPreset = AVAssetExportPreset1920x1080;
            break;
        case HZYVideoExportPreset3840x2160:
            self.avPreset = AVAssetExportPreset3840x2160;
            break;
        case HZYVideoExportPresetAppleM4A:
            self.avPreset = AVAssetExportPresetAppleM4A;
            break;
    }
}
@end
