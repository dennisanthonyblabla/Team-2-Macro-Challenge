//
//  InviteFriendCoordinator.swift
//  Macro Challenge Team2
//
//  Created by Mohammad Alfarisi on 09/11/22.
//

import UIKit
import RxSwift

final class InviteFriendCoordinator: BaseCoordinator {
    private let viewModel: InviteFriendViewModel
    private let disposeBag = DisposeBag()
    
    private let navigationController: UINavigationController
    private let makeBattleInvitation: (InviteFriendCoordinator, BattleInvitation) -> UIViewController
    private let makeBattle: () -> Coordinator
    private let previousStack: [UIViewController]
    
    init(
        _ navigationController: UINavigationController,
        viewModel: InviteFriendViewModel,
        makeBattleInvitation: @escaping (InviteFriendCoordinator, BattleInvitation) -> UIViewController,
        makeBattle: @escaping () -> Coordinator
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.makeBattleInvitation = makeBattleInvitation
        self.makeBattle = makeBattle
        self.previousStack = navigationController.viewControllers
    }
    
    override func start() {
        viewModel.inviteFriend()
            .subscribe { [weak self] state in self?.onStateChanged(state) }
            .disposed(by: disposeBag)
    }
    
    private func onStateChanged(_ state: InviteFriendViewModel.State) {
        switch state {
        case .loading:
            break
        case let .battleInvitationCreated(battleInvitation):
            show(makeBattleInvitation(self, battleInvitation))
        case .battleFound:
            startNextCoordinator(makeBattle())
        }
    }

    private func show(_ viewController: UIViewController) {
        navigationController.setViewControllers(previousStack + [viewController], animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
        completion?()
    }
}
