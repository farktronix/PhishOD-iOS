//
//  PhishNetAuth.h
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishNetAuth : NSObject

+(instancetype)sharedInstance;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *authkey;

@property (nonatomic, readonly) BOOL hasCredentials;

- (void)validateUsername:(NSString *)username
            withPassword:(NSString *)password
                    save:(BOOL)shouldSave
                  result:(void(^)(BOOL valid))result;

- (void)ensureSignedInFrom:(UIViewController *)vc
                   success:(void (^)(void))success;

- (void)signOut;

@end
