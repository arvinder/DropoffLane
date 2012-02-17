//
//  OLArticleViewController.h
//
//  Created by Adam McDonald on 1/18/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Article;

@interface OLArticleViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *ivSharing;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnSaveArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnEmailArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnFacebookArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnTweetArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *modalFacebookView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *modalTwitterView;

@property (strong, nonatomic) Article *article;

- (void)loadArticle:(Article *)theArticle;

- (IBAction)touchSaveArticle:(id)sender;
- (IBAction)touchEmailArticle:(id)sender;
- (IBAction)touchFacebookArticle:(id)sender;
- (IBAction)touchTweetArticle:(id)sender;

- (IBAction)touchShareTwitter:(id)sender;
- (IBAction)touchShareFacebook:(id)sender;
@end
