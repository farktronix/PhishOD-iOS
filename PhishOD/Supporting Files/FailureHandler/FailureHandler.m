//
//  FailureHandler.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "FailureHandler.h"
#import "RefreshableTableViewController.h"

@implementation FailureHandler

+ (void (^)(NSURLSessionTask *, NSError *))returnCallback:(RefreshableTableViewController *)table {
	return ^(NSURLSessionTask *op, NSError *err) {
		UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error!"
													message:[NSString stringWithFormat:@"%@\n\n%@", [err localizedDescription], err]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
		[a show];
		
		if(table != nil && [table respondsToSelector:@selector(refreshControl)])
			[table.refreshControl endRefreshing];
	};
}

+ (void)showAlertWithStatsError:(PhishTracksStatsError *)statsError
{
	[FailureHandler showErrorAlertWithMessage:[NSString stringWithFormat:@"%@",
											   [statsError primaryErrorMessage]]];
}

+ (void)showErrorAlertWithMessage:(NSString *)message
{
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
												message:message
											   delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
	[a show];
}

@end
