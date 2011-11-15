//
//  IGResponse.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGResponse.h"

@implementation IGResponse

@synthesize body=_body, headers=_headers, statusCode=_statusCode, error=_error;

+ (id)responseFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError {
	return [[self alloc] initFrom:response withBody:data andError:aError];
}

- (void)normalizeError:(NSError *)aError {
	switch ([aError code]) {
		case NSURLErrorUserCancelledAuthentication:
			_statusCode = 401;
      _error = aError;
			break;
		default:
			_error = aError;
			break;
	}
}

- (id)initFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError {
  if ((self = [self init])) {
    _rawBody = data;
    //TODO: parse the data
    if(response) {
      _statusCode = [response statusCode];
      _headers = [response allHeaderFields];		
    }

    [self normalizeError:aError];
  }
	return self;
}

- (BOOL)isSuccess {
	return _statusCode >= 200 && _statusCode < 400;
}

- (BOOL)isError {
	return ![self isSuccess];
}

- (NSString*)debugDescription {
  DLOG(@"<= %@", [[NSString alloc] initWithData:_rawBody encoding:NSUTF8StringEncoding]);
}

@end
