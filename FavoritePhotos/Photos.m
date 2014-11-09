//
//  Photos.m
//  FavoritePhotos
//
//  Created by Alex on 11/6/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "Photos.h"

@interface Photos()



@end

@implementation Photos

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super init];

    self.imageID = dictionary[@"id"];
    self.favImgStar = @"";

    NSDictionary *imgJSON = dictionary[@"images"];
    NSDictionary *imgJSONResolution = imgJSON[@"standard_resolution"];
    self.imgURLString = imgJSONResolution[@"url"];

//    [self dataWithURLString:imgURLString];
//    self.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURLString]];
//    later use UIImage* image = [UIImage imageWithData: ];
    self.isFavorite = NO;


    

    return self;
}


// Calling from async request already, not sure if I still need that
-(void)retrieveImageDataWithComplete:(void(^)(NSData *data, NSError *error))completionBlock
{

    NSURL *url = [NSURL URLWithString:self.imgURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           if (connectionError)
                                           {
                                               completionBlock(0, connectionError);
                                              NSLog(@"%@",connectionError.localizedDescription);
                                           }
                                           else
                                           {
                                               completionBlock(data, nil); //return the data to the block
                                           }
                                       }];
}




@end
