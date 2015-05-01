//
//  LivePhishCategoryViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishCategoryViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "LivePhishAPI.h"
#import "LargeImageTableViewCell.h"
#import "LivePhishContainerViewController.h"

typedef NS_ENUM(NSInteger, LivePhishCategoryViewControllerMode) {
	LivePhishCategoryViewControllerCategoryMode,
	LivePhishCategoryViewControllerStashMode,
	LivePhishCategoryViewControllerFeaturedContentMode,
	LivePhishCategoryViewControllerModeCount,
};

@interface LivePhishCategoryViewController ()

@property (nonatomic) LivePhishCategoryViewControllerMode viewMode;

@property (nonatomic) LivePhishCategory *category;
@property (nonatomic) LivePhishStash *stash;

@property (nonatomic) NSArray *containers;

@end

@implementation LivePhishCategoryViewController

- (instancetype)initWithCategory:(LivePhishCategory *)cat {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.category = cat;
		self.viewMode = LivePhishCategoryViewControllerCategoryMode;
    }
    
    return self;
}

- (instancetype)initWithStash {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.viewMode = LivePhishCategoryViewControllerStashMode;
    }
    
    return self;
}

- (instancetype)initWithFeaturedContent {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.viewMode = LivePhishCategoryViewControllerFeaturedContentMode;
    }
    
    return self;
}

-(void)refresh:(id)sender {
    if(self.viewMode == LivePhishCategoryViewControllerCategoryMode) {
        [LivePhishAPI.sharedInstance containersForCategory:self.category
                                                   success:^(NSArray *containers) {
                                                       self.containers = containers;
                                                       
                                                       [self.tableView reloadData];
                                                       [super refresh:sender];
                                                   }
                                                   failure:REQUEST_FAILED(self.tableView)];
    }
    else if(self.viewMode == LivePhishCategoryViewControllerStashMode) {
        [LivePhishAPI.sharedInstance userStash:^(LivePhishStash *stash) {
            self.stash = stash;
            self.containers = stash.passes;
            
            [self.tableView reloadData];
            [super refresh:sender];
        }
                                       failure:REQUEST_FAILED(self.tableView)];
    }
	else if(self.viewMode == LivePhishCategoryViewControllerFeaturedContentMode) {
        [LivePhishAPI.sharedInstance featuredContainers:^(NSArray *containers) {
			self.containers = containers;
			
			[self.tableView reloadData];
			[super refresh:sender];
		}
                                       failure:REQUEST_FAILED(self.tableView)];
		
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.viewMode == LivePhishCategoryViewControllerCategoryMode) {
        self.title = self.category.name.capitalizedString;
    }
    else if(self.viewMode == LivePhishCategoryViewControllerStashMode) {
        self.title = @"My Stash";
    }
	else if(self.viewMode == LivePhishCategoryViewControllerFeaturedContentMode) {
        self.title = @"Featured";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.containers == nil) {
        return 0;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.containers.count;
}

- (UIImage *)placeholderImage {
    static UIImage *img;
    
    if(img == nil) {
        CGSize size = CGSizeMake(88.0f, 88.0f);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return img;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subtitle"];
    
    if(!cell) {
        cell = [LargeImageTableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:@"subtitle"];
    }
    
    LivePhishContainer *cont = self.containers[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = cont.displayText;
    cell.detailTextLabel.text = cont.displaySubtext;
    cell.detailTextLabel.numberOfLines = 3;
    
    [cell.imageView sd_setImageWithURL:cont.imageURL
                      placeholderImage:self.placeholderImage];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    LivePhishContainer *cont = self.containers[indexPath.row];
    LivePhishContainerViewController *vc = [LivePhishContainerViewController.alloc initWithContainer:cont];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end