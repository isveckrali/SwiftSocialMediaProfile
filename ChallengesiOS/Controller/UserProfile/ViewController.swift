//
//  ViewController.swift
//  ChallengesiOS
//
//  Created by Flyco Developer on 30.12.2018.
//  Copyright © 2018 Flyco Global. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import Toast_Swift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet var topViewTopConstraint: NSLayoutConstraint!
    var oldContentOffSet = CGPoint.zero

    let USER_CELL_LIST_IDENTIFIER:String = "userListCellItentifier"
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableViewUsers: UITableView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblUserDescription: UILabel!
    @IBOutlet var imgViewUserProfile: UIImageView!
    @IBOutlet var imgViewParallaxTop: UIImageView!
    
     let DATE_FORMAT_TYPE_TO_TEXT:String = "yyyy-MM-dd HH:mm:ss"
    
    let CELL_HEİGHT:CGFloat = 64
    
    var userModel:UserModel?
    let listLoadingType:Int = 0
    let BY_TIME_TYPE:Int = 1
    let POPULARITY_TYPE:Int = 2
    
    let SEGMENT_BY_TIME:Int = 0
    let SEGMENT_POPULARITY:Int = 1
    
    var currentDate:Date = Date()
    var sortedData:[Feed]?
    override func viewDidLoad() {
        super.viewDidLoad()
        if Connectivity.isConnectedToInternet() {
        getCurrentTime()
        requestWith(url: Services.USER_PROFILE_PATH)
        } else {
            self.view.makeToast("Please check your internet connection")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func segmentedConrolClicked(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == SEGMENT_BY_TIME {
            sortByDate()
        } else {
            sortByPopularity()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = userModel?.feed {
        return model.count
        }
        return 0
    }
    
    func elapsedTimeCalculater(text:String) -> String{
        
        var elapsedTime:String = ""
        let createdAt = stringConvertToDate(_text: text)
        let diffInMiliSeconds = Calendar.current.dateComponents([.nanosecond], from: createdAt, to: currentDate).nanosecond
        let diffInSeconds = Calendar.current.dateComponents([.second], from: createdAt, to: currentDate).second
        let diffInDays = Calendar.current.dateComponents([.weekday], from: createdAt, to: currentDate).weekday
        let diffInWeek = Calendar.current.dateComponents([.weekOfMonth], from: createdAt, to: currentDate).weekOfMonth
        let diffInMonth = Calendar.current.dateComponents([.month], from: createdAt, to: currentDate).month
        let diffInYear = Calendar.current.dateComponents([.year], from: createdAt, to: currentDate).year

       if diffInYear! != 0 && diffInYear! > 0 {
            elapsedTime = "\(diffInYear!) year ago"

        }
        else if diffInMonth != 0 && diffInMonth! > 0 {
            elapsedTime = "\(diffInMonth!) month ago"

        } else if diffInWeek != 0 && diffInWeek! > 0 {
            elapsedTime = "\(diffInWeek!) week ago"

        } else if diffInDays != 0 && diffInDays! > 0 {
            elapsedTime = "\(diffInDays!) day ago"

        } else if diffInSeconds != 0 && diffInSeconds! > 0 {
            elapsedTime = "\(diffInMiliSeconds!) second ago"

        } else if diffInMiliSeconds != 0 && diffInMiliSeconds! > 0 {
            elapsedTime = "\(diffInMiliSeconds!) nanosecond ago"
        } else {
            elapsedTime = "now"
        }
        
        return elapsedTime
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.USER_CELL_LIST_IDENTIFIER) as! UserListCell
        if (userModel?.feed) != nil {
            cell.lblUserName.text = sortedData![indexPath.row].Name!
            
            cell.lblElapsedTime.text = elapsedTimeCalculater(text: sortedData![indexPath.row].CreatedAt!)
            cell.lblUserFollowersCount.text = sortedData![indexPath.row].FollowerCount!
            cell.imgViewUser.sd_setImage(with: URL(string: sortedData![indexPath.row].photo!))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEİGHT
    }
    
    func requestWith(url:String) {
        Alamofire.request(url)
            .responseJSON { (dataResponse) in
                self.activityIndicator.stopAnimating()
                if dataResponse.result.isSuccess {
                    do  {
                        //print(dataResponse.result.value)
                       self.userModel =  try JSONDecoder().decode(UserModel.self, from: dataResponse.data!)
                        self.sortedData = self.userModel?.feed
                        self.setData()
                    } catch (let error) {
                        self.view.makeToast(error.localizedDescription)
                    }
                } else {
                    self.view.makeToast("Service request is not successful")
                }
        }
    }
    
    func sortByDate() {
        if (userModel?.feed) != nil {
            self.sortedData = (userModel?.feed)!.sorted(by: { stringConvertToDate(_text: $0.CreatedAt!) > stringConvertToDate(_text: $1.CreatedAt!) })
            self.tableViewUsers.reloadData()
        }
    }
    
    func sortByPopularity() {
        if (userModel?.feed) != nil {
        self.sortedData = (userModel?.feed)!.sorted(by: { Int($0.FollowerCount!)! > Int($1.FollowerCount!)! })
            self.tableViewUsers.reloadData()
        }
    }
    
    func setData() {
        if let model = userModel?.user  {
            imgViewParallaxTop.sd_setImage(with: URL(string: (model.coverPhoto!)))
            imgViewUserProfile.sd_setImage(with: URL(string: (model.profilePhoto!)))
        lblUserName.text = model.name!
        lblUserDescription.text = model.bio!
        self.tableViewUsers.reloadData()
        } else {
        
        }   
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let model = self.userModel?.feed {
        let contentOffset  = scrollView.contentOffset.y - oldContentOffSet.y
        
        //scroll up
        if scrollView.contentOffset.y > 0 && contentOffset > 0 {
            
            if topViewTopConstraint.constant >= -256 {
                if tableViewUsers.frame.height <= (CELL_HEİGHT * CGFloat((model.count))) {
                   // print("\(tableViewUsers.frame.height) \((CELL_HEİGHT * CGFloat((model.count))))")
                self.topViewTopConstraint.constant -= contentOffset
                scrollView.contentOffset.y -= contentOffset
                }
            }
        }
        
            // let diffInDays = Calendar.current.dateComponents([.day], from: dateA, to: dateB).day

        //scroll down
        if scrollView.contentOffset.y < 0 && contentOffset < 0 {
            
            if topViewTopConstraint.constant < 0 {
                
                if topViewTopConstraint.constant - contentOffset > 0 {
                    
                    topViewTopConstraint.constant = 0
                } else {
                    topViewTopConstraint.constant -= contentOffset
                }
                scrollView.contentOffset.y -= contentOffset
            }
            
            oldContentOffSet = scrollView.contentOffset
            }
        }
        
    }
    
    //String convert to Date Method
    func stringConvertToDate(_text:String) -> Date {
        let format = DateFormatter()
        format.dateFormat = DATE_FORMAT_TYPE_TO_TEXT
        let convertDate:Date = format.date(from: _text)!
        return convertDate
    }
    
    func getCurrentTime() {
        let format = DateFormatter()
        let date:Date = Date()
        format.dateFormat = DATE_FORMAT_TYPE_TO_TEXT
        let resultDate = format.string(from: date)
        self.currentDate = stringConvertToDate(_text: resultDate)
    }
}

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

