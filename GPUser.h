//
//  GPUser.h
//  GrowingPains
//
//  Created by Kyle Clegg on 11/19/12.
//  Copyright (c) 2012 Kyle Clegg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface GPUser : NSObject

@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSString *email;
@property NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSDate *updatedDate;

+ (RKObjectMapping *)mapping;

@end
