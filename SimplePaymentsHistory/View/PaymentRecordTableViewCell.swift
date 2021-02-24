//
//  PaymentRecordTableViewCell.swift
//  SimplePaymentsHistory
//
//  Created by user166683 on 2/20/21.
//  Copyright © 2021 Lakobib. All rights reserved.
//

import UIKit

class PaymentRecordTableViewCell: UITableViewCell {
    private var amountLabel = UILabel()
    private var createdLabel = UILabel()
    private var descLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    //MARK: - Support Functions
    ///setup all views
    private func setup(){
        initViews()
        setupViews()
        setupConstraints()
    }
    
    ///initialization and set default state for view and each subview
    private func initViews(){
        self.backgroundColor = .white
        
        descLabel.numberOfLines = 0
    }
    
    
    ///Apply data to content of cell
    ///
    /// - parameter data: payment to display
    func configureCell(with data: PaymentRecord){
        if let currency = data.currency{
            if currency != "\"\""{
                amountLabel.text = "Amount \(data.amount) \(currency)"
            } else{
                amountLabel.text = "Amount \(data.amount) RUB"
            }            
        } else{
            amountLabel.text = "Amount \(data.amount) RUB"
        }
        
        let dateTime = data.created
        let timeInterval = Double(dateTime)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formatedDate = dateFormatter.string(from: date)
        createdLabel.text = "Created at: \(String(describing: formatedDate))"
        
        descLabel.text = data.desc
    }
}

//MARK: - Layout
extension PaymentRecordTableViewCell{
    ///setup hierarchy of views
    private func setupViews(){
        self.addSubview(amountLabel)
        self.addSubview(createdLabel)
        self.addSubview(descLabel)
    }
    
    ///set constraints for all views
    private func setupConstraints(){
        self.amountLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(8)
            $0.height.equalTo(32)
        })
        
        self.createdLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(amountLabel.snp.bottom).offset(8)
            $0.height.equalTo(33)
        })
        
        self.descLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(createdLabel.snp.bottom).offset(8)
            $0.height.greaterThanOrEqualTo(32)
            $0.bottom.equalToSuperview().inset(8)
        })
    }
}
