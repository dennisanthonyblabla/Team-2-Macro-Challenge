//
//  BattlefieldVC.swift
//  Macro Challenge Team2
//
//  Created by Dennis Anthony on 02/11/22.
//

import UIKit
import SnapKit
import RxSwift
import SwiftUI

// TODO: implement update statusLabel
// TODO: implement run code popup
// TODO: @dennis refactor BattleContohStackView to new file
final class BattlefieldPageViewController: UIViewController {
    private lazy var snippets: [SnippetModel] = {
        var snippets: [SnippetModel] = []
        snippets.append(SnippetModel(title: "baca", snippet: "baca _"))
        snippets.append(SnippetModel(title: "tulis", snippet: "tulis _"))
        snippets.append(SnippetModel(title: "ulangin", snippet: "ulangin _ dari _ sampe _\n\t_\nyaudah"))
        snippets.append(
            SnippetModel(
                title: "ulangin longkap",
                snippet: "ulangin _ dari _ sampe _ longkap _\n\t_\nyaudah"
            )
        )
        snippets.append(SnippetModel(title: "selama", snippet: "selama _\n\t_\nyaudah"))
        snippets.append(SnippetModel(title: "kalo", snippet: "kalo _\n\t_\nyaudah"))
        snippets.append(SnippetModel(title: "kalogak", snippet: "kalogak _ \n\t_\n"))
        snippets.append(SnippetModel(title: "lainnya", snippet: "lainnya\n\t_"))
        snippets.append(SnippetModel(title: "yaudah", snippet: "yaudah"))
        snippets.append(SnippetModel(title: "dan", snippet: "dan"))
        snippets.append(SnippetModel(title: "atau", snippet: "atau"))
        snippets.append(SnippetModel(title: "bukan", snippet: "bukan"))
        snippets.append(SnippetModel(title: "itu", snippet: "itu"))
        snippets.append(SnippetModel(title: "benar", snippet: "benar"))
        snippets.append(SnippetModel(title: "salah", snippet: "salah"))
        snippets.append(SnippetModel(title: "+", snippet: "+"))
        snippets.append(SnippetModel(title: "-", snippet: "-"))
        snippets.append(SnippetModel(title: "*", snippet: "*"))
        snippets.append(SnippetModel(title: "/", snippet: "/"))
        snippets.append(SnippetModel(title: "%", snippet: "%"))
        snippets.append(SnippetModel(title: "==", snippet: "=="))
        snippets.append(SnippetModel(title: "!=", snippet: "!="))
        return snippets
    }()
    
