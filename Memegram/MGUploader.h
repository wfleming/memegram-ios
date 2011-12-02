//
//  MGUploader.h
//  Memegram
//
//  Created by William Fleming on 11/18/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Meme;

@interface MGUploader : NSObject


// look for a memegram awaiting upload, and try to upload it.
+ (void) attemptUpload;

// current memegram being uploaded, if available
+ (Meme*) currentUpload;

@end
