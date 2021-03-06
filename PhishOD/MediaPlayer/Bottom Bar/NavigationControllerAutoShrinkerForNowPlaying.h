//
//  CenterPanelAutoShrinker.h
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationControllerAutoShrinkerForNowPlaying : NSObject<UINavigationControllerDelegate>

@property (nonatomic) UIViewController *lastViewController;

- (void)fixForViewController:(UIViewController*)vc;
- (void)fixForViewController:(UIViewController*)vc force:(BOOL)force;
- (void)addBarToViewController;
- (void)addBarToViewController:(UIViewController *)vc;

@end
