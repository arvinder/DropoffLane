//
//  Article.h
//
//  Created by Adam McDonald on 1/16/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) UIImage  *image;
@property (nonatomic, retain) NSString  *imageURL;
@property (nonatomic, retain) NSString  *bitlyURL;

@end
