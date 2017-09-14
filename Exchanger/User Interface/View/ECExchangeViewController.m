//
//  ECExchangeViewController.m
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Bolts;
@import SVProgressHUD;

#import "ECBinding.h"

#import "ECExchangePresenter.h"
#import "ECExchangeViewController.h"

#define kSyncInterval 30.0f

@interface ECExchangeViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) ECExchangePresenter *presenter;

@property (weak, nonatomic) IBOutlet UILabel *firstCurrencyLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstCurrencyTextField;
@property (weak, nonatomic) IBOutlet UILabel *firstCurrencyAccountLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *firstCurrencySegmentControl;

@property (weak, nonatomic) IBOutlet UILabel *secondCurrencyLabel;
@property (weak, nonatomic) IBOutlet UITextField *secondCurrencyTextField;
@property (weak, nonatomic) IBOutlet UILabel *secondCurrencyAccountLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *secondCurrencySegmentControl;

@property (nonatomic, strong) NSTimer *syncTimer;

@end

@implementation ECExchangeViewController

- (ECExchangePresenter *)presenter {
  if (!_presenter) {
    _presenter = [ECExchangePresenter new];
  }
  return _presenter;
}

- (void)setupBindings {
  __weak typeof(self) weakSelf = self;
  [self bindObject:self.presenter property:@"firstCurrencyId" withBlock:^(id value) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.firstCurrencyLabel.text = value;
    });
  }];
  [self bindObject:self.presenter property:@"secondCurrencyId" withBlock:^(id value) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.secondCurrencyLabel.text = value;
    });
  }];
  [self bindObject:self.presenter property:@"firstCurrencyAmount" withBlock:^(id value) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.firstCurrencyAccountLabel.text = [NSString stringWithFormat:@"You have %@", value];
    });
  }];
  [self bindObject:self.presenter property:@"secondCurrencyAmount" withBlock:^(id value) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.secondCurrencyAccountLabel.text = [NSString stringWithFormat:@"You have %@", value];
    });
  }];
  [self bindObject:self.presenter property:@"firstCurrencyIndex" withBlock:^(id value) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.firstCurrencySegmentControl.selectedSegmentIndex = [value unsignedIntegerValue];
    });
  }];
  [self bindObject:self.presenter property:@"secondCurrencyIndex" withBlock:^(id value) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.secondCurrencySegmentControl.selectedSegmentIndex = [value unsignedIntegerValue];
    });
  }];
  [self bindObject:self.presenter property:@"firstCurrencyValue" withBlock:^(NSNumber *value) {
    if (weakSelf.firstCurrencyTextField.isFirstResponder) {
      return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([value doubleValue] > 0.0) {
        weakSelf.firstCurrencyTextField.text = [NSString stringWithFormat:@"-%.2f", [value doubleValue]];
      } else {
        weakSelf.firstCurrencyTextField.text = nil;
      }
    });
  }];
  [self bindObject:self.presenter property:@"secondCurrencyValue" withBlock:^(NSNumber *value) {
    if (weakSelf.secondCurrencyTextField.isFirstResponder) {
      return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([value doubleValue] > 0.0) {
        weakSelf.secondCurrencyTextField.text = [NSString stringWithFormat:@"+%.2f", [value doubleValue]];
      } else {
        weakSelf.secondCurrencyTextField.text = nil;
      }
    });
  }];
  [self bindObject:self.presenter property:@"currenciesIds" withBlock:^(NSArray<NSString *> *value) {
    dispatch_async(dispatch_get_main_queue(), ^{
      for (NSUInteger i = 0; i < weakSelf.firstCurrencySegmentControl.numberOfSegments; ++i) {
        [weakSelf.firstCurrencySegmentControl setTitle:value[i] forSegmentAtIndex:i];
        [weakSelf.secondCurrencySegmentControl setTitle:value[i] forSegmentAtIndex:i];
      }
    });
  }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupBindings];
  [self.firstCurrencyTextField addTarget:self
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
  [self.secondCurrencyTextField addTarget:self
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self sync];
  [self.firstCurrencyTextField becomeFirstResponder];
  
  self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:kSyncInterval
                                                    target:self
                                                  selector:@selector(sync)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.syncTimer invalidate];
}

- (void)sync {
  __block BOOL synced = NO;
  
  // We don't need to show HUD if sync is fast
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    if (!synced) {
      [SVProgressHUD show];
    }
  });
  
  [[self.presenter sync] continueWithExecutor:BFExecutor.mainThreadExecutor withBlock:^id _Nullable(BFTask * _Nonnull t) {
    synced = YES;
    [SVProgressHUD dismiss];
    return t;
  }];
}

#pragma mark - Actions

- (IBAction)exchangePressed:(UIBarButtonItem *)sender {
  __weak typeof(self) weakSelf = self;
  [[self.presenter exchangePressed] continueWithExecutor:BFExecutor.mainThreadExecutor withBlock:^id _Nullable(BFTask * _Nonnull t) {
    if (t.error) {
      NSString *msg = @"You don't have enought money to perform this transaction";
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                     message:msg
                                                              preferredStyle:UIAlertControllerStyleAlert];
      [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
      [weakSelf presentViewController:alert animated:YES completion:nil];
    }
    return t;
  }];
}

- (IBAction)currencyIdChanged:(UISegmentedControl *)sender {
  if (sender == self.firstCurrencySegmentControl) {
    [self.presenter updateFirstCurrencyIndex:sender.selectedSegmentIndex];
  } else {
    [self.presenter updateSecondCurrencyIndex:sender.selectedSegmentIndex];
  }
}

- (void)textFieldDidChange:(UITextField *)textField {
  NSString *sign = nil;
  if (textField == self.firstCurrencyTextField) {
    sign = @"-";
  } else {
    sign = @"+";
  }
  
  if ([textField.text isEqualToString:sign]) {
    textField.text = nil;
  } else if (textField.text.length == 1) {
    textField.text = [sign stringByAppendingString:textField.text];
  }
  
  NSString *value = [textField.text stringByReplacingOccurrencesOfString:sign withString:@""];

  NSString *regex = @"^([0-9]*|[0-9]*[.]?[0-9]?[0-9]?)$";
  NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
  BOOL isNumberValid = [test evaluateWithObject:value];
  
  if (!isNumberValid) {
    textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(textField.text.length - 1, 1) withString:@""];
    return;
  }
  
  if (textField == self.firstCurrencyTextField) {
    [self.presenter updateFirstCurrencyValue:value];
  } else {
    [self.presenter updateSecondCurrencyValue:value];
  }
}

@end
