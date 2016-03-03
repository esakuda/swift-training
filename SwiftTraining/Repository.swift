//
//  Respository.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/25/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Accounts
import Social
import Result

private let DefaultCount: UInt = 20

protocol TwitterRepositoryType {
    
    func fetchHomeTimeLine(maxID: String?, count: UInt) -> SignalProducer<[Tweet], NSError>
    
}

extension ACAccountStore {
    
    func requestAccessToAccountsWithType(accountType: ACAccountType!, options: [NSObject : AnyObject]!) -> SignalProducer<Bool, NSError> {
        return SignalProducer { observable, _ in
            self.requestAccessToAccountsWithType(accountType, options: options) { success, error in
                if success {
                    observable.sendNext(success)
                    observable.sendCompleted()
                } else {
                    observable.sendFailed(error)
                }
            }
        }
    }
    
}

extension SLRequest {
    
    func performRequest() -> SignalProducer<(NSData, NSURLResponse), NSError> {
        return SignalProducer { observable, _ in
            self.performRequestWithHandler { data, response, error in
                if error == nil {
                    observable.sendNext((data, response))
                    observable.sendCompleted()
                } else {
                    observable.sendFailed(error)
                }
            }
        }
    }
    
}

func JSONObjectWithData<ParseResponse>(data: NSData, options: NSJSONReadingOptions) -> Result<ParseResponse, NSError> {
    let attempt: () throws -> ParseResponse = { try NSJSONSerialization.JSONObjectWithData(data, options: options) as! ParseResponse }
    return Result(attempt: attempt)
}

final class TwitterRepository: TwitterRepositoryType {
    
    typealias AccountProducer = SignalProducer<ACAccount, NSError>
    typealias TwitterRequestProducer = SignalProducer<(NSData, NSURLResponse), NSError>
    typealias JSONProducer = SignalProducer<[JSON], NSError>
    typealias TweetProducer = SignalProducer<[Tweet], NSError>
    
    private let _accountStore: ACAccountStore
    private let _twitterAccountType: ACAccountType
    
    private var twitterAccount: ACAccount? {
        return _accountStore.accountsWithAccountType(_twitterAccountType).last as? ACAccount
    }
    
    init(accountStore: ACAccountStore = ACAccountStore()) {
        _accountStore = accountStore
        _twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    }
    
    
    
    func fetchHomeTimeLine(maxID: String? = Optional.None, count: UInt = DefaultCount) -> TweetProducer {
        return getTwitterAccount()
            .flatMap(.Concat) { self.performTwitterRequest($0, maxID: maxID, count: count) }
            .flatMap(.Concat) { self.parseJSON($0.0) }
            .map { $0.flatMap(Tweet.fromJSON) }
    }

}

private extension TwitterRepository {
    
    func getTwitterAccount() -> AccountProducer {
        return _accountStore.requestAccessToAccountsWithType(_twitterAccountType, options: nil).flatMap(.Concat) { _  -> AccountProducer in
            if let account = self._accountStore.accountsWithAccountType(self._twitterAccountType).last as? ACAccount {
                return SignalProducer(value: account)
            } else {
                return SignalProducer(error: NSError(domain: "", code: 0, userInfo: nil))
            }
        }
    }
    
    func performTwitterRequest(account: ACAccount, maxID: String?, count: UInt) -> TwitterRequestProducer {
        let requestURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        
        var parameters: [String : AnyObject] = [
            "screen_name" : account.username,
            "count" : count
        ]
        if let ID = maxID {
            parameters["max_id"] = ID
        }
        
        let request = SLRequest(forServiceType:SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters)
        request.account = account
        return request.performRequest()

    }
    
    func parseJSON(data: NSData) -> JSONProducer {
        return SignalProducer.attempt { JSONObjectWithData(data, options: []) }
    }
    
}
