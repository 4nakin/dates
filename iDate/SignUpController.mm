//
//  SignUpController.m
//  iDate
//
//  Created by Work(')Box on 1/21/13.
//  Copyright (c) 2013 Work(')Box. All rights reserved.
//

#import "SignUpController.h"
#import "MBProgressHUD.h"

@implementation SignUpController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:@"account"];
    if ([account isEqualToString:@"true"])
    {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
    self.genderSignUp.selectedSegmentIndex = 1;
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showError:(NSString*)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error"
        message:errorMessage
        delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [alert show];
}


- (IBAction)removeKeyboard {
    
    //[self.usernameSignUp resignFirstResponder];
}

- (IBAction)signUp:(id)sender {
    
    if (![self.usernameSignUp.text length] > 0)
    {
        [self showError:@"Username cannot be blank."];
    }
    else if (![self.passwordSignUp.text length] > 0)
    {
        [self showError:@"Password cannot be blank."];
    }
    else if (![self.rePasswordSignUp.text length] > 0)
    {
        [self showError:@"Retype Password cannot be blank."];
    }
    else if (![self.rePasswordSignUp.text isEqualToString:self.passwordSignUp.text])
    {
        [self showError:@"The two passwords do not match."];
    } else {
        PFUser *user = [PFUser user];
        user.username = self.usernameSignUp.text;
        user.password = self.passwordSignUp.text;
        
        [user setObject:[self.genderSignUp titleForSegmentAtIndex:self.genderSignUp.selectedSegmentIndex] forKey:@"gender"];
        [user setObject:[self.seekingSignUp titleForSegmentAtIndex:self.seekingSignUp.selectedSegmentIndex] forKey:@"seeking"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __block SignUpController *bself = self;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:bself.usernameSignUp.text forKey:@"username"];
                [userDefaults setObject:@"true" forKey:@"account"];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [bself performSegueWithIdentifier:@"loginSegue" sender:bself];
            } else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                [bself showError:errorString];
                [MBProgressHUD hideHUDForView:self.view animated:YES];

            }
        }];
    }
}
@end
