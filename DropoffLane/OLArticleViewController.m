//
//  OLArticleViewController.m
//
//  Created by Adam McDonald on 1/18/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "OLArticleViewController.h"
#import "Article.h"

@implementation OLArticleViewController

@synthesize ivSharing = _ivSharing;
@synthesize btnSaveArticle = _btnSaveArticle;
@synthesize btnEmailArticle = _btnEmailArticle;
@synthesize btnFacebookArticle = _btnFacebookArticle;
@synthesize btnTweetArticle = _btnTweetArticle;
@synthesize modalFacebookView = _modalFacebookView;
@synthesize modalTwitterView = _modalTwitterView;
@synthesize article = _article;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.hidesBackButton = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Article *article = [[Article alloc] init];
    article.title = @"Apple OS X Mountain Lion: Top 15 New Features";
    article.summary = @"Apple just unveiled the next major upgrade to its core software, OS X. It’s called Mountain Lion, and it’s a doozy, bringing a lot of the features its customers use ever day on iPhones and iPads over to the Mac. Apple says Mountain Lion has 100 new features, from tiny details in the Safari web browser to wholesale changes in how instant messaging works.";
    article.url = @"http://mashable.com/2012/02/16/osx-mountain-lion-top-new-features/";
    article.image = [UIImage imageNamed:@"mountain-lion.jpg"];
    [self loadArticle:article];
}

- (void)viewDidUnload
{
    [self setIvSharing:nil];
    [self setBtnSaveArticle:nil];
    [self setBtnEmailArticle:nil];
    [self setBtnFacebookArticle:nil];
    [self setBtnTweetArticle:nil];
    [self setModalFacebookView:nil];
    [self setModalTwitterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	//return YES;
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)loadArticle:(Article *)theArticle {
    // Store
    self.article = theArticle;
    
    self.btnSaveArticle.selected = NO;
    self.modalTwitterView.hidden = YES;
    self.modalFacebookView.hidden = YES;
}

- (IBAction)touchSaveArticle:(id)sender
{
    NSLog(@"touchSaveArticle:");
    
    self.btnSaveArticle.selected = !self.btnSaveArticle.selected;
}

- (IBAction)touchEmailArticle:(id)sender
{
    NSLog(@"touchEmailArticle:");
}

- (IBAction)touchFacebookArticle:(id)sender
{
    NSLog(@"touchFacebookArticle:");
    
    self.modalTwitterView.hidden = YES;
    self.modalFacebookView.hidden = !self.modalFacebookView.hidden;
}

- (IBAction)touchTweetArticle:(id)sender
{
    NSLog(@"touchTweetArticle:");
    
    self.modalFacebookView.hidden = YES;
    self.modalTwitterView.hidden = !self.modalTwitterView.hidden;
}

- (IBAction)touchShareTwitter:(id)sender
{
    self.modalTwitterView.hidden = YES;
}

- (IBAction)touchShareFacebook:(id)sender
{
    self.modalFacebookView.hidden = YES;    
}

@end
