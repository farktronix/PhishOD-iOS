//
//  PHODTrackCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PHODTrackCell.h"

#import <NAKPlaybackIndicatorView/NAKPlaybackIndicatorView.h>
#import <LLACircularProgressView/LLACircularProgressView.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "IGDurationHelper.h"
#import "AGMediaPlayerViewController.h"
#import "RLShowViewController.h"
#import "IguanaMediaItem.h"
#import "AppDelegate.h"
#import "IGEvents.h"

@implementation UIImage (IPImageUtils)

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color {
    static UIImage *result = nil;
    
    if (result != nil) {
        return result;
    }
    
    UIImage *image = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    result = UIGraphicsGetImageFromCurrentImageContext();
    return result;
}

@end

@interface PHODTrackCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiTrackTitle;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackRunningTime;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackNumber;
@property (weak, nonatomic) IBOutlet NAKPlaybackIndicatorView *uiPlaybackIndicator;
@property (weak, nonatomic) IBOutlet UIView *heatmapView;
@property (weak, nonatomic) IBOutlet UIView *heatmapValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heatmapValueHeight;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonMore;
@property (weak, nonatomic) IBOutlet UIView *uiViewProgress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *uiConstraintProgress;

@property (nonatomic) NSObject<PHODGenericTrack> *track;
@property (nonatomic) NSTimer *progressTimer;

@property (nonatomic) PHODDownloadItem *downloadItem;

@property (nonatomic) BOOL hasSubtitle;

@end

@implementation PHODTrackCell

- (void)awakeFromNib {
    self.uiViewProgress.backgroundColor = [COLOR_PHISH_GREEN colorWithAlphaComponent:0.1];
    self.uiViewProgress.hidden = YES;
    self.uiConstraintProgress.constant = 0.0f;
    self.uiPlaybackIndicator.backgroundColor = UIColor.clearColor;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.uiConstraintProgress.constant = 0.0f;
    self.uiViewProgress.hidden = YES;
    
    [self.track.downloader removeDownloadObserver:self
                                            forId:self.track.id];
}

- (NSAttributedString *)attributedStringForTrack:(NSObject<PHODGenericTrack> *)track {
    if (!track || !track.title) {
        return nil;
    }
    
    NSMutableAttributedString *att = [NSMutableAttributedString.alloc initWithString:track.title
                                                                          attributes:@{NSFontAttributeName: self.uiTrackTitle.font}];
    if([track respondsToSelector:@selector(show_date)]) {
        NSString *showdate = [track performSelector:@selector(show_date)];
        
        if(showdate) {
            NSAttributedString *str = [NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"\n%@", showdate]
                                                                    attributes:@{
                                                                                 NSFontAttributeName: [UIFont systemFontOfSize:12.0f],
                                                                                 NSForegroundColorAttributeName: UIColor.darkGrayColor
                                                                                 }];
            [att appendAttributedString:str];
        }
    }
    
    return att;
}

- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
                inTableView:(UITableView *)tableView {
    // dynamic type
    UIFontDescriptor *boldSubhead = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    boldSubhead = [boldSubhead fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    self.uiTrackTitle.font = [UIFont fontWithDescriptor:boldSubhead
                                                   size:0.0f];
    self.uiTrackRunningTime.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.uiTrackNumber.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
	self.track = track;
    self.uiTrackNumber.text = @(track.track).stringValue;
    self.uiTrackTitle.attributedText = [self attributedStringForTrack:track];
    self.uiTrackRunningTime.text = [IGDurationHelper formattedTimeWithInterval:track.duration];
	
    self.uiPlaybackIndicator.tintColor = COLOR_PHISH_GREEN;
    if(track.id == AGMediaPlayerViewController.sharedInstance.currentItem.id) {
        self.uiTrackNumber.hidden = YES;
        if(AGMediaPlayerViewController.sharedInstance.playing) {
            self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStatePlaying;
        }
        else {
            self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStatePaused;
        }
    }
    else {
        self.uiTrackNumber.hidden = NO;
        self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStateStopped;
    }
    
    [self updateMoreButton];
	
	if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
		if(!track.isCached) {
			self.uiTrackTitle.alpha =
			self.uiTrackRunningTime.alpha =
			self.uiTrackNumber.alpha = 0.5;
			self.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else {
			self.uiTrackTitle.alpha =
			self.uiTrackRunningTime.alpha =
			self.uiTrackNumber.alpha = 1.0;
			self.selectionStyle = UITableViewCellSelectionStyleDefault;
		}
	}
    
    if([self.track.downloader isTrackDownloadingOrQueued:self.track.id]) {
        self.uiViewProgress.hidden = NO;
        [self setProgress:0.02f
                 animated:NO];
    }
    
    [self.track.downloader addDownloadObserver:self
                                         forId:self.track.id
                                      progress:^(int64_t dl, int64_t total) {
                                          self.uiViewProgress.hidden = NO;
                                          
                                          float per = (dl * 1.0f) / (total * 1.0f);
                                          [self setProgress:per
                                                   animated:YES];
                                      }
                                       success:^(NSURL *destUrl) {
                                           [self updateMoreButton];
                                           self.uiViewProgress.hidden = YES;
                                       }
                                       failure:^(NSError *err) {
                                           [self updateMoreButton];
                                           self.uiViewProgress.hidden = YES;
                                       }];

	self.heatmapView.hidden = YES;
}

- (void)setProgress:(float)per
           animated:(BOOL)animated {
    self.uiConstraintProgress.constant = -1.0f * (self.contentView.bounds.size.width - (per * self.contentView.bounds.size.width));
    
    void(^blk)(void) = ^{
        [self.contentView layoutIfNeeded];
        [self.uiViewProgress layoutIfNeeded];
    };
    
    [self.uiViewProgress updateConstraintsIfNeeded];
    
    if(animated) {
        [UIView animateWithDuration:0.1f
                         animations:blk];
    }
    else {
        blk();
    }
}

- (void)updateMoreButton {
    [self.uiButtonMore setImage:[UIImage imageNamed:self.track.isCached ? @"more-filled" : @"more"]
                       forState:UIControlStateNormal];
}

- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
             AndTrackNumber:(NSInteger)number
                inTableView:(UITableView *)tableView {
    [self updateCellWithTrack:track inTableView:tableView];
    self.uiTrackNumber.text = @(number).stringValue;
}

- (void)pollForProgressUpdates {
	if(self.progressTimer != nil) {
		return;
	}
	
	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
														  target:self
														selector:@selector(updateDownloadButtons)
														userInfo:nil
														 repeats:YES];
}

- (void)stopProgressUpdates {
	if(!self.progressTimer) {
		return;
	}
	
	[self.progressTimer invalidate];
	self.progressTimer = nil;
}

- (void)dealloc {
	[self stopProgressUpdates];
}

