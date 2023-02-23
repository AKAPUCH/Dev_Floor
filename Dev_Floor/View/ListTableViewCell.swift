//
//  ListTableViewCell.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/16.
//

import UIKit
import SnapKit
final class ListTableViewCell: UITableViewCell {
    
    
    lazy var bookmarkStar : UIImageView = {
        let set = UIImageView()
        set.contentMode = .scaleAspectFit //비율 유지
        return set
    }()
    
        let postTitle : UILabel = {
           let set = UILabel()
            set.tintColor = .label
            set.numberOfLines = 2
            set.adjustsFontSizeToFitWidth = true
            set.textAlignment = .left
            return set
        }()
    
//    let postTitle : UITextView  = {
//        let set = UITextView()
//        set.isEditable = false
//        set.textContainer.maximumNumberOfLines = 2
//        set.adjustsFontForContentSizeCategory = true
//        set.font = .systemFont(ofSize: 18)
//        set.sizeToFit()
//        set.isScrollEnabled = false
//
//        return set
//    }()
    
    let postIntroduction : UILabel = {
        let set = UILabel()
        set.tintColor = .label
        set.numberOfLines = 2
        return set
    }()
    
    lazy var stack : UIStackView = {
        let set = UIStackView(arrangedSubviews: [postTitle,postIntroduction])
        set.axis = .vertical
        set.alignment = .fill
        set.distribution = .fill
        
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
        [stack,bookmarkStar].forEach {self.addSubview($0)}
        stack.snp.makeConstraints { make in
            make.leading.height.equalToSuperview()
            make.trailing.equalToSuperview().offset(-30)
        }
        bookmarkStar.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
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
