//
//  IGResponse.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGResponse.h"

#import "IGInstagramAPI.h"

@implementation IGResponse

@synthesize rawBody=_rawBody, headers=_headers, statusCode=_statusCode, error=_error;

+ (id)responseFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError {
	return [[self alloc] initFrom:response withBody:data andError:aError];
}

- (void)normalizeError:(NSError *)aError {
//  TODO: a 503 means down for maintenance
//  TODO: change error to errors including 'meta' info where possible/appropriate
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

- (NSString*)bodyAsString {
  return [[NSString alloc] initWithData:_rawBody encoding:NSUTF8StringEncoding];
}

- (NSDictionary*) parsedBody {
  if (!_parsedBody) {
    NSError *parseError = nil;
    _parsedBody = [[IGInstagramAPI serializer] deserializeJSON:self.rawBody error:&parseError];
    if (!_parsedBody && parseError) {
      DLOG(@"ERROR parsing response body: %@", parseError);
      DLOG(@"original body was: %@", [self bodyAsString]);
    }
  }
  return _parsedBody;
}

@end
