//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Xoi's iMac on 2015-08-21.
//  Copyright (c) 2015 XoiAHin. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"


@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSArray *buttonsArray;
@property (nonatomic, weak) UIButton *currentLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, assign) NSUInteger rotationSequence;


@end



@implementation AwesomeFloatingToolbar


- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = [@[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]] mutableCopy];
        
        // Set for next color rotation in longPressGesture
        self.rotationSequence = 1;
        
        NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
        
        // Make the 4 buttons
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *myButton = [[UIButton alloc]init];
            myButton.userInteractionEnabled = NO;
            myButton.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            myButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            myButton.titleLabel.font = [UIFont systemFontOfSize:10];
            [myButton setTitle:titleForThisLabel forState:UIControlStateNormal];
            myButton.backgroundColor = colorForThisLabel;
            myButton.titleLabel.textColor = [UIColor whiteColor];
            
            [myButton addTarget:self action:@selector(touchDownFired:) forControlEvents:UIControlEventTouchDown];
            [myButton addTarget:self action:@selector(touchUpFired:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [buttonArray addObject:myButton];
        }
        
        self.buttonsArray = buttonArray;
        
        for (UIButton *thisButton in self.buttonsArray) {
            [self addSubview:thisButton];
        }
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}



- (void) layoutSubviews {
    
    // set the frames for the 4 labels
    for (UIButton *thisButton in self.buttonsArray) {
        NSUInteger currentLabelIndex = [self.buttonsArray indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}



#pragma mark - Button Actions

-(void)touchDownFired:(UIButton *)sender
{
    sender.alpha = .9;
}

-(void)touchUpFired:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:sender.titleLabel.text];
    }
}




#pragma mark - Touch Handling


- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"Panning: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}


- (void)pinchFired:(UIPinchGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recognizer scale];
        
        NSLog(@"Pinching: %f", scale);
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
        recognizer.scale = 1;
    }
}



-(void)longPressGestureFired:(UILongPressGestureRecognizer *)recognizer {
    NSLog(@"Long press...");
    
    if (recognizer.state == UIGestureRecognizerStateBegan)  {
        // The four labels are arranged as follows (See layoutSubVew method):
        //  Init=  |0|1|  next rotation: |2|0|  next |3|2| next |1|3|
        //         |2|3|                 |3|1|       |1|0|      |0|2|
        
        // Change array colors to mutable and rotate accordingly in clockwise
        switch (self.rotationSequence) {
            case 0:
                self.colors = [@[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],              // 0
                                 [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],               // 1
                                 [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],              // 2
                                 [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]] mutableCopy]; // 3
                self.rotationSequence = 1;
                break;
                
            case 1:
                self.colors = [@[[UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],              // 2
                                 [UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],              // 0
                                 [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1],               // 3
                                 [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1]] mutableCopy]; // 1
                self.rotationSequence = 2;
                break;

            case 2:
                self.colors = [@[[UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1],                // 3
                                 [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],               // 2
                                 [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],                // 1
                                 [UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1]] mutableCopy]; // 0
                self.rotationSequence = 3;
                break;
                
            case 3:
                self.colors = [@[[UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],                // 1
                                 [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1],                // 3
                                 [UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],               // 0
                                 [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1]] mutableCopy]; // 2
                self.rotationSequence = 0;
                break;
  
            default:
                break;
}
        
        // Apply colors using the rotated-color-array
        for (UIButton *thisButton in self.buttonsArray) {
            NSUInteger currentButtonIndex = [self.buttonsArray indexOfObject:thisButton];
            UIColor *colorFotThisButton = [self.colors objectAtIndex:currentButtonIndex];
            thisButton.backgroundColor = colorFotThisButton ;
        }
    }
}



#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *myButton = [self.buttonsArray objectAtIndex:index];
        myButton.userInteractionEnabled = enabled;
        myButton.alpha = enabled ? 1.0 : 0.25;
    }
}



@end
