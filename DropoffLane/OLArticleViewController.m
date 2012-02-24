//
//  OLArticleViewController.m
//
//  Created by Adam McDonald on 1/18/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "OLArticleViewController.h"
#import "Article.h"
#import <QuartzCore/QuartzCore.h>
#import "FBConnect.h"
#import "Facebook.h"
#import "SA_OAuthTwitterEngine.h"
#import "URLShortener.h"

#define kOAuthConsumerKey				@"9SMb1cUlE9bqusYYROA"		//REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret			@"bsTol6AAdkbASKHmgfXpZn7Awi4MlsKnhNR7YcYdQc"		//REPLACE With Twitter App OAuth Secret

@implementation OLArticleViewController

@synthesize ivSharing = _ivSharing;
@synthesize btnSaveArticle = _btnSaveArticle;
@synthesize btnEmailArticle = _btnEmailArticle;
@synthesize btnFacebookArticle = _btnFacebookArticle;
@synthesize btnTweetArticle = _btnTweetArticle;
@synthesize modalFacebookView = _modalFacebookView;
@synthesize modalTwitterView = _modalTwitterView;
@synthesize article = _article;
@synthesize fbTextView,fbArticleImage,fbArticleTitle,fbArticleSummary;
@synthesize twitterTextView,twitterArticleImage,twitterArticleTitle,twitterArticleSummary;
@synthesize btnLogin;
@synthesize btnPublish;
@synthesize lblUser;
@synthesize actView;
@synthesize facebook;
@synthesize permissions;
@synthesize isConnected;


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

-(void) initializeTW
{
    // Twitter Initialization / Login Code Goes Here
    if(!_engine){  
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
        _engine.consumerKey    = kOAuthConsumerKey;  
        _engine.consumerSecret = kOAuthConsumerSecret;  
    } 
}

-(void) initializeFB
{
    // Set the permissions.
    // Without specifying permissions the access to Facebook is imposibble.
    permissions = [[NSArray arrayWithObjects:@"read_stream", @"publish_stream", nil] retain];
    
    // Set the Facebook object we declared. We’ll use the declared object from the application
    // delegate.
    facebook = [[Facebook alloc] initWithAppId:@"351512468203753" andDelegate:self];
    
    // Check if there is a stored access token.
    [self checkForPreviouslySavedAccessTokenInfo];
    
    
    // Depending on the access token existence set the appropriate image to the login button.
    [self setLoginButtonImage];
    
    // Specify the lblUser label's message depending on the isConnected value.
    // If the access token not found and the user is not connected then prompt him/her to login.
    if (!isConnected) {
        //[lblUser setText:@"Tap on the Login to connect to Facebook"];
    }
    else {
        // Get the user's name from the Facebook account. The message will be set later.
        [facebook requestWithGraphPath:@"me" andDelegate:self];
    }
    
    // Initially hide the publish button.
    [btnPublish setHidden:YES];
    [btnLogin setHidden:YES];
}

/**
 * URLShortener delegate method that will be called when the URL was succesfully shortened.
 */

- (void) shortener: (URLShortener*) shortener didSucceedWithShortenedURL: (NSURL*) shortenedURL
{
    article.bitlyURL = [NSString stringWithFormat:@"%@",[shortenedURL absoluteString]];
    NSLog(@"shortener: %@ didSucceedWithShortenedURL: %@", self, [shortenedURL absoluteString]);
}

/**
 * URLShortener delegate method that will be called when the bit.ly service returned a non-200
 * status code to our request.
 */

- (void) shortener: (URLShortener*) shortener didFailWithStatusCode: (int) statusCode
{
    NSLog(@"shortener: %@ didFailWithStatusCode: %d", self, statusCode);
    article.bitlyURL = article.url;
}

/**
 * URLShortener delegate method that will be called when a lower level error has occurred. Like
 * network timeouts or host lookup failures.
 */

- (void) shortener: (URLShortener*) shortener didFailWithError: (NSError*) error
{
    NSLog(@"shortener: %@ didFailWithError: %@", self, [error localizedDescription]);
    article.bitlyURL = article.url;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    article = [[Article alloc] init];
    article.url = @"http://mashable.com/2012/02/16/osx-mountain-lion-top-new-features/";
    URLShortener* shortener = [[URLShortener new] autorelease];
    if (shortener != nil) {
        shortener.delegate = self;
        shortener.login = @"offlane";
        shortener.key = @"R_7f1b672f4de4c6e8a8a41d0bd1bd604c";
        shortener.url = [NSURL URLWithString: article.url];
        [shortener execute];
    }
    
    
    article.title = @"Apple OS X Mountain Lion: Top 15 New Features";
    article.summary = @"Apple just unveiled the next major upgrade to its core software, OS X. It’s called Mountain Lion, and it’s a doozy, bringing a lot of the features its customers use ever day on iPhones and iPads over to the Mac. Apple says Mountain Lion has 100 new features, from tiny details in the Safari web browser to wholesale changes in how instant messaging works.";
    
    article.image = [UIImage imageNamed:@"mountain-lion.jpg"];
    article.imageURL = @"http://financialpress.com/wp-content/plugins/RSSPoster_PRO/cache/72b7a_mitchells.top.jpg";
    
    
    
    [self loadArticle:article];
    
    [self setupFBModal];
    [self setupTWModal];
    
    [self initializeFB];
    
    
}

