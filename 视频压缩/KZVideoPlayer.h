//
//  KZVideoPlayer.h
//  KZWeChatSmallVideo_OC
//
//  Created by HouKangzhu on 16/7/21.
//  Copyright © 2016年 侯康柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class KZVideoPlayer;
@protocol KZVideoPlayerDelegate <NSObject>
- (void)videoPlayer:(KZVideoPlayer *)player playerDidTaped:(NSURL *)url;
@end
@interface KZVideoPlayer : UIView

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl showLoadIndicator:(BOOL)show autoPlay:(BOOL)play;
@property (weak, nonatomic) id<KZVideoPlayerDelegate> delegate;

@property (nonatomic, strong, readonly) NSURL *videoUrl;

@property (nonatomic,assign) BOOL autoReplay; // 默认 YES

@property (assign, nonatomic) BOOL autoPlay;

@property (assign, nonatomic) BOOL showIndicator;

@property (assign, nonatomic) BOOL customTap;

- (void)play;

- (void)stop;

@end
