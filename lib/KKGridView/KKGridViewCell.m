//
//  KKGridViewCell.m
//  KKGridView
//
//  Created by Kolin Krewinkel on 7.24.11.
//  Copyright 2011 Giulio Petek, Jonathan Sterling, and Kolin Krewinkel. All rights reserved.
//

#import "KKGridViewCell.h"
#import "KKGridView.h"

@interface KKGridViewCell ()

- (UIImage *)_defaultBlueBackgroundRendition;

@end

@implementation KKGridViewCell {
    UIView *_badgeView;
}

@synthesize accessoryPosition = _accessoryPosition;
@synthesize backgroundView = _backgroundView;
@synthesize contentView = _contentView;
@synthesize editing = _editing;
@synthesize indexPath = _indexPath;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize selected = _selected;
@synthesize accessoryView=_badgeView;
@synthesize selectedBackgroundView = _selectedBackgroundView;


#pragma mark - Class Methods

+ (NSString *)cellIdentifier
{
    return NSStringFromClass([self class]);
}

+ (id)cellForGridView:(KKGridView *)gridView
{
    NSString *cellID = [self cellIdentifier];
    KKGridViewCell *cell = (KKGridViewCell *)[gridView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[self alloc] initWithFrame:(CGRect){ .size = gridView.cellSize } reuseIdentifier:cellID];
    }
    
    return cell;
}

#pragma mark - Designated Initializer

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithFrame:frame])) {
        self.reuseIdentifier = reuseIdentifier;
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backgroundView];
        
        _selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[self _defaultBlueBackgroundRendition]];
        _selectedBackgroundView.hidden = YES;
        _selectedBackgroundView.alpha = 0.f;
        [self addSubview:_selectedBackgroundView];
        [self bringSubviewToFront:_contentView];
    }
    
    return self;
}

#pragma mark - Setters

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [UIView animateWithDuration:KKGridViewDefaultAnimationDuration animations:^{
        self.editing = editing;
    }];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected == YES) {
        _selectedBackgroundView.hidden = !selected;
    }
    
    _selectedBackgroundView.alpha = selected ? 1.f : 0.f;
    for (UIView *view in _contentView.subviews) {
        if ([view respondsToSelector:@selector(setSelected:)]) {
            UIButton *assumedButton = (UIButton *)view;
            assumedButton.selected = selected;
        }
    }
    [self layoutSubviews];        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent) animations:^(void) {
        _selected = selected;
        _selectedBackgroundView.alpha = selected ? 1.f : 0.f;
    } completion:^(BOOL finished) {
        [self layoutSubviews];        
    }];
}

- (void) setAccessoryView:(UIView *)accessoryView {
  if (_badgeView) {
    [_badgeView removeFromSuperview];
  }
  _badgeView = accessoryView;
  [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    _contentView.frame = self.bounds;
    _backgroundView.frame = self.bounds;
    _selectedBackgroundView.frame = self.bounds;
    
    [self sendSubviewToBack:_selectedBackgroundView];
    [self sendSubviewToBack:_backgroundView];
    [self bringSubviewToFront:_contentView];
    
    
    if (_selected) {
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.opaque = NO;
    } else {
        _contentView.backgroundColor = [UIColor lightGrayColor];
    }
    
    _selectedBackgroundView.hidden = !_selected;
    _backgroundView.hidden = _selected;
    
  
  // Handle the accessory view differently ~Will
  if (_badgeView) {
    [_contentView addSubview:_badgeView];
    
    CGSize badgeSize = _badgeView.bounds.size;
    CGFloat edgeOffset = 3.0;
    
    CGPoint point = CGPointZero;
    switch (_accessoryPosition) {
      case KKGridViewCellAccessoryPositionTopRight:
        point = CGPointMake((self.bounds.size.width - badgeSize.width - edgeOffset), edgeOffset);
        break;
      case KKGridViewCellAccessoryPositionTopLeft:
        point = CGPointMake(edgeOffset, edgeOffset);
        break;
      case KKGridViewCellAccessoryPositionBottomLeft:
        point = CGPointMake(edgeOffset, (self.bounds.size.height - badgeSize.height - edgeOffset));
        break;
      case KKGridViewCellAccessoryPositionBottomRight:
        point = CGPointMake((self.bounds.size.width - badgeSize.width - edgeOffset), (self.bounds.size.height - badgeSize.height - edgeOffset));
        break;
      default:
        break;
    }
    
    _badgeView.frame = CGRectMake(point.x,
                                  point.y,
                                  badgeSize.width,
                                  badgeSize.height);
    
    [_contentView bringSubviewToFront:_badgeView];
  }
}

- (UIImage *)_defaultBlueBackgroundRendition
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [UIScreen mainScreen].scale);
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    static const CGFloat colors [] = { 
        0.063f, 0.459f, 0.949f, 1.0f, 
        0.028f, 0.26f, 0.877f, 1.0f
    };
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
    
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, startPoint, endPoint, 0);
    
    CGGradientRelease(gradient), gradient = NULL;
    UIImage *rendition = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rendition;
}

#pragma mark - Subclassers

- (void)prepareForReuse
{
  if (_badgeView) {
    [_badgeView removeFromSuperview];
  }
}

@end
