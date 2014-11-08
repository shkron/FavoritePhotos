//
//  Photos.h
//  FavoritePhotos
//
//  Created by Alex on 11/6/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photos : NSObject
@property (strong, nonatomic) NSString *imageID;
@property (strong, nonatomic) NSData *imgData;
@property double latitute;
@property double longtitude;

@property BOOL isFavorite;


-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;


-(void)retrieveImageDataWithComplete:(void(^)(NSData *data, NSError *error))completionBlock;

@end
