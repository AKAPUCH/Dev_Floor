//
//  ButtonView.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/16.
//

import UIKit
import SnapKit
class ButtonView: UIView {

    
    lazy var button1 : UIButton = createButton()
    lazy var button2 : UIButton = createButton()
    lazy var button3 : UIButton = createButton()
    lazy var button4 : UIButton = createButton()
    
    
    lazy var stack : UIStackView = {
        let stacks = UIStackView(arrangedSubviews: [button1,button2,button3,button4])
        stacks.axis = .vertical
        stacks.spacing = 30
        stacks.distribution = .fillEqually
        stacks.alignment = .fill
        stacks.translatesAutoresizingMaskIntoConstraints = false
        return stacks
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let round = button1.frame.height / 4
        button1.layer.cornerRadius = round
        button2.layer.cornerRadius = round
        button3.layer.cornerRadius = round
        button4.layer.cornerRadius = round
    }
    
    func createButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 25.0)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        button.layer.borderWidth = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }
    
    func setUI() {
        self.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(100)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-150)
        }
    }
    

    
    
    

}
