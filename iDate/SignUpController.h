//
//  SignUpController.h
//  iDate
//
//  Created by Work(')Box on 1/21/13.
//  Copyright (c) 2013 Work(')Box. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShowKit/ShowKit.h>
#import <Parse/Parse.h>

@interface SignUpController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameSignUp;
@property (weak, nonatomic) IBOutlet UITextField *passwordSignUp;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordSignUp;

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSignUp;
@property (weak, nonatomic) IBOutlet UISegmentedControl *seekingSignUp;

- (IBAction)removeKeyboard:(id)sender;


- (IBAction)signUp:(id)sender;
@end
