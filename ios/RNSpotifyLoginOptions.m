//
//  RNSpotifyLoginOptions.m
//  RNSpotify
//
//  Created by Luis Finke on 3/4/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNSpotifyLoginOptions.h"
#import "RNSpotifyUtils.h"
#import "HelperMacros.h"

@implementation RNSpotifyLoginOptions

-(NSURL*)spotifyWebAuthenticationURLWithState:(NSString*)state {
	NSURLComponents* components = [NSURLComponents componentsWithString:@"https://accounts.spotify.com/authorize"];
	NSMutableArray<NSURLQueryItem*>* queryItems = [NSMutableArray array];
	if(_clientID != nil) {
		[queryItems addObject:[NSURLQueryItem queryItemWithName:@"client_id" value:_clientID]];
	}
	if(_tokenSwapURL != nil) {
		[queryItems addObject:[NSURLQueryItem queryItemWithName:@"response_type" value:@"code"]];
	}
	else {
		[queryItems addObject:[NSURLQueryItem queryItemWithName:@"response_type" value:@"token"]];
	}
	if(_redirectURL != nil) {
		[queryItems addObject:[NSURLQueryItem queryItemWithName:@"redirect_uri" value:_redirectURL.absoluteString]];
	}
	if(_scopes != nil && _scopes.count > 0) {
		[queryItems addObject:[NSURLQueryItem queryItemWithName:@"scope" value:[_scopes componentsJoinedByString:@" "]]];
	}
	if(state != nil) {
		[queryItems addObject:[NSURLQueryItem queryItemWithName:@"state" value:state]];
	}
	if(_params != nil) {
		for(NSString* key in _params) {
			id value = _params[key];
			// remove duplicate query item if it exists
			for(NSUInteger i=0; i<queryItems.count; i++) {
				NSURLQueryItem* queryItem = queryItems[i];
				if([queryItem.name isEqualToString:key]) {
					[queryItems removeObjectAtIndex:i];
					break;
				}
			}
			[queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value]];
		}
	}
	components.queryItems = queryItems;
	return components.URL;
}


+(RNSpotifyLoginOptions*)fromDictionary:(NSDictionary*)dict fallback:(NSDictionary*)fallbackDict error:(RNSpotifyError**)error {
	RNSpotifyLoginOptions* options = [[RNSpotifyLoginOptions alloc] init];
	// clientID
	options.clientID = [RNSpotifyUtils getOption:@"clientID" from:dict fallback:fallbackDict];
	if(options.clientID == nil) {
		*error = [RNSpotifyError missingOptionErrorForName:@"clientID"];
		return nil;
	}
	if(![options.clientID isKindOfClass:[NSString class]]) {
		*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"clientID must be a string"];
		return nil;
	}
	// redirectURL
	NSString* redirectURLString = [RNSpotifyUtils getOption:@"redirectURL" from:dict fallback:fallbackDict];
	if(redirectURLString == nil) {
		*error = [RNSpotifyError missingOptionErrorForName:@"redirectURL"];
		return nil;
	}
	if(![redirectURLString isKindOfClass:[NSString class]]) {
		*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"redirectURL must be a string"];
		return nil;
	}
	options.redirectURL = [NSURL URLWithString:redirectURLString];
	if(options.redirectURL == nil) {
		*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"redirectURL is not a valid URL"];
		return nil;
	}
	// scopes
	options.scopes = [RNSpotifyUtils getOption:@"scopes" from:dict fallback:fallbackDict];
	if(options.scopes != nil) {
		if([options.scopes isKindOfClass:[NSNull class]]) {
			options.scopes = nil;
		}
		else if(![options.scopes isKindOfClass:[NSArray class]]) {
			*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"scopes must be an array"];
			return nil;
		}
	}
	// tokenSwapURL
	NSString* tokenSwapURLString = [RNSpotifyUtils getOption:@"tokenSwapURL" from:dict fallback:fallbackDict];
	if(tokenSwapURLString != nil) {
		if([tokenSwapURLString isKindOfClass:[NSNull class]]) {
			tokenSwapURLString = nil;
		}
		else if(![tokenSwapURLString isKindOfClass:[NSString class]]) {
			*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"tokenSwapURL must be a string"];
			return nil;
		}
		else {
			options.tokenSwapURL = [NSURL URLWithString:tokenSwapURLString];
			if(options.tokenSwapURL == nil) {
				*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"tokenSwapURL is not a valid URL"];
				return nil;
			}
		}
	}
	// tokenSwapURL
	NSString* tokenRefreshURLString = [RNSpotifyUtils getOption:@"tokenRefreshURL" from:dict fallback:fallbackDict];
	if(tokenRefreshURLString != nil) {
		if([tokenRefreshURLString isKindOfClass:[NSNull class]]) {
			tokenRefreshURLString = nil;
		}
		else if(![tokenRefreshURLString isKindOfClass:[NSString class]]) {
			*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"tokenRefreshURL must be a string"];
			return nil;
		}
		else {
			options.tokenRefreshURL = [NSURL URLWithString:tokenRefreshURLString];
			if(options.tokenRefreshURL == nil) {
				*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"tokenRefreshURL is not a valid URL"];
				return nil;
			}
		}
	}
	// params
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	NSNumber* showDialog = [RNSpotifyUtils getOption:@"showDialog" from:dict fallback:fallbackDict];
	if(showDialog != nil) {
		if(![showDialog isKindOfClass:[NSNumber class]]) {
			*error = [RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadParameter message:@"showDialog must be a boolean"];
			return nil;
		}
		params[@"show_dialog"] = showDialog.boolValue ? @"true" : @"false";
	}
	options.params = params;
	
	return options;
}

@end
