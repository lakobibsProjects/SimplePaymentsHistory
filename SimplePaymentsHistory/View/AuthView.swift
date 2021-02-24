//
//  AuthView.swift
//  SimplePaymentsHistory
//
//  Created by user166683 on 2/20/21.
//  Copyright © 2021 Lakobib. All rights reserved.
//

import UIKit
import SnapKit

class AuthView: UIViewController, AuthObserver {
    weak var coordinator: MainCoordinator?
    var id = 1
    private var authRequestService = AuthRequestService()
    
    private var loginView: UIView!
    private var loginTextField: UITextField!
    private var passwordTextField: UITextField!
    private var loginButton: UIButton!
    
    private var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        authRequestService.attach(self)
        
        setupVC()
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
        
        loginView = UIView()
        loginTextField = UITextField()
        loginTextField.placeholder = "  login"
        loginTextField.layer.borderWidth = 1
        loginTextField.layer.borderColor = UIColor.lightGray.cgColor
        loginTextField.layer.cornerRadius = 8
        passwordTextField = UITextField()
        passwordTextField.placeholder = "  password"
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.cornerRadius = 8
        loginButton = UIButton()
        loginButton.setTitle("Log in", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.addTarget(self, action: #selector(loginButonPressed), for: .touchUpInside)
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.isHidden = true
    }
    
    //AuthObserver functions
    func update(result: Bool, token: String?, error: String?) {
        DispatchQueue.main.async{
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        if result{
            if let token = token{
                print(token)
                coordinator?.paymentHistory(token: token)
            }else{
                let dialogMessage = UIAlertController(title: "Authorization failed", message: error ?? "" , preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                dialogMessage.addAction(ok)
                UIApplication.shared.windows.last?.rootViewController?.present(dialogMessage, animated: true)
            }
        }else{
            let dialogMessage = UIAlertController(title: "Authorization failed", message: error ?? "" , preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            dialogMessage.addAction(ok)
            UIApplication.shared.windows.last?.rootViewController?.present(dialogMessage, animated: true)
        }
    }
    
    //MARK: - Event Handlers
    @objc func loginButonPressed(){
        if let login = loginTextField.text, let password = passwordTextField.text{
            if !login.isEmpty && !password.isEmpty{
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                authRequestService.authRequest(login: login, password: password)
            } else{
                let dialogMessage = UIAlertController(title: "", message: "Login and password cannot be empty" , preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                dialogMessage.addAction(ok)
                UIApplication.shared.windows.last?.rootViewController?.present(dialogMessage, animated: true)
            }
        } else{
            let dialogMessage = UIAlertController(title: "", message: "Login and password cannot be empty" , preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            dialogMessage.addAction(ok)
            UIApplication.shared.windows.last?.rootViewController?.present(dialogMessage, animated: true)
        }
    }
}

//MARK: - Layout
extension AuthView{
    ///setup hierarchy of views
    private func setupViews(){
        self.view.addSubview(loginView)
        self.view.addSubview(activityIndicator)
        
        loginView.addSubview(loginTextField)
        loginView.addSubview(passwordTextField)
        loginView.addSubview(loginButton)
    }
    
    ///set constraints for all views
    private func setupConstraints(){
        loginView.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(144)
        })
        
        loginTextField.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.top.equalToSuperview().inset(8)
        })
        
        passwordTextField.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.top.equalTo(loginTextField.snp.bottom).offset(8)
        })
        
        loginButton.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(1.2)
            $0.height.equalTo(48)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().inset(8)
        })
        
        activityIndicator.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.height.equalTo(64)
            $0.width.equalTo(activityIndicator.snp.height)
        })
    }
}
