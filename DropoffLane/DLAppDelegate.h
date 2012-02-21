//
//  DLAppDelegate.h
//  DropoffLane
//
//  Created by Adam McDonald on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OLArticleViewController;

@interface DLAppDelegate : UIResponder <UIApplicationDelegate>{
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OLArticleViewController *viewController;

@end
