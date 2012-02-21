//
//  OLArticleViewController.h
//
//  Created by Adam McDonald on 1/18/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "Facebook.h"

@class Article;

@interface OLArticleViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>{
    Article *article;
    
    UIButton *btnLogin;
    UIButton *btnPublish;
    UILabel *lblUser;
    UIActivityIndicatorView *actView;
    
    Facebook *facebook;
    
    NSArray *permissions; 
    BOOL isConnected;
    UIAlertView *msgAlert;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *ivSharing;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnSaveArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnEmailArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnFacebookArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnTweetArticle;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *modalFacebookView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *modalTwitterView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *fbTextView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *fbArticleImage;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *fbArticleTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *fbArticleSummary;

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *twitterTextView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *twitterArticleImage;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *twitterArticleTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *twitterArticleSummary;

@property (strong, nonatomic) Article *article;

@property (retain, nonatomic) IBOutlet UIButton *btnLogin;
@property (retain, nonatomic) IBOutlet UIButton *btnPublish;
@property (retain, nonatomic) IBOutlet UILabel *lblUser;
@property (retain, nonatomic) UIActivityIndicatorView *actView;
@property (retain, nonatomic) Facebook *facebook;
@property (retain, nonatomic) NSArray *permissions;
@property (nonatomic) BOOL isConnected;

- (IBAction)LoginOrLogout;
- (IBAction)Publish;
-(void) initializeFB;

- (void)loadArticle:(Article *)theArticle;

- (IBAction)touchSaveArticle:(id)sender;
- (IBAction)touchEmailArticle:(id)sender;
- (IBAction)touchFacebookArticle:(id)sender;
- (IBAction)touchTweetArticle:(id)sender;

- (IBAction)touchShareTwitter:(id)sender;
- (IBAction)touchShareFacebook:(id)sender;
- (void) setupTWModal;
- (void) setupFBModal;

-(void)checkForPreviouslySavedAccessTokenInfo;
-(void)setLoginButtonImage;

@end