-(void)checkForPreviouslySavedAccessTokenInfo{
    // Initially set the isConnected value to NO.
    isConnected = NO;
    
    // Check if there is a previous access token key in the user defaults file.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] &&
        [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        
        // Check if the facebook session is valid.
        // If it’s not valid clear any authorization and mark the status as not connected.
        if (![facebook isSessionValid]) {
            [facebook authorize:nil];
            isConnected = NO;
        }
        else {
            isConnected = YES;
        }
    }
}
-(void)setLoginButtonImage{
    UIImage *imgNormal;
    UIImage *imgHighlighted;
    UIImageView *tempImage;
    
    // Check if the user is connected or not.
    if (!isConnected) {
        // In case the user is not connected (logged in) show the appropriate
        // images for both normal and highlighted states.
        //imgNormal = [UIImage imageNamed:@"LoginNormal.png"];
        //imgHighlighted = [UIImage imageNamed:@"LoginPressed.png"];
    }
    else {
        imgNormal = [UIImage imageNamed:@"LogoutNormal.png"];
        imgHighlighted = [UIImage imageNamed:@"LogoutPressed.png"];
        
        tempImage = [[UIImageView alloc] initWithImage:imgNormal];
        [btnLogin setBackgroundImage:imgNormal forState:UIControlStateNormal];
        [btnLogin setBackgroundImage:imgHighlighted forState:UIControlStateHighlighted];
        [tempImage  release];
    }
    
    // Get the screen width to use it to center the login/logout button.
    // We’ll use a temporary image view to get the appopriate width and height.
    //float screenWidth = [UIScreen mainScreen].bounds.size.width;    
    /*tempImage = [[UIImageView alloc] initWithImage:imgNormal];
    //[btnLogin setFrame:CGRectMake(screenWidth / 2 - tempImage.frame.size.width / 2, btnLogin.frame.origin.y, tempImage.frame.size.width, tempImage.frame.size.height)];
    
    // Set the button’s images.
    [btnLogin setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:imgHighlighted forState:UIControlStateHighlighted];
    
    // Release the temporary image view.
    [tempImage  release];*/
}

