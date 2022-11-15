//
//  MainCoordinator.swift
//  Macro Challenge Team2
//
//  Created by Mohammad Alfarisi on 07/11/22.
//

import UIKit
import RxSwift

/// Responsible for navigation when onAuthStateChanged is called
final class AuthCoordinator: BaseCoordinator {
    private let viewModel: AuthViewModel
    private let disposeBag = DisposeBag()
    
    private let navigationController: UINavigationController
    private let makeLoading: () -> UIViewController
    private let makeSignIn: () -> UIViewController
    private let makeMain: (BaseCoordinator, User) -> UIViewController
    
    init(
        _ navigationController: UINavigationController,
        viewModel: AuthViewModel,
        makeLoading: @escaping () -> UIViewController,
        makeSignIn: @escaping () -> UIViewController,
        makeMain: @escaping (BaseCoordinator, User) -> UIViewController
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.makeLoading = makeLoading
        self.makeSignIn = makeSignIn
        self.makeMain = makeMain
    }
    
    override func start() {
        // Bind auth coordinator with auth state from view model
        viewModel.getUserState()
            .distinctUntilChanged()
            .subscribe { [weak self] in self?.onStateChanged($0) }
            .disposed(by: disposeBag)
    }
    
    func onStateChanged(_ state: AuthViewModel.State) {
        switch state {
        case .loading:
            setRootViewController(makeLoading())
        case .unauthenticated:
            setRootViewController(makeSignIn())
        case let .authenticated(user):
            setRootViewController(makeMain(self, user))
        }
    }
    
    private func setRootViewController(_ viewController: UIViewController) {
        navigationController.setViewControllers([viewController], animated: true)
    }
}
