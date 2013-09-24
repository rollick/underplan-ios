//
//  UserItem.h
//  Underplan
//
//  Created by Mark Gallop on 24/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "MeteorModel.h"

@interface UserItem : MeteorModel

@property (strong, nonatomic) NSMutableDictionary *created;

- (NSString *)summaryInfo;

@end
