//
//  Value1SubtitleCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "Value1SubtitleCell.h"

@implementation Value1SubtitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self relayout];
}

- (void)relayout {
    [self.titleLabel setPreferredMaxLayoutWidth:self.bounds.size.width - self.value1Label.bounds.size.width - 10];
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)height {
	return 61.0f;
}

@end
