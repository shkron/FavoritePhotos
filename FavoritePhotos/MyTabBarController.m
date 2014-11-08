//
//  MyTabBarController.m
//  FavoritePhotos
//
//  Created by Alex on 11/6/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController () <UITabBarControllerDelegate>

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}
@end
