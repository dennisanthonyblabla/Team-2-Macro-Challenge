//
//  ProfileInvite.swift
//  Macro Challenge Team2
//
//  Created by Dennis Anthony on 17/10/22.
//

import Foundation
import SnapKit
import UIKit

final class ProfileInvite: UIView {
    var inviteCode: String? {
        didSet {
            self.inviteCodeLabel.text = inviteCode
        }
    }

    private lazy var profileBG: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.kobarDarkGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.kobarGray
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 7
        view.addSubview(profileView)
        view.addSubview(inviteCodeLabel)
        view.addSubview(inviteInstruction)
        return view
    }()
    private lazy var profileView: UIImageView = {
        let imageView = UIImageView()
//        let config = UIImage.SymbolConfiguration(pointSize: 96)
        imageView.contentMode = .scaleAspectFill
        let profile = UIImage(systemName: "person.fill")
        imageView.image = profile?.withTintColor(.kobarBlack, renderingMode: .alwaysOriginal)
        return imageView
    }()
    private lazy var inviteInstruction: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .kobarBlack
        label.font = .regular17
        label.text = "Kode buat ajak temen"
        return label
    }()
    private lazy var inviteCodeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .kobarBlack
        label.font = .bold22
        label.text = inviteCode ?? "Loading"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileBG)
        setupAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAutoLayout() {
        profileBG.snp.makeConstraints { (make) in
            make.width.equalTo(233)
            make.height.equalTo(205)
            make.center.equalToSuperview()
        }
        inviteCodeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(inviteCodeLabel.snp.width)
            make.height.equalTo(inviteCodeLabel.snp.height)
            make.bottom.equalTo(profileBG.snp.bottom).offset(-35)
            make.centerX.equalToSuperview()
        }
        inviteInstruction.snp.makeConstraints { (make) in
            make.width.equalTo(inviteInstruction.snp.width)
            make.height.equalTo(inviteInstruction.snp.height)
            make.bottom.equalTo(inviteCodeLabel.snp.top)
            make.centerX.equalToSuperview()
        }
        profileView.snp.makeConstraints { (make) in
            make.width.equalTo(profileView.snp.width)
            make.height.equalTo(profileView.snp.height)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalTo(inviteInstruction.snp.top).offset(-5)
            make.centerX.equalToSuperview()
        }

    }
}
