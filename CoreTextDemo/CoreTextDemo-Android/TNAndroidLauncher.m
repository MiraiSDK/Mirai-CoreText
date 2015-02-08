//
//  TNAndroidLauncher.m
//  CoreTextDemo-Android
//
//  Created by Chen Yonghui on 2/7/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNAndroidLauncher.h"

extern int main(int argc, char * argv[]);

@implementation TNAndroidLauncher (User)
+ (void)launchWithArgc:(int)argc argv:(char *[])argv
{
    main(argc,argv);
}
@end