    private let keyboard: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            KeyboardCollectionViewCell.self,
            forCellWithReuseIdentifier: KeyboardCollectionViewCell.identifier
        )
        collectionView.backgroundColor = .kobarGrayKeyboard
        
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var statusDesc: String?
    
    weak var runCodeViewModel: RunCodeViewModel?
    private let disposeBag = DisposeBag()
    
    var onSubmitCode: ((SubmitCodeSubmission) -> Void)?
    var onShowDocumentation: (() -> Void)?
    
    var userName = ""
    var opponentName = ""
    var battleEndDate = Date.now
    var problem: Problem = .empty()
    
    var code = ""

    private lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = .kobarDarkBlueBG
        return view
    }()

    private lazy var backgroundFront: UIView = {
        let view = UIView()
        view.backgroundColor = .kobarBlueActive
        return view
    }()

    private lazy var backgroundStatus: UIView = {
        let view = UIView()
        view.backgroundColor = .kobarBlueBG
        return view
    }()

    private lazy var statusBG: UIView = {
        let view = UIView()
        view.backgroundColor = .kobarDarkBlueBG
        view.layer.cornerRadius = 20.5
        view.addSubview(statusLabel)
        return view
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tenang! Lawan lo masih ngerjain kok"
        label.font = .regular17
        label.textColor = .white
        return label
    }()

    private lazy var hourglass: UILabel = {
        let label = UILabel()
        label.text = "⌛️"
        label.font = .semi36
        return label
    }()

    private lazy var timeLeftLabel: CountdownLabelView = {
        let label = CountdownLabelView(endDate: battleEndDate)
        
        label.onCountdownFinished = {
            let submission = SubmitCodeSubmission(code: self.code)
            self.onSubmitCode?(submission)
        }
        
        label.textColor = .white
        label.textAlignment = .left
        label.font = .bold36
        return label
    }()

    private lazy var nameCard: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "versusNameCard")
        return view
    }()

    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = userName
        label.font = .bold22
        label.textColor = .kobarBlack
        label.textAlignment = .left
        return label
    }()

    private lazy var opponentNameLabel: UILabel = {
        let label = UILabel()
        label.text = opponentName
        label.font = .bold22
        label.textColor = .kobarBlack
        label.textAlignment = .left
        return label
    }()

    private lazy var pertanyaanCard: CardView = {
        let card = CardView(type: .pertanyaan)
        let string = NSMutableAttributedString()
            .appendWithFont("\(problem.prompt) \n\n", font: .regular17)
            .appendWithFont("Input Format \n", font: .bold17)
            .appendWithFont("\(problem.inputFormat) \n\n", font: .regular17)
            .appendWithFont("Output Format \n", font: .bold17)
            .appendWithFont("\(problem.outputFormat) \n\n", font: .regular17)
        
        card.attributedText = string
        
        return card
    }()
    
    private lazy var ngodingYukCard: CardView = {
        let card = CardView(type: .codingCard)
        
        card.onTextChanged = { code in
            self.code = code
        }
        
        return card
    }()
    
    private lazy var ujiKodinganView: UjiKodinganView = {
        let view = UjiKodinganView()
        
        view.onRunCode = { [weak self, problem] input in
            guard let self = self else { return }
            let submission = RunCodeSubmission(code: self.code, input: input)
            self.runCodeViewModel?.runCode(submission: submission, problemId: problem.id)
        }
        
        runCodeViewModel?.runCodeResult
            .subscribe { [weak view] result in
                view?.updateCodeOutput(result: result)
            }
            .disposed(by: disposeBag)
        
        view.onSubmitCode = { _ in
            let submission = SubmitCodeSubmission(code: self.code)
            self.onSubmitCode?(submission)
        }

        return view
    }()

    private lazy var contohBGInput: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMinXMaxYCorner]
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.kobarBorderGray.cgColor
        view.addSubview(contohTextInput)
        return view
    }()

    private lazy var contohBGOutput: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMaxYCorner]
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.kobarBorderGray.cgColor
        view.addSubview(contohTextOutput)
        return view
    }()

    private lazy var contohTextInput: UITextView = {
        let textView = UITextView.init()
        textView.textColor = .kobarBlack
        textView.font = UIFont.regular17
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.alpha = 0
        return textView
    }()

    private lazy var contohTextOutput: UITextView = {
        let textView = UITextView.init()
        textView.textColor = .kobarBlack
        textView.font = UIFont.regular17
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.alpha = 0
        return textView
    }()

    private lazy var contohBGStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [contohBGInput, contohBGOutput]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var ujiKodinganBtn: SmallButtonView = {
        let btn = SmallButtonView(
            variant: .variant2,
            title: "Uji Kodingan")
        return btn
    }()
    
    private lazy var tipsBtn: SmallIconButtonView = {
        let btn = SmallIconButtonView(variant: .variant2, buttonImage: UIImage(systemName: "book.fill"))
        btn.addVoidAction(onShowDocumentation, for: .touchUpInside)
        return btn
    }()

    private lazy var examples: [BattleContohView] = {
        var contoh: [BattleContohView] = []
        var previousBtn: Int?
        var currentBtn: Int?
        for i in 0..<problem.exampleCount {
            contoh.append(
                BattleContohView(
                    title: "Contoh " + "(\(i + 1))",
                    image: "chevron.down",
                    selected: .notSelected))
        }
        
        for (index, i) in contoh.enumerated() {
            let testCase = problem.testCases[index]
            i.addAction(
                UIAction { [self]_ in
                currentBtn = index
                    for each in contoh {
                        each.isItSelected = .notSelected
                    }
                if previousBtn == currentBtn {
                    contohBGStackView.snp.updateConstraints { make in
                        make.height.equalTo(0)
                    }
                    animationTransparency(view: contohTextInput, alpha: 0)
                    animationTransparency(view: contohTextOutput, alpha: 0)
                    i.isItSelected = .notSelected
                    animationLayout()
                    currentBtn = nil
                } else {
                    contohBGStackView.snp.updateConstraints { make in
                        make.height.equalTo(200)
                    }
                    contohTextInput.text = testCase.input
                    contohTextOutput.text = testCase.output
                    animationTransparency(view: contohTextInput, alpha: 1)
                    animationTransparency(view: contohTextOutput, alpha: 1)
                    i.isItSelected = .selected
                    animationLayout()
                }
                previousBtn = currentBtn
                }, for: .touchUpInside)
        }
        return contoh
    }()

    private lazy var contohStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: examples)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = CGFloat(problem.exampleCount)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .bottom
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboard.dataSource = self
        keyboard.delegate = self
        
        view.addSubview(background)
        view.addSubview(backgroundFront)
        view.addSubview(backgroundStatus)
        view.addSubview(statusBG)
        view.addSubview(pertanyaanCard)
        view.addSubview(ngodingYukCard)
        view.addSubview(ujiKodinganBtn)
        view.addSubview(tipsBtn)
        view.addSubview(nameCard)
        view.addSubview(hourglass)
        view.addSubview(timeLeftLabel)
        view.addSubview(userNameLabel)
        view.addSubview(opponentNameLabel)
        view.addSubview(contohStackView)
        view.addSubview(contohBGStackView)
        view.addSubview(ujiKodinganView)
        view.addSubview(keyboard)

        setupBackground()
        setupDisplays()
        setupComponents()
        setupButtonFunction()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue {
            ngodingYukCard.snp.remakeConstraints { make in
                make.top.equalTo(pertanyaanCard)
                make.bottom.equalToSuperview().offset(-(keyboardSize.height + 70 + 10))
                make.trailing.equalTo(backgroundFront).offset(-16)
                make.leading.equalTo(backgroundFront.snp.centerX).offset(8)
            }
            keyboard.snp.remakeConstraints { make in
                make.height.equalTo(70)
                make.width.equalToSuperview()
                make.bottom.equalToSuperview().offset(-keyboardSize.height)
            }
            animationLayout()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        ngodingYukCard.snp.remakeConstraints { make in
            make.top.equalTo(pertanyaanCard)
            make.bottom.equalTo(keyboard.snp.top).offset(-10)
            make.trailing.equalTo(backgroundFront).offset(-16)
            make.leading.equalTo(backgroundFront.snp.centerX).offset(8)
        }
        keyboard.snp.remakeConstraints { make in
            make.height.equalTo(70)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        animationLayout()
    }
    
    func updateRunCodeResult(result: RunCodeResult) {
        ujiKodinganView.updateCodeOutput(result: result)
    }
}

