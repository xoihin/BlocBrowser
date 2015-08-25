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
@property (nonatomic, strong) NSArray *labels;
//@property (nonatomic, weak) UILabel *currentLabel;
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
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
//            UILabel *label = [[UILabel alloc] init];
            UIButton *label = [[UIButton alloc]init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
//            label.textAlignment = NSTextAlignmentCenter;
//            label.font = [UIFont systemFontOfSize:10];
//            label.text = titleForThisLabel;
//             label.textColor = [UIColor whiteColor];
            
            label.titleLabel.textAlignment = NSTextAlignmentCenter;
            label.titleLabel.font = [UIFont systemFontOfSize:10];
            [label setTitle:titleForThisLabel forState:UIControlStateNormal];
            label.backgroundColor = colorForThisLabel;
            label.titleLabel.textColor = [UIColor whiteColor];
            
            [label addTarget:self action:@selector(touchDownFired:) forControlEvents:UIControlEventTouchDown];
            [label addTarget:self action:@selector(touchUpFired:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
//        for (UILabel *thisLabel in self.labels) {
        for (UIButton *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
//        
//        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
//        [self addGestureRecognizer:self.tapGesture];
        
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
    
//    for (UILabel *thisLabel in self.labels) {
    
    for (UIButton *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
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

//- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self];
//    UIView *subview = [self hitTest:location withEvent:event];
//    
//    if ([subview isKindOfClass:[UILabel class]]) {
//        return (UILabel *)subview;
//    } else {
//        return nil;
//    }
//}


//- (void) tapFired:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) { // #3
//        CGPoint location = [recognizer locationInView:self]; // #4
//        UIView *tappedView = [self hitTest:location withEvent:nil]; // #5
//        
//        if ([self.labels containsObject:tappedView]) { // #6
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}


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
        NSLog(@"Pinching...");
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:recognizer];
        }
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
        for (UIButton *thisButton in self.labels) {
            NSUInteger currentLabelIndex = [self.labels indexOfObject:thisButton];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentLabelIndex];
            thisButton.backgroundColor = colorForThisLabel ;
        }
    }
}



#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
//        UILabel *label = [self.labels objectAtIndex:index];
        UIButton *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}







@end
