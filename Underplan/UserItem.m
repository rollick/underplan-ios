//
//  UserItem.m
//  Underplan
//
//  Created by Mark Gallop on 24/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UserItem.h"

@implementation UserItem

- (NSString *)summaryInfo
{
    NSString *created;
    if([self.created isKindOfClass:[NSMutableDictionary class]])
    {
        double dateDouble = [self.created[@"$date"] doubleValue];
        dateDouble = dateDouble/1000;
        NSDate *dateCreated = [NSDate dateWithTimeIntervalSince1970:dateDouble];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy 'at' HH:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:dateCreated];
        
        created = formattedDateString;
    }
    else
    {
        created = @"-";
    }
    
    return created;
}

@end
