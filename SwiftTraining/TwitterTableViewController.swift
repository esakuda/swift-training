//
//  TwitterTableViewController.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit
import Social
import Accounts
import DateTools
import ReactiveCocoa

class TwitterTableViewController: UITableViewController {
    let tableViewModel = TwitterTableViewModel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.tableView)
        tableView.registerNib(UINib(nibName: "TwitterCell", bundle: nil), forCellReuseIdentifier: "TwitterCell")
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 44
        self.tableViewModel.fetchLineTime().startWithNext({
            tweetModel in
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        })

        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewModel.elementsCount()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.tableViewModel.elementsCount()) {
            self.tableViewModel.fetchLineTime()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TwitterCell") as! TwitterCell
        let tweet = self.tableViewModel.elementForIndexPath(indexPath)
        cell.messageTextView.text = tweet.text
//        cell.messageTextView.sizeToFit()
//        cell.messageTextView.layoutIfNeeded()
        cell.userLabel.text = tweet.user
        cell.timeLabel.text = tweet.time.timeAgoSinceNow()
        
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableViewModel.refresh().startWithNext({
            tweetModel in
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }
        })
    }

}