- (IBAction)showMoreOptions:(id)sender {
    UITableViewController *vc = (UITableViewController *)[AppDelegate topViewController];
    NSString *title = [NSString stringWithFormat:@"%@ (%@)", self.track.title, [IGDurationHelper formattedTimeWithInterval:self.track.duration]];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([vc isKindOfClass:[RLShowViewController class]]) {
        RLShowViewController *rlsvc = (RLShowViewController *)vc;
        [controller addAction:[UIAlertAction actionWithTitle:@"Play Next"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
            NSArray *playlist = [NSArray arrayWithObject:[IguanaMediaItem.alloc initWithTrack:(IGTrack *)self.track inShow:rlsvc.show]];
            
            if ([AGMediaPlayerViewController.sharedInstance queue].count == 0) {
                [AppDelegate sharedDelegate].currentlyPlayingShow = rlsvc.show;
                [AGMediaPlayerViewController.sharedInstance viewWillAppear:NO];
                [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist startIndex:0];
                [AppDelegate.sharedDelegate.navDelegate addBarToViewController];
                [AppDelegate.sharedDelegate.navDelegate fixForViewController:rlsvc];
                [AppDelegate.sharedDelegate saveCurrentState];
            } else {
                [AGMediaPlayerViewController.sharedInstance insertItem:playlist[0] atIndex:AGMediaPlayerViewController.sharedInstance.currentIndex + 1];
            }
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"Add to end of queue"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
            RLShowViewController *rlsvc = (RLShowViewController *)vc;
            NSArray *playlist = [NSArray arrayWithObject:[IguanaMediaItem.alloc initWithTrack:(IGTrack *)self.track inShow:rlsvc.show]];
            
            if ([AGMediaPlayerViewController.sharedInstance queue].count == 0) {
                [AppDelegate sharedDelegate].currentlyPlayingShow = rlsvc.show;
                [AGMediaPlayerViewController.sharedInstance viewWillAppear:NO];
                [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist startIndex:0];
                [AppDelegate.sharedDelegate.navDelegate addBarToViewController];
                [AppDelegate.sharedDelegate.navDelegate fixForViewController:rlsvc];
                [AppDelegate.sharedDelegate saveCurrentState];
            } else {
                [AGMediaPlayerViewController.sharedInstance addItemsToQueue:playlist];
            }
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"Add rest of tracks to queue"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
            RLShowViewController *rlsvc = (RLShowViewController *)vc;
            NSMutableArray *playlist = [NSMutableArray new];
            NSArray *temp = [rlsvc getAllTracks].mutableCopy;
            for (IguanaMediaItem *item in temp) {
                if (![item.iguanaTrack isEqual:self.track]) {
                    [playlist addObject:item];
                }
            }
            
            if ([AGMediaPlayerViewController.sharedInstance queue].count == 0) {
                [AppDelegate sharedDelegate].currentlyPlayingShow = rlsvc.show;
                [AGMediaPlayerViewController.sharedInstance viewWillAppear:NO];
                [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist startIndex:0];
                [AppDelegate.sharedDelegate.navDelegate addBarToViewController];
                [AppDelegate.sharedDelegate.navDelegate fixForViewController:rlsvc];
                [AppDelegate.sharedDelegate saveCurrentState];
            } else {
                [AGMediaPlayerViewController.sharedInstance addItemsToQueue:playlist];
            }
        }]];
    }
    
    if(self.track.isCached) {
        [controller addAction:[UIAlertAction actionWithTitle:@"Delete saved file"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [(IGTrack *)self.track deleteCache];
                                                         [self updateMoreButton];
                                                     }]];
    }
    else if(self.track.isDownloadingOrQueued) {
        [controller addAction:[UIAlertAction actionWithTitle:@"Cancel download"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
            if (self.track.downloader == nil) {
                return;
            }
            
            [self.track.downloader cancelDownloadForTrackId:self.track.id];
        }]];
    }
    else if (!self.track.isCached && AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
        [controller addAction:[UIAlertAction actionWithTitle:@"Download"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
            if (self.track.downloader == nil) {
                return;
            }
            
            [self.track.downloader downloadItem:self.track.downloadItem];
                                                         
                                                         [self setProgress:0.02f
                                                                  animated:NO];
                                                         self.uiViewProgress.hidden = NO;
        }]];
    }
    
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                   style:UIAlertActionStyleCancel
                                                 handler:nil]];
    
    [[AppDelegate topViewController] presentViewController:controller
                                                  animated:true
                                                completion:nil];
}

- (CGFloat)heightForCellWithTrack:(NSObject<PHODGenericTrack> *)track
                      inTableView:(UITableView *)tableView {
    CGFloat leftMargin = 49;
    CGFloat rightMargin = 83;
    
    CGFloat detail = self.hasSubtitle ? self.detailTextLabel.frame.size.width : 0;
    CGSize constraintSize = CGSizeMake(tableView.bounds.size.width - leftMargin - rightMargin - detail, MAXFLOAT);
    
    NSAttributedString *att = [self attributedStringForTrack:track];
    CGRect labelSize = [att boundingRectWithSize:constraintSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil];
    
    return MAX((tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight), labelSize.size.height + 24);
}

- (void)updateHeatmapLabelWithValue:(float)val {
	self.heatmapView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"heatmaps.enabled"];
	// with hue=48, we get the same color as the ratings stars
	CGFloat max_height = self.heatmapView.frame.size.height;
	self.heatmapValueHeight.constant = max_height * val;
    
    [self.heatmapValue setNeedsUpdateConstraints];
//	float min_hue = 48.0/0xFF;
//	float max_hue = 0;
//	float hue = (min_hue - max_hue) * (1.0 - val);
//	self.heatmapValue.backgroundColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

- (void)showHeatmap:(BOOL)show {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"heatmaps.enabled"]) {
		self.heatmapView.hidden = !show;
	}
}

- (NSObject<PHODGenericTrack> *)getTrack {
	return _track;
}

@end
