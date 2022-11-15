//
//  BattleCoordinator.swift
//  Macro Challenge Team2
//
//  Created by Mohammad Alfarisi on 10/11/22.
//

import UIKit
import RxSwift

final class BattleCoordinator: BaseCoordinator {
    private let viewModel: BattleViewModel
    private let disposeBag = DisposeBag()
    
    private let navigationController: UINavigationController
    private let makeCountdown: (Battle) -> UIViewController
    private let makeBattle: (BattleCoordinator, Battle) -> UIViewController
    private let makeDocumentation: () -> UIViewController
    private let previousStack: [UIViewController]
    
    init(
        _ navigationController: UINavigationController,
        viewModel: BattleViewModel,
        makeCountdown: @escaping (Battle) -> UIViewController,
        makeBattle: @escaping (BattleCoordinator, Battle) -> UIViewController,
        makeDocumentation: @escaping () -> UIViewController
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.makeCountdown = makeCountdown
        self.makeBattle = makeBattle
        self.makeDocumentation = makeDocumentation
        
        self.previousStack = navigationController.viewControllers
    }
    
    override func start() {
        viewModel.state
            .subscribe { [weak self] in self?.onStateChanged($0) }
            .disposed(by: disposeBag)
    }
    
    private func onStateChanged(_ state: BattleViewModel.State) {
        switch state {
        case .loading:
            break
        case .canceled:
            break
        case let .countdown(battle):
            show(makeCountdown(battle))
        case let .battle(battle):
            show(makeBattle(self, battle))
        case .finished:
            break
        }
    }
    
    func showDocumentation() {
        present(makeDocumentation())
    }
    
    private func pop() {
        navigationController.popViewController(animated: true)
    }
    
    private func show(_ viewController: UIViewController) {
        navigationController.setViewControllers(previousStack + [viewController], animated: true)
    }
    
    private func present(_ viewController: UIViewController) {
        navigationController.present(viewController, animated: true)
    }
}
