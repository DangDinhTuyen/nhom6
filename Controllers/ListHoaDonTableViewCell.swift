//
//  ListHoaDonTableViewCell.swift
//  Quan Ly Ban Hang Vat Lieu Xay
//
//  Created by MacOS on 5/31/21.
//  Copyright © 2021 DoAnIOS. All rights reserved.
//

import UIKit

class ListHoaDonTableViewCell: UITableViewCell {
    @IBOutlet weak var lbKH: UILabel!
    @IBOutlet weak var lbTien: UILabel!
    @IBOutlet weak var lbNgay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
