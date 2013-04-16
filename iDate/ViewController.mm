//
//  ViewController.m
//  iDate
//
//  Created by Nathan Kelley on 1/2/13.
//  Copyright (c) 2013 Curiousminds. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.userName.text = [userDefaults objectForKey:@"username"];
    self.contacted = [NSMutableArray array];
    self.callNext = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender {
    
    [self.arrow setHidden:YES];

    int frameHeight = self.mainVideoUIView.frame.size.height;
    int frameWidth = self.mainVideoUIView.frame.size.width;
    int frameX = self.mainVideoUIView.frame.origin.x;

    if ( frameX == 234 ) // If Side bar is open.
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [self.mainVideoUIView setFrame: CGRectMake(0, 0, frameWidth, frameHeight)];
        [UIView commitAnimations];
        
    } else { //Otherwise start a call.
        //If a the user is in a call, Hangup the call
        if ([ShowKit getStateForKey:SHKConnectionStatusKey] == SHKConnectionStatusInCall) {
            self.callNext = YES; //Tell call terminated to call another user, calling the next user will be triggered in connectionStateChanged
            [ShowKit hangupCall];
        } else {
            [self callNextUser];
        }

        [[PFUser currentUser] setObject:@"available" forKey:@"status"];
        [[PFUser currentUser] saveInBackground];
    }
    
}

- (IBAction)login:(id)sender {
    [self.userPassword resignFirstResponder];
    
    __block ViewController *bSelf = self;
    [SHKParseUser logInWithPFUsernameInBackground:self.userName.text password:self.userPassword.text
                                    block:^(PFUser *user, NSError *error, NSString* const connectionStatus) {
                                        if (user)
                                        {
                                            PFUser *user = [PFUser currentUser];
                                            
                                            bSelf.authorized = YES;
                                            [user setObject:@"available" forKey:@"status"];
                                            [user saveInBackground];
                                            
                                            NSString *name = [user objectForKey:@"username"];
                                            bSelf.nameLabel.text = name;
                                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                            [userDefaults setObject:name forKey:@"username"];
                            
                                            bSelf.ageLabel.text = [NSString stringWithFormat:@"%d",[[user objectForKey:@"age"] intValue]];
                                            bSelf.buildLabel.text = [user objectForKey:@"build"];
                                            bSelf.genderLabel.text = [user objectForKey:@"gender"];
                                            bSelf.seekingLabel.text = [user objectForKey:@"seeking"];
                                            
                                        } else {
                                            bSelf.authorized = NO;
                                            [UIView beginAnimations:nil context:NULL];
                                            [UIView setAnimationDuration:1];
                                            bSelf.loginUIView.alpha = 1;
                                            [UIView commitAnimations];
                                        }
                                    }];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    self.loginUIView.alpha = 0.0;
    [UIView commitAnimations];
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender {    
    [self.arrow setHidden:YES];

    int frameHeight = self.mainVideoUIView.frame.size.height;
    int frameWidth = self.mainVideoUIView.frame.size.width;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.mainVideoUIView setFrame: CGRectMake(234, 0, frameWidth, frameHeight)];
    [UIView commitAnimations];

}

- (void) callNextUser {
    if ( self.authorized == YES )
    {
        [[PFUser currentUser] setObject:@"in-call" forKey:@"status"];
        [[PFUser currentUser] save];
        
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"status" equalTo:@"available"];
        [query whereKey:@"showkit_username" notContainedIn:self.contacted];
        NSString *gender = [[PFUser currentUser] objectForKey:@"gender"];
        NSString *seeking = [[PFUser currentUser] objectForKey:@"seeking"];
        [query whereKey:@"seeking" equalTo:gender];
        [query whereKey:@"gender" equalTo:seeking];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                [[PFUser currentUser] setObject:@"available" forKey:@"status"];
                [[PFUser currentUser] saveInBackground];
            } else {
                NSString *userName = [object objectForKey:@"showkit_username"];
                [self.contacted addObject:userName];
                [ShowKit initiateCallWithUser:userName];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [ShowKit setState:self.mainVideoUIView forKey:SHKMainDisplayViewKey];
    [ShowKit setState:self.prevVideoUIView forKey:SHKPreviewDisplayViewKey];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(connectionStateChanged:)
     name:SHKConnectionStatusChangedNotification
     object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [ShowKit setState:nil forKey:SHKMainDisplayViewKey];
    [ShowKit setState:nil forKey:SHKPreviewDisplayViewKey];
}

-(IBAction)removeKeyboard
{
    //[self.userName resignFirstResponder];
}

- (IBAction)logout:(id)sender {
    self.authorized = NO;
    [[PFUser currentUser] setObject:@"off-line" forKey:@"status"];
    __block ViewController *bSelf = self;
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SHKParseUser logOut];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        bSelf.loginUIView.alpha = 1;
        [UIView commitAnimations];

        int frameHeight = self.mainVideoUIView.frame.size.height;
        int frameWidth = self.mainVideoUIView.frame.size.width;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [self.mainVideoUIView setFrame: CGRectMake(0, 0, frameWidth, frameHeight)];
        [UIView commitAnimations];
        
    }];

}

- (IBAction)removeKeyboard:(id)sender {
}

- (void) connectionStateChanged: (NSNotification*) notification
{
    SHKNotification* showNotice ;
    NSString * value ;
    
    showNotice = (SHKNotification*) [notification object];
    value = (NSString*) showNotice.Value;
    PFUser *user = [PFUser currentUser];
    
    if ([value isEqualToString:SHKConnectionStatusCallTerminated]){
        [ShowKit setState:nil forKey:SHKMainDisplayViewKey];
        [ShowKit setState:nil forKey:SHKPreviewDisplayViewKey];
        [ShowKit setState:self.mainVideoUIView forKey:SHKMainDisplayViewKey];
        [ShowKit setState:self.prevVideoUIView forKey:SHKPreviewDisplayViewKey];
        
        NSLog(@"Terminated");
        [user setObject:@"available" forKey:@"status"];
        [user saveInBackground];
        if (self.callNext) {
            self.callNext = NO;
            [self callNextUser];
        }
    } else if ([value isEqualToString:SHKConnectionStatusInCall]) {
        NSLog(@"IN Confference");
    } else if ([value isEqualToString:SHKConnectionStatusLoggedIn]) {
        NSLog(@"Logged in");
    } else if ([value isEqualToString:SHKConnectionStatusNotConnected]) {
        NSLog(@"disconnected");
        [user setObject:@"available" forKey:@"status"];
        [user saveInBackground];
    } else if ([value isEqualToString:SHKConnectionStatusLoginFailed]) {
        NSLog(@"FAil");
    } else if ([value isEqualToString:SHKConnectionStatusCallIncoming]) {
        NSString *incomingUser = (NSString*) showNotice.UserObject;
        NSRange range = [incomingUser rangeOfString:@"."];        
        NSString *incomingUserName = [incomingUser substringFromIndex:range.location + 1];
        [self.contacted addObject:incomingUserName];
        NSLog(@"INcomming");
        [self.arrow setHidden:YES];
        [user setObject:@"in-call" forKey:@"status"];
        [user save];
        [ShowKit acceptCall];
    }
}

- (IBAction)backSignUp:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end