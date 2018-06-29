//
//  AGMediaPlayerViewController.h
//  iguana
//
//  Created by Alec Gorge on 3/3/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AGMediaItem.h"
#import "PTSHeatmap.h"

#import <AGAudioPlayer/AGAudioPlayer.h>

@interface AGMediaPlayerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

+ (instancetype)sharedInstance;

// playing, buffering etc
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) BOOL buffering;
@property (strong, nonatomic) AGAudioPlayer *audioPlayer;
@property (strong, nonatomic) AGAudioPlayerUpNextQueue *queue;

// an array of AGMediaItems
@property (nonatomic, readonly) AGAudioItem * currentItem;
@property (nonatomic, readonly) AGAudioItem * nextItem;
@property (nonatomic, readonly) NSInteger nextIndex;

@property (nonatomic) NSInteger currentIndex;

- (void)replaceQueueWithItems:(NSArray *) queue startIndex:(NSInteger)index;
- (void)addItemsToQueue:(NSArray *)queue;

@property (nonatomic) BOOL shuffle;
@property (nonatomic) BOOL loop;
@property (nonatomic) float progress;
@property (nonatomic) NSTimeInterval elapsed;
@property (nonatomic, readonly) float duration;

- (void)insertItem:(AGAudioItem *)item atIndex:(NSUInteger)index;

- (void)forward;
- (void)play;
- (void)stop;
- (void)pause;
- (void)backward;
- (void)togglePlayPause;

- (void)redrawUICompletely;

- (void)share;
- (void)shareFromView:(UIView *)view;

@property (nonatomic) PTSHeatmap *heatmap;

@end
