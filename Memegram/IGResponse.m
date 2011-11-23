//
//  IGResponse.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGResponse.h"

#import "IGInstagramAPI.h"

NSString * const kIGErrorDomain = @"IGErrorDomain";

@implementation IGResponse

@synthesize rawBody=_rawBody, headers=_headers, statusCode=_statusCode, error=_error;

+ (id)responseFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError {
	return [[self alloc] initFrom:response withBody:data andError:aError];
}

- (void)normalizeError:(NSError *)aError {
  if (!aError) {
    return;
  }
  
	switch ([aError code]) {
		case NSURLErrorUserCancelledAuthentication:
			_statusCode = 401;
      _error = aError;
			break;
    case NSURLErrorCannotFindHost:
    case NSURLErrorCannotConnectToHost:
    case NSURLErrorNetworkConnectionLost:
    case NSURLErrorDNSLookupFailed:
      break;
    case 503: // means 'down for maintenance'
      _error = [NSError errorWithDomain:kIGErrorDomain
                                   code:IGErrorDownForMaintenance
                               userInfo:[NSDictionary dictionaryWithObject:@"Down for maintenance"
                                                                    forKey:NSLocalizedDescriptionKey]];
    case 400:
      _error = [NSError errorWithDomain:kIGErrorDomain
                                   code:IGErrorOAuthException
                               userInfo:[NSDictionary dictionaryWithObject:[[[self parsedBody] objectForKey:@"meta"] objectForKey:@"error_message"]
                                                                    forKey:NSLocalizedDescriptionKey]];
		default:
			_error = aError;
      if ([self parsedBody]) {
        _error = [NSError errorWithDomain:kIGErrorDomain
                                     code:aError.code
                                 userInfo:[NSDictionary dictionaryWithObject:[[[self parsedBody] objectForKey:@"meta"] objectForKey:@"error_message"] 
                                                                      forKey:NSLocalizedDescriptionKey]];
      }
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
    
    // attempt to figure out *some* error if not a successful request
    if ([self isError] && ![self error]) {
      NSString *message = @"An error occurred.";
      if ([self parsedBody]) {
        message = [[[self parsedBody] objectForKey:@"meta"] objectForKey:@"error_message"];
      }
      _error = [NSError errorWithDomain:kIGErrorDomain
                                   code:_statusCode
                               userInfo:[NSDictionary dictionaryWithObject:message
                                                                    forKey:NSLocalizedDescriptionKey]];
    }
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