-(void)showActivityView{
    // Show an alert with a message without the buttons.
    msgAlert = [[UIAlertView alloc] initWithTitle:@"Offlane" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [msgAlert show];
    
    // Show the activity view indicator.
    actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
    [actView setCenter:CGPointMake(160.0, 350.0)];
    [actView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:actView];
    [actView startAnimating];
}


-(void)stopShowingActivity{
    [actView stopAnimating];
    [msgAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)saveAccessTokenKeyInfo{
    // Save the access token key info into the user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

-(void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    // Keep this just for testing purposes.
    NSLog(@"received response");
}


-(void)request:(FBRequest *)request didLoad:(id)result{
    // With this method we’ll get any Facebook response in the form of an array.
    // In this example the method will be used twice. Once to get the user’s name to
    // when showing the welcome message and next to get the ID of the published post.
    // Inside the result array there the data is stored as a NSDictionary.    
    if ([result isKindOfClass:[NSArray class]]) {
        // The first object in the result is the data dictionary.
        result = [result objectAtIndex:0];
    }
    
    // Check it the “first_name” is contained into the returned data.
    if ([result objectForKey:@"first_name"]) {
        // If the current result contains the "first_name" key then it's the user's data that have been returned.
        // Change the lblUser label's text.
        //[lblUser setText:[NSString stringWithFormat:@"Welcome %@!", [result objectForKey:@"first_name"]]];
        // Show the publish button.
        [btnPublish setHidden:NO];
        [btnLogin setHidden:NO];
    }
    else if ([result objectForKey:@"id"]) {
        // Stop showing the activity view.
        [self stopShowingActivity];
        
        // If the result contains the "id" key then the data have been posted and the id of the published post have been returned.
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Offlane" message:@"Your message has been posted on your wall!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [al show];
        [al release];
        _modalFacebookView.hidden = YES;
    }
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
    
    // Stop the activity just in case there is a failure and the activity view is animating.
    if ([actView isAnimating]) {
        [self stopShowingActivity];
    }
}

-(void)fbDidLogin{
    // Save the access token key info.
    [self saveAccessTokenKeyInfo];
    
    // Get the user's info.
    [facebook requestWithGraphPath:@"me" andDelegate:self];
}

-(void)fbDidNotLogin:(BOOL)cancelled{
    // Keep this for testing purposes.
    //NSLog(@"Did not login");
    
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Offlane" message:@"Login cancelled." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [al show];
    _modalFacebookView.hidden = YES;
}

-(void)fbDidLogout{
    // Keep this for testing purposes.
    //NSLog(@"Logged out");
    
    // Hide the publish button.
    [btnPublish setHidden:YES];
    [btnLogin setHidden:YES];
}

- (IBAction)LoginOrLogout {
    // If the user is not connected (logged in) then connect.
    // Otherwise logout.
    if (!isConnected) {
        [facebook authorize:permissions];
        
        // Change the lblUser label's message.
        [fbTextView setText:@"Add a Comment..."];
    }
    else {
        [facebook logout:self];
        //[fbTextView setText:@"Tap on the Login to connect to Facebook"];
        self.modalFacebookView.hidden = YES;
    }
    
    isConnected = !isConnected;
    [self setLoginButtonImage];
}

- (IBAction)Publish {
    [fbTextView resignFirstResponder];
    // Show the activity indicator.
    [self showActivityView];
    
    // Create the parameters dictionary that will keep the data that will be posted.
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Offlane", @"name",
                                   article.bitlyURL, @"link",
                                   fbArticleTitle.text, @"caption",
                                   fbArticleSummary.text, @"description",
                                   article.imageURL, @"picture",
                                   fbTextView.text, @"message",              
                                   nil];
    
    // Publish.
    // This is the most important method that you call. It does the actual job, the message posting.
    [facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initializeTW];
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
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;

        [mailViewController setSubject:article.title];
        [mailViewController setMessageBody:[NSString stringWithFormat:@"<b>%@</b></br>\n"
                                    "<font color=\"green\">%@</font></br></br>\n"
                                    "<img src=\"%@\"></br></br>"
                                    "%@</br>\n"
                                    "--</br></br>\n"
                                    "<font color=\"green\">OFFLANE</font> for iPad is the FREE digital newsstand you can take with you wherever you go. Just sync and go! read the latest news and blog posts without the need for WiFi or cellular access."
                                    ,article.title,article.bitlyURL,article.imageURL,article.summary]
                                    
                                    isHTML:YES];
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
        
    }
    
    else {
        
        NSLog(@"Device is unable to send email in its current state.");
        
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)touchFacebookArticle:(id)sender
{
    NSLog(@"touchFacebookArticle:");
    
    self.modalTwitterView.hidden = YES;
    self.modalFacebookView.hidden = !self.modalFacebookView.hidden;
    
    // If the user is not connected (logged in) then connect.
    // Otherwise logout.
    if (!isConnected) {
        //Go Online
        [facebook authorize:permissions];
        
        // Change the lblUser label's message.
        [fbTextView setText:@"Add a Comment..."];
        isConnected = !isConnected;
    }
    else {
        //Go Offline
        //[facebook logout:self];
        //[fbTextView setText:@"Tap on the Login to connect to Facebook"];
    }
    
    //isConnected = !isConnected;
    //[self setLoginButtonImage];
    
}

- (IBAction)touchTweetArticle:(id)sender
{
    NSLog(@"touchTweetArticle:");
    
    self.modalFacebookView.hidden = YES;
    self.modalTwitterView.hidden = !self.modalTwitterView.hidden;
    if(![_engine isAuthorized]){  
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
        
        if (controller){  
            [self presentModalViewController: controller animated: YES];  
        }  
    }
    twitterTextView.text = [NSString stringWithFormat:@"Now reading: %@.%@ (via @Offlane)",article.title,article.bitlyURL];
    
}

- (IBAction)touchShareTwitter:(id)sender
{
    //self.modalTwitterView.hidden = YES;
    
    //Dismiss Keyboard
	[twitterTextView resignFirstResponder];
	
    
    if(![_engine isAuthorized]){  
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
        
        if (controller){  
            [self presentModalViewController: controller animated: YES];  
        }  
    }else{
        //Twitter Integration Code Goes Here
        [_engine sendUpdate:twitterTextView.text];
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"tweet sent" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         [alert release];*/
        //tweetTextField.text = @"";
        
    }
}

- (IBAction)touchShareFacebook:(id)sender
{
    self.modalFacebookView.hidden = YES;    
}

- (void) setupFBModal
{
    fbTextView.layer.borderWidth = 1.0f;
    fbTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    fbTextView.textColor = [UIColor grayColor];
    
    fbArticleTitle.text = article.title;
    fbArticleImage.image = article.image;
    fbArticleSummary.text = article.summary;
    
}

- (void) setupTWModal
{
    twitterTextView.layer.borderWidth = 1.0f;
    twitterTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    twitterTextView.textColor = [UIColor grayColor];
    //twitterTextView.text = [NSString stringWithFormat:@"Now reading: %@.%@ (via @Offlane)",article.title,article.bitlyURL];
    twitterArticleTitle.text = article.title;
    twitterArticleImage.image = article.image;
    twitterArticleSummary.text = article.summary;
}

- (void)dealloc {
    [btnLogin release];
    [lblUser release];
    [btnPublish release];
    [actView release];
    [facebook release];
    [permissions release];
    [super dealloc];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
	[theTextField resignFirstResponder];
	return YES;
}

// Twitter

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	//NSLog(@"Request %@ succeeded", requestIdentifier);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet sent successfully!! " message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self.navigationController popViewControllerAnimated:YES];
    self.modalTwitterView.hidden = YES;
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	//NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet Failed" message:[NSString stringWithFormat:@"%@",error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    self.modalTwitterView.hidden = YES;
}


@end
