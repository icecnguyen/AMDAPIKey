#pragma once

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface AMDAPIKey : NSObject

+ (instancetype)shared;

@property (nonatomic, assign, readonly) BOOL validated;

@property (nonatomic, assign, readonly) BOOL validating;

- (void)configureWithServerURL:(NSString *)serverURL packageToken:(NSString *)packageToken appVersion:(NSString *)appVersion targetBundle:(NSString *)targetBundle;

- (void)startWithViewController:(UIViewController *)vc;

@end
