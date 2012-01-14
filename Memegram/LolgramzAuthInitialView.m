//
//  LolgramzAuthInitialView.m
//  Memegram
//
//  Created by William Fleming on 12/2/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "LolgramzAuthInitialView.h"

#import "WFIGAuthController.h"

@implementation LolgramzAuthInitialView {
  WFIGAuthController *_controller;
  IBOutlet UIButton *_nextButton;
}

- (id) initWithController:(WFIGAuthController*)controller {
  NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"AuthView" owner:self options:nil];
  self = [objects objectAtIndex:0];
  self->_controller = controller;
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction) nextButtonTapped:(id)sender {
  [_controller gotoInstagramAuthURL:self];
}
@end
