//
//  IGConnectionDelegate.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGConnectionDelegate : NSObject {
  
	NSMutableData *_data;
	NSURLResponse *_response;
	BOOL done;
	NSError *_error;
	NSURLConnection *_connection;
	
}

- (BOOL) isDone;
- (void) cancel;

@property(nonatomic, strong) NSURLResponse *response;
@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, strong) NSURLConnection *connection;

@end
