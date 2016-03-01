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

private let DefaultCount: UInt = 20

protocol TwitterRepositoryType {
    
    func fetchHomeTimeLine(maxID: String?, count: UInt) -> SignalProducer<[Tweet], NSError>
    
}

final class TwitterRepository: TwitterRepositoryType {
    
    private let _accountStore: ACAccountStore
    private let _twitterAccountType: ACAccountType
    
    init(accountStore: ACAccountStore = ACAccountStore()) {
        _accountStore = accountStore
        _twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    }
    
    func getTwitterAccount() -> ACAccount! {
        let arrayOfAccounts = _accountStore.accountsWithAccountType(_twitterAccountType)
        
        if arrayOfAccounts.count > 0 {
            return arrayOfAccounts.last as! ACAccount
        } else {
            return nil
        }
    }
    
    func getAccount() -> SignalProducer<ACAccount, NSError> {
        return SignalProducer {
            sink, disposable in
            self._accountStore.requestAccessToAccountsWithType(self._twitterAccountType, options: nil,
                completion: {(success: Bool, error: NSError!) -> Void in
                    
                    if success {
                        let twitterAccount = self.getTwitterAccount()
                        sink.sendNext(twitterAccount)
                    } else {
                        sink.sendFailed(error)
                    }
            })
        }
    }
    
    func fetchHomeTimeLine(maxID: String? = Optional.None, count: UInt = DefaultCount) -> SignalProducer<[Tweet], NSError> {
        return SignalProducer { sink, disposable in
            self.getAccount().startWithNext({ twitterAccount in
                let requestURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                
                var parameters: [String : AnyObject] = [
                    "screen_name" : twitterAccount.username,
                    "count" : count
                ]
                if let ID = maxID {
                    parameters["max_id"] = ID
                }
                
                let postRequest = SLRequest(forServiceType:
                    SLServiceTypeTwitter,
                    requestMethod: SLRequestMethod.GET,
                    URL: requestURL,
                    parameters: parameters)
                
                postRequest.account = twitterAccount
                
                postRequest.performRequestWithHandler { responseData, _, error in
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves) as? [JSON] {
                            let tweets = jsonResult.map { Tweet.fromJSON($0) }
                            sink.sendNext(tweets)
                        }
                    } catch let error as NSError {
                        sink.sendFailed(error)
                    }
                }
            })
        }
    }

}