extension BattlefieldPageViewController {
    /// For all Constraints
    private func setupBackground() {
        background.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        }
        backgroundFront.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(background).offset(8)
        }
        backgroundStatus.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        statusBG.snp.makeConstraints { make in
            make.height.equalTo(statusLabel).offset(20)
            make.width.equalTo(statusLabel).offset(48)
            make.centerX.equalTo(nameCard)
            make.top.equalTo(nameCard.snp.bottom)
        }
        ujiKodinganView.snp.makeConstraints { make in
            make.leading.equalTo(backgroundFront.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.bottom.equalTo(backgroundFront)
        }
    }

    private func setupDisplays() {
        nameCard.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundFront)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-10)
        }
        statusLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        hourglass.snp.makeConstraints { make in
            make.leading.equalTo(pertanyaanCard)
            make.bottom.equalTo(pertanyaanCard.snp.top)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        timeLeftLabel.snp.makeConstraints { make in
            make.leading.equalTo(hourglass.snp.trailing).offset(20)
            make.centerY.equalTo(hourglass)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameCard).offset(-4)
            make.leading.equalTo(nameCard).offset(50)
            make.width.equalTo(125)
        }
        opponentNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameCard).offset(-4)
            make.leading.equalTo(nameCard.snp.centerX).offset(40)
            make.width.equalTo(125)
        }
        contohTextInput.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15).priority(750)
            make.height.greaterThanOrEqualTo(100)
        }
        contohTextOutput.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15).priority(750)
            make.height.greaterThanOrEqualTo(100)
        }
    }

    private func setupComponents() {
        pertanyaanCard.snp.makeConstraints { make in
            make.top.equalTo(statusBG.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(backgroundFront.snp.centerX).offset(-8)
            make.bottom.equalTo(contohStackView.snp.top).offset(-23)
        }
        ngodingYukCard.snp.makeConstraints { make in
            make.top.equalTo(pertanyaanCard)
            make.bottom.equalTo(keyboard.snp.top).offset(-10)
            make.trailing.equalTo(backgroundFront).offset(-16)
            make.leading.equalTo(backgroundFront.snp.centerX).offset(8)
        }
        ujiKodinganBtn.snp.makeConstraints { make in
            make.width.equalTo(135)
            make.trailing.equalTo(ngodingYukCard).offset(-30)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        tipsBtn.snp.makeConstraints { make in
            make.trailing.equalTo(ujiKodinganBtn.snp.leading).offset(-20)
            make.centerY.equalTo(ujiKodinganBtn)
        }
        contohStackView.snp.makeConstraints { make in
            make.leading.equalTo(pertanyaanCard).offset(5)
            make.bottom.equalTo(contohBGStackView.snp.top).offset(-10)
            make.trailing.equalTo(pertanyaanCard).offset(-5)
        }
        contohBGStackView.snp.makeConstraints { make in
            make.width.equalTo(contohStackView).offset(10)
            make.centerX.equalTo(contohStackView)
            make.bottom.equalTo(backgroundFront).offset(-80)
            make.top.equalTo(contohBGStackView.snp.top)
            make.height.equalTo(0)
        }
        keyboard.snp.remakeConstraints { make in
            make.height.equalTo(70)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupButtonFunction() {
        ujiKodinganBtn.addAction(
            UIAction { [self] _ in
                backgroundFront.snp.remakeConstraints { make in
                    make.leading.bottom.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.75)
                    make.top.equalTo(background).offset(8)
                }
                ujiKodinganBtn.snp.updateConstraints { make in
                    make.trailing.equalTo(ngodingYukCard).offset(135)
                }
                animationTransparency(view: ujiKodinganBtn, alpha: 0)
                animationLayout()
            },
            for: .touchUpInside
        )
        
        ujiKodinganView.backBtn.addAction(
            UIAction { [self] _ in
                backgroundFront.snp.remakeConstraints { make in
                    make.leading.bottom.equalToSuperview()
                    make.width.equalToSuperview()
                    make.top.equalTo(background).offset(8)
                }
                ujiKodinganBtn.snp.updateConstraints { make in
                    make.trailing.equalTo(ngodingYukCard).offset(-30)
                }
                animationTransparency(view: ujiKodinganBtn, alpha: 1)
                animationLayout()
            },
            for: .touchUpInside)
        }

    /// Adds animation for layouting changes
    private func animationLayout() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    private func animationTransparency(view: UIView, alpha: CGFloat) {
        UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            view.alpha = alpha
        }.startAnimation()
    }
}

extension BattlefieldPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snippet = snippets[indexPath.row]
        ngodingYukCard.textViewDidBeginEditing(ngodingYukCard.textInput)
        if let textRange = ngodingYukCard.textInput.selectedTextRange {
            ngodingYukCard.textInput.replace(textRange, withText: snippet.snippet)
        }
    }
}

extension BattlefieldPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snippets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = keyboard.dequeueReusableCell(
            withReuseIdentifier: KeyboardCollectionViewCell.identifier,
            for: indexPath
        ) as? KeyboardCollectionViewCell else {
            fatalError("error")
        }
        
        let snippet = snippets[indexPath.row]
        cell.snippet = snippet.snippet
        cell.btnLabel = snippet.title

        return cell
    }
}

struct SnippetModel {
    let title: String
    let snippet: String
}

struct BattlefieldViewControllerPreviews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            return UINavigationController(rootViewController: BattlefieldPageViewController())
        }
        .previewDevice("iPad Pro (11-inch) (3rd generation)")
        .previewInterfaceOrientation(.landscapeLeft)
        .ignoresSafeArea()
    }
}
