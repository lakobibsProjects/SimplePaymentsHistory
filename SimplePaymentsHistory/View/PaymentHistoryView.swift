//
//  PaymentHistoryView.swift
//  SimplePaymentsHistory
//
//  Created by user166683 on 2/20/21.
//  Copyright © 2021 Lakobib. All rights reserved.
//

import UIKit

class PaymentHistoryView: UIViewController {
    weak var coordinator: MainCoordinator?
    private var requestService = PaymentHistoryRequestService()
    private var paymentHistory = [PaymentRecord]()
    var token: String?
    var id = 1
    
    private var headerView: UIView!
    private var titleLabel: UILabel!
    private var logoutButton: UIButton!
    private var reloadDataButton: UIButton!
    
    private var paymentHistoryTableView: UITableView!
    
    private var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestService.attach(self)
        
        setupVC()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - Support Functions
    ///setup all views
    private func setupVC(){
        initViews()
        setupViews()
        setupConstraints()
    }
    
    ///initialization and set default state for view and each subview
    private func initViews(){
        self.view.backgroundColor = .white
        
        headerView = UIView()
        titleLabel = UILabel()
        titleLabel.text = "Payment History"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        logoutButton = UIButton()
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        reloadDataButton = UIButton()
        reloadDataButton.setTitle("Reload", for: .normal)
        reloadDataButton.setTitleColor(.black, for: .normal)
        reloadDataButton.addTarget(self, action: #selector(reloadDataButtonPressed), for: .touchUpInside)
        
        paymentHistoryTableView = UITableView()
        paymentHistoryTableView.delegate = self
        paymentHistoryTableView.dataSource = self
        paymentHistoryTableView.register(PaymentRecordTableViewCell.self, forCellReuseIdentifier: "PaymentRecordTableViewCell")
        paymentHistoryTableView.rowHeight = UITableView.automaticDimension
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.isHidden = true
    }
    
    ///Initialize loading data from service
    private func loadData(){
        if let token = token{
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            }
            requestService.paymentHistoryRequest(token: token)
            
        } else{
            let dialogMessage = UIAlertController(title: "Some wrong with authorization", message: "Please logout and try again" , preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            let logout = UIAlertAction(title: "Logout", style: .cancel, handler: { _ in
                self.logoutButtonPressed()
            })
            dialogMessage.addAction(ok)
            dialogMessage.addAction(logout)
            UIApplication.shared.windows.last?.rootViewController?.present(dialogMessage, animated: true)
        }
    }
    
    //MARK: - Event Handlers
    @objc func logoutButtonPressed(){
        self.token = nil
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func reloadDataButtonPressed(){
        loadData()
    }
}

//MARK: - UITableViewDelegate & DataSource
extension PaymentHistoryView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentRecordTableViewCell", for: indexPath) as! PaymentRecordTableViewCell
        cell.configureCell(with: paymentHistory[indexPath.row])
        
        return cell
    }
}

extension PaymentHistoryView: PaymentHistoryRequestObserver{
    
    func update(paymentHistory: [PaymentRecord]) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        
        self.paymentHistory = paymentHistory
        paymentHistoryTableView.reloadData()
    }
    
}

//MARK: - Layout
extension PaymentHistoryView{
    ///setup hierarchy of views
    private func setupViews(){
        self.view.addSubview(headerView)
        self.view.addSubview(paymentHistoryTableView)
        self.view.addSubview(activityIndicator)
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(logoutButton)
        headerView.addSubview(reloadDataButton)
    }
    
    ///set constraints for all views
    private func setupConstraints(){
        headerView.snp.makeConstraints({
            $0.top.equalToSuperview().inset(48)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(108)
        })
        
        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        })
        
        logoutButton.snp.makeConstraints({
            $0.leading.bottom.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.equalToSuperview().multipliedBy(0.4)
        })
        
        reloadDataButton.snp.makeConstraints({
            $0.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.equalToSuperview().multipliedBy(0.4)
        })
        
        paymentHistoryTableView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(48)
            $0.top.equalTo(headerView.snp.bottom).offset(16)
        })
        
        activityIndicator.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.height.equalTo(64)
            $0.width.equalTo(activityIndicator.snp.height)
        })
    }
    
}
