//
//  TwitterTableViewController.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import MBProgressHUD
import AlamofireImage

class TwitterTableViewController: UITableViewController {
    let tableViewModel = TwitterTableViewModel.init()
    var loadingHUD: MBProgressHUD!
    var imageViewSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TwitterCell", bundle: nil), forCellReuseIdentifier: "TwitterCell")
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 44
        self.tableViewModel.fetchLineTime()
        self.tableViewModel.loaded.producer.observeOn(UIScheduler()).startWithNext {
            loaded in
            if (loaded) {
                self.tableView.reloadData()
                self.endLoading()
            } else {
                self.startLoading()
            }
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        self.imageViewSize = CGSize(width: 51.0, height: 51.0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewModel.elementsCount()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.tableViewModel.elementsCount() - 1) {
            self.tableViewModel.fetchLineTime()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TwitterCell") as! TwitterCell
        let tweet = self.tableViewModel.elementForIndexPath(indexPath)
        cell.messageTextView.text = tweet.text
        cell.messageTextView.addMentionsStyle()
//        cell.messageTextView.sizeToFit()
//        cell.messageTextView.layoutIfNeeded()
        cell.userLabel.text = tweet.user
        cell.timeLabel.text = tweet.time
        cell.imageView!.af_setImageWithURL(tweet.avatarURL, placeholderImage:UIImage(named: "avatar_placeholder"), filter:AspectScaledToFillSizeCircleFilter(size: self.imageViewSize))
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableViewModel.refresh()
        self.refreshControl?.endRefreshing()
    }
    
    func startLoading() {
        if (self.loadingHUD == nil) {
            self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.tableView, animated:true)
        } else {
            self.loadingHUD.show(true)
        }
    }
    
    func endLoading() {
        self.loadingHUD.hide(true)
    }

}
