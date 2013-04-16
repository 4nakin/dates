//
//  ViewController.h
//  iDate
//
//  Created by Nathan Kelley on 1/2/13.
//  Copyright (c) 2013 Curiousminds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShowKit/ShowKit.h>
#import <Parse/Parse.h>

@interface ViewController : UIViewController

- (IBAction)connect:(id)sender;

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)login:(id)sender;
- (IBAction)removeKeyboard;
- (IBAction)logout:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;

@property (weak, nonatomic) IBOutlet UIView *prevVideoUIView;
@property (weak, nonatomic) IBOutlet UIView *mainVideoUIView;
@property (weak, nonatomic) IBOutlet UIView *loginUIView;
@property (weak, nonatomic) IBOutlet UIView *profileUIView;

@property (nonatomic, assign) BOOL authorized;
@property (strong, nonatomic) NSMutableArray *contacted;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *seekingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;

@property (assign, nonatomic) bool callNext;

- (IBAction)backSignUp:(id)sender;
@end
