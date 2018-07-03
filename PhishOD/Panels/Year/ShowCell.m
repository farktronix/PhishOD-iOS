//
//  ShowCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/27/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "ShowCell.h"

#import "IGDurationHelper.h"

#import <MediaPlayer/MediaPlayer.h>
#import "PhishAlbumArtCache.h"

@interface ShowCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiSoundboardLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiRemasteredLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *heatmapView;
@property (weak, nonatomic) IBOutlet UIView *heatmapValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heatmapValueWidth;
@property (weak, nonatomic) IBOutlet UIImageView *uiArtworkImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uiLoadingIndicator;

@end

@implementation ShowCell

- (void)awakeFromNib {
    self.uiSoundboardLabel.backgroundColor = COLOR_PHISH_GREEN;
	self.uiRemasteredLabel.backgroundColor = COLOR_PHISH_GREEN;
	
	self.uiRemasteredLabel.layer.cornerRadius =
	self.uiSoundboardLabel.layer.cornerRadius = 5.0f;
}

- (NSAttributedString *)attributedStringForShow:(PhishinShow *)show {
	NSMutableAttributedString *att = [NSMutableAttributedString.alloc initWithString:[show.venue_name stringByAppendingFormat:@"\n%@", show.location]];
	
	[att addAttributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote],
						 NSForegroundColorAttributeName: UIColor.darkGrayColor,
						 }
				 range:NSMakeRange(show.venue_name.length + 1, show.location.length)];

	return att;
}

- (void)updateCellWithShow:(PhishinShow *)show
			   inTableView:(UITableView *)tableView {
    // dynamic type
    self.uiDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.uiDurationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.uiDescriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
	self.uiDateLabel.text = show.date;
	self.uiDurationLabel.text = [IGDurationHelper formattedTimeWithInterval:show.duration / 1000.0f];
    self.uiSoundboardLabel.alpha = show.sbd ? 1.0 : 0.2;
    self.uiRemasteredLabel.alpha = show.remastered ? 1.0 : 0.2;
		
	self.uiDescriptionLabel.attributedText = [self attributedStringForShow:show];
    
    [self.uiLoadingIndicator startAnimating];
    PhishAlbumArtCache *c = PhishAlbumArtCache.sharedInstance;
    
    self.uiArtworkImage.image = nil;
    self.uiLoadingIndicator.hidden = NO;
    [c.sharedCache asynchronouslyRetrieveImageForEntity:show
                                         withFormatName:PHODImageFormatSmall
                                        completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                                            self.uiArtworkImage.image = image;
                                            self.uiLoadingIndicator.hidden = YES;

                                            [self.uiArtworkImage.layer addAnimation:[CATransition animation]
                                                                          forKey:kCATransition];
                                        }];
}

- (CGFloat)heightForCellWithShow:(PhishinShow *)show
					 inTableView:(UITableView *)tableView {
    CGFloat leftMargin = 10;
    CGFloat rightMargin = 50;
    
    CGSize constraintSize = CGSizeMake(tableView.bounds.size.width - leftMargin - rightMargin, MAXFLOAT);
	
	NSAttributedString *att = [self attributedStringForShow:show];
    CGRect labelSize = [att boundingRectWithSize:constraintSize
										 options:NSStringDrawingUsesLineFragmentOrigin
										 context:nil];
    
    return MAX((tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight), labelSize.size.height + 35 + 10);
}

- (void)updateHeatmapLabelWithValue:(float)val {
	self.heatmapView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"heatmaps.enabled"];
	CGFloat max_width = self.heatmapView.frame.size.width;
	self.heatmapValueWidth.constant = max_width * val;
}

@end
