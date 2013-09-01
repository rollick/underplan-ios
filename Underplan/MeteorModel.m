//
//  MeteorModel.m
//  Underplan
//
//  Created by Mark Gallop on 7/08/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "MeteorModel.h"

@implementation MeteorModel

// Override this in the subclass
- (NSString *)collectionName
{
    return @"";
}

// Override this in the subclass
- (BOOL)processApiData: (NSDictionary *)data_
{
    return true;
}

- (id)initWithData: (NSDictionary *)data_
{
    self = [super init];
    [self processApiData:data_];
    
    return self;
}

- (id)initWithIdAndUnderplanApiClient: (NSString *)id_ apiClient:(UnderplanApiClient *)apiClient
{
    self = [super init];
    self.apiClient = apiClient;
    
    NSArray *collection_ = self.apiClient.collections[self.collectionName];
    NSDictionary *data_ = [self findItemInDictionaryById:collection_ id:id_];
    [self processApiData:data_];
    
    return self;
}

- (id)initWithIdAndCollection: (NSString *)id_ collection:(NSArray *)collection_
{
    self = [super init];
    
    NSDictionary *data_ = [self findItemInDictionaryById:collection_ id:id_];
    [self processApiData:data_];
    
    return self;
}

- (NSDictionary *)findItemInDictionaryById: (NSArray *)collection_ id:(NSString *)id_
{
    NSDictionary *data_;
    for (NSDictionary *dict in collection_) {
        NSString *mod = dict[@"_id"];
        if ([mod isEqualToString:id_]) {
            data_ = dict;
            break;
        }
    }
    
    return data_;
}

@end
