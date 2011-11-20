//
//  Memegram.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "Memegram.h"

#import "MemegramAPI.h"
#import "MGConnection.h"
#import "IGResponse.h"
#import "IGDefaultSerializer.h"
#import <Twitter/Twitter.h>
#import "MGAccountHelper.h"
#import "IGInstagramAPI.h"
#import "IGInstagramUser.h"
#import "MGUploader.h"

@interface Memegram (Sharing)
- (void) doSharing;
- (void) doTwitterShare;
- (NSString*) statusForTwitter;
@end


#pragma mark -
@implementation Memegram

@dynamic caption;
@dynamic instagramSourceId;
@dynamic instagramSourceLink;
@dynamic memegramId;
@dynamic image;
@dynamic userId;
@dynamic shareToTwitter;
@dynamic shareToTumblr;
@dynamic shareToFacebook;
@dynamic link;


- (BOOL) uploadError:(NSError* __autoreleasing*)error {
  NSMutableURLRequest *request = [MGConnection requestForMethod:@"POST" to:[MemegramAPI urlForEndpoint:@"/memegrams"]];
  [request setTimeoutInterval:180.0]; // images over something like EDGE could be really painful, and this is in the background anyway
  
  NSString *boundary = @"MG01WF314x";
  NSString* contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
  [request setValue:contentType forHTTPHeaderField: @"Content-type"];
  NSData* boundaryMarker = [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
  NSMutableData *body = [NSMutableData data];
  
  [body appendData:boundaryMarker];
  [body appendData:[@"Content-Disposition: form-data; name=\"memegram\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[self uploadRepresentation]];
  
  if (self.image) {
    [body appendData:boundaryMarker];
    [body appendData:[@"Content-Disposition: form-data; name=\"imageData\"; filename=\"memegram.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImageJPEGRepresentation(self.image, 1.0)];
  }
  
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  [request setHTTPBody:body];
  
  IGResponse *response = [MGConnection sendRequest:request];
  
  BOOL success = [response isSuccess];
  
  if (!success) {
    if (error) {
      DLOG(@"UPLOAD FAILED.\n\terror => %@,\n\tbody => %@",
           [response error],
           [[NSString alloc] initWithData:[response rawBody] encoding:NSUTF8StringEncoding]);
      *error = [response error];
    }
  } else {
    DLOG(@"UPLOAD SUCCEEDED of %@", self);
    [self updateFromJSON:[response parsedBody]];
    
    [self doSharing];
  }
  
  return success;
}

- (NSData*) uploadRepresentation {
  NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];

  if (self.caption) {
    [attrs setObject:self.caption forKey:@"caption"];
  }
  if (self.instagramSourceId) {
    [attrs setObject:self.instagramSourceId forKey:@"instagram_source_id"];
  }
  if (self.instagramSourceLink) {
    [attrs setObject:self.instagramSourceLink forKey:@"instagram_source_link"];
  }
  if (self.userId) {
    [attrs setObject:self.userId forKey:@"user_id"];
  }
  
  NSError *err = nil;
  NSData *result = [IGDefaultSerializer serializeJSON:attrs error:&err];
  if (err) {
    DLOG(@"serializing failed: %@", err);
  }
  
  return result;
}


- (void) updateFromJSON:(NSDictionary*)json {
  DASSERT([json isKindOfClass:[NSDictionary class]]);
  
  NSDictionary *attrs = [json objectForKey:@"meme"];
  
  if (nil != [attrs objectForKey:@"id"] && [NSNull null] != [attrs objectForKey:@"id"]) {
    self.memegramId = [attrs objectForKey:@"id"];
  }
  
  if (nil != [attrs objectForKey:@"user_id"] && [NSNull null] != [attrs objectForKey:@"user_id"]) {
    self.userId = [attrs objectForKey:@"user_id"];
  }
  
  if (nil != [attrs objectForKey:@"caption"] && [NSNull null] != [attrs objectForKey:@"caption"]) {
    self.caption = [attrs objectForKey:@"caption"];
  }
  
  if (nil != [attrs objectForKey:@"instagram_source_id"] && [NSNull null] != [attrs objectForKey:@"instagram_source_id"]) {
    self.instagramSourceId = [attrs objectForKey:@"instagram_source_id"];
  }
  
  if (nil != [attrs objectForKey:@"instagram_source_link"] && [NSNull null] != [attrs objectForKey:@"instagram_source_link"]) {
    self.instagramSourceLink = [attrs objectForKey:@"instagram_source_link"];
  }
  
  if (nil != [attrs objectForKey:@"link"] && [NSNull null] != [attrs objectForKey:@"link"]) {
    self.link = [attrs objectForKey:@"link"];
  }
}

- (BOOL) isUploaded {
  return (nil != self.memegramId);
}

- (BOOL) isUploading {
  return (self == [MGUploader currentUpload]);
}

- (BOOL) isWaitingForUpload {
  return (![self isUploaded] && ![self isUploading]);
}

@end


#pragma mark -
@implementation Memegram (Sharing)
- (void) doSharing {
  if (!self.link) { // fatal to sharing
    DASSERT(self.link);
    return;
  }
  
  if ([self.shareToTwitter boolValue]) {
    [self doTwitterShare];
  }
}

- (void) doTwitterShare {
  TWRequest *postRequest = [[TWRequest alloc] initWithURL:
                            [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] 
                                               parameters:[NSDictionary dictionaryWithObject:[self statusForTwitter] 
                                                                                      forKey:@"status"] requestMethod:TWRequestMethodPOST];
  
  [postRequest setAccount:[MGAccountHelper defaultTwitterAccount]];
  
  // Block handler to manage the response
  [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
   {
     if ([urlResponse statusCode] > 300) {
       DLOG(@"twitter post failed (status %d): data => %@\nerror => %@",
            [urlResponse statusCode],
            [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding],
            error);
     }
   }];
}

- (NSString*) statusForTwitter {
  // 20 for the URL, 1 for a space.
  const int maxLength = (140 - 20 - 1);
  
  NSString *status = self.caption;
  
  if ((nil == status) || 0 == [status length]) {
    status = [NSString stringWithFormat:@"A memegram by %@.", [IGInstagramAPI currentUser].username];
  }
  
  if ([status length] > maxLength) {
    status = [NSString stringWithFormat:@"%@...", [status substringToIndex:(maxLength - 3)]];
  }
  
  status = [NSString stringWithFormat:@"%@ %@", status, self.link];
  
  return status;
}
@end