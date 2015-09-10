//
//  TNImageTestViewController.h
//  
//
//  Created by Chen Yonghui on 9/9/15.
//
//

#import "TNTestViewController.h"

@interface TNImageTestViewController : TNTestViewController


// methods for property 'imageView'
- (void)updateImage;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) BOOL flip;

@end
