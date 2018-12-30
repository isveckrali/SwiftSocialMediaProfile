//
//  UserListCell.swift
//  ChallengesiOS
//
//  Created by Flyco Developer on 30.12.2018.
//  Copyright © 2018 Flyco Global. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {

    @IBOutlet var imgViewUser: UIImageView!
    @IBOutlet var lblUserFollowersCount: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblElapsedTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
