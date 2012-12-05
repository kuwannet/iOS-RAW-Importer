//
//  AppDelegate.h
//  RAW Importer
//
//  Created by Dave Thorup on 12/4/12.
//  Copyright (c) 2012 Dave Thorup. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class ALAssetsLibrary;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) ALAssetsLibrary * assetLibrary;

@end
