//
//  RPAboutBox.h
//  RP HD
//
//  Created by Giacomo Tufano on 16/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPAboutBox : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lVersion;

- (IBAction)OKPressed:(id)sender;

@end
