//
//  ListTableViewCell.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/16.
//

import UIKit
import SnapKit
final class ListTableViewCell: UITableViewCell {

    
    lazy var profileImage : UIImageView = {
       let set = UIImageView()
        set.image = UIImage(systemName: "face.smiling")
        return set
    }()
    
    lazy var bookmarkStar : UIImageView = {
       let set = UIImageView()
        
        return set
    }()
    
    let postTitle : UILabel = {
       let set = UILabel()
        set.tintColor = .label
        return set
    }()
    
    let postIntroduction : UILabel = {
        let set = UILabel()
        set.tintColor = .label
        return set
    }()
    
    lazy var stack : UIStackView = {
        let set = UIStackView(arrangedSubviews: [postTitle,postIntroduction])
        set.axis = .vertical
        set.alignment = .fill
        set.distribution = .fill
        set.spacing = 5
        return set
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        [profileImage,stack,bookmarkStar].forEach {self.addSubview($0)}
        profileImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self.snp.height)
        }
        stack.snp.makeConstraints { make in
            make.height.centerY.equalToSuperview()
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
        }
        bookmarkStar.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.lessThanOrEqualTo(profileImage)
            make.trailing.equalToSuperview().offset(-10)
        }
        
    }
    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
