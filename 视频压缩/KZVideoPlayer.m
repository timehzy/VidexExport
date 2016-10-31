//
//  KZVideoPlayer.m
//  KZWeChatSmallVideo_OC
//
//  Created by HouKangzhu on 16/7/21.
//  Copyright © 2016年 侯康柱. All rights reserved.
//

#import "KZVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation KZVideoPlayer {
    AVPlayer *_player;
    
    UIView *_ctrlView;
    CALayer *_playStatus;
    
    BOOL _isPlaying;
    
    CGPoint _startPosition;
    CGPoint _defaultPosition;
    
    UIActivityIndicatorView *_indicator;
}

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl showLoadIndicator:(BOOL)show autoPlay:(BOOL)play{
    if (self = [super initWithFrame:frame]) {
        _autoReplay = YES;
        _videoUrl = videoUrl;
        self.showIndicator = show;
        self.autoPlay = play;
        [self setupSubViews];
    }
    return self;
}

- (void)play {
    if (_isPlaying) {
        return;
    }
    [self tapAction];
}

- (void)stop {
    if (_isPlaying) {
        [self tapAction];
    }
}


- (void)setupSubViews{
//    UIPanGestureRecognizer *drop = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(DropToRemove:)];
//    [self addGestureRecognizer:drop];
//        self.playAsset = [AVURLAsset assetWithURL:_videoUrl];
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithURL:_videoUrl];
    _player = [AVPlayer playerWithPlayerItem:playItem];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:playerLayer];
    
    _ctrlView = [[UIView alloc] initWithFrame:self.bounds];
    _ctrlView.backgroundColor = [UIColor clearColor];
    [self addSubview:_ctrlView];
    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.color = [UIColor redColor];
    _indicator.center = self.center;
    _indicator.hidesWhenStopped = YES;
    [self addSubview:_indicator];
    if ([_videoUrl.absoluteString hasPrefix:@"http"] && _showIndicator) {
        [_indicator startAnimating];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_ctrlView addGestureRecognizer:tap];
    [self setupStatusView];
    if (_autoPlay) {
        [self tapAction];
    }
    
}

- (void)setupStatusView {
    CGPoint selfCent = CGPointMake(self.bounds.size.width/2+10, self.bounds.size.height/2);
    CGFloat width = 40;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, selfCent.x - width/2, selfCent.y - width/2);
    CGPathAddLineToPoint(path, nil, selfCent.x - width/2, selfCent.y + width/2);
    CGPathAddLineToPoint(path, nil, selfCent.x + width/2 - 4, selfCent.y);
    CGPathAddLineToPoint(path, nil, selfCent.x - width/2, selfCent.y - width/2);
    
    CGColorRef color = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.5].CGColor;
    
    CAShapeLayer *trackLayer = [CAShapeLayer layer];
    trackLayer.frame = self.bounds;
    trackLayer.strokeColor = [UIColor clearColor].CGColor;
    trackLayer.fillColor = color;
    trackLayer.opacity = 1.0;
    trackLayer.lineCap = kCALineCapRound;
    trackLayer.lineWidth = 1.0;
    trackLayer.path = path;
    [_ctrlView.layer addSublayer:trackLayer];
    _playStatus = trackLayer;
    
    CGPathRelease(path);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _player && [keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            [_indicator stopAnimating];
        } else if (_player.status == AVPlayerStatusFailed) {
//            [_indicator stopAnimating];

        }
    }
}

- (void)DropToRemove:(UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        _defaultPosition = [gesture translationInView:[UIApplication sharedApplication].keyWindow];
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _startPosition = [gesture translationInView:[UIApplication sharedApplication].keyWindow];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        CGPoint endPosition = [gesture translationInView:[UIApplication sharedApplication].keyWindow];
        CGFloat distanceX = _startPosition.x - endPosition.x;
        CGFloat distanceY = _startPosition.y - endPosition.y;
        CGFloat distance = sqrt(distanceX*distanceX + distanceY*distanceY);
        if (distance > 64) {
            [self removeFromSuperview];
        }else{
            self.center = _defaultPosition;
        }
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.center = [gesture translationInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)tapAction {
    if (_customTap) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playerDidTaped:)]) {
            [self.delegate videoPlayer:self playerDidTaped:self.videoUrl];
        }
    }else{
        if (_isPlaying) {
            [_player pause];
        }
        else {
            [_player play];
        }
        _isPlaying = !_isPlaying;
        _playStatus.hidden = !_playStatus.hidden;
    }
}

- (void)playEnd {
    if (!_autoReplay) {
        return;
    }
    @try {
        [_player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [_player play];
        }];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    } @finally {
        
    }
}

- (void)removeFromSuperview {
    [_player pause];
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player removeObserver:self forKeyPath:@"status"];
    [super removeFromSuperview];
}

- (void)dealloc {
//    NSLog(@"player dalloc");
}
@end
