//
//  MainViewController.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import UIKit
import ComposableArchitecture
import Combine

final class MainViewController: UIViewController {
    private typealias Section = WeatherStore.Section
    private typealias Item = WeatherStore.Item
    private let viewStore: ViewStoreOf<WeatherStore>
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var searchTextField: PaddingTextField!
    private var clearButton: UIButton!
    private var searchSwitch: UISwitch!
    private var searchSwitchLabel: UILabel!
    private var areaNameListCollectionView: UICollectionView!
    private var activityIndicator: UIActivityIndicatorView!

    init(store: StoreOf<WeatherStore>) {
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        configureView()
        applyConstraints()

        Task {
            await viewStore.send(.fetchAreaList(.fetchAreaList), while: \.isLoading)
            observeDataSource()
        }

        viewStore.publisher.placeholder
            .assign(to: \.placeholder, on: searchTextField)
            .store(in: &cancellables)

        viewStore.publisher.isEnabled
            .assign(to: \.isEnabled, on: searchTextField)
            .store(in: &cancellables)

        viewStore.publisher.isEnabled
            .assign(to: \.isEnabled, on: clearButton)
            .store(in: &cancellables)

        viewStore.publisher.searchBarText
            .assign(to: \.text, on: searchTextField)
            .store(in: &cancellables)

        viewStore.publisher.isLoading.map({ !$0 })
            .assign(to: \.isHidden, on: activityIndicator)
            .store(in: &cancellables)

        viewStore.publisher.alert
            .sink { [weak self] alert in
                guard let self = self else { return }
                guard let alert = alert else { return }
                let alertController = UIAlertController(title: String(state: alert.title),
                                                        message: String(state: alert.message ?? TextState("")),
                                                        preferredStyle: .alert)
                alertController.addAction(
                    UIAlertAction(title: "Ok", style: .default) { _ in
                        self.viewStore.send(.alertDismiss)
                    }
                )
                self.present(alertController, animated: true)
            }
            .store(in: &cancellables)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.frame = view.bounds
    }
}

// MARK: - configure
extension MainViewController {
    private func configure() {
        configureSearchSwitchLabel()
        configureSearchSwitch()
        configureSearchTextField()
        configureSwitchButton()
        configureAreaNameListCollectionView()
        configureActivityIndicator()
        configureDataSource()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchSwitchLabel)
        view.addSubview(searchSwitch)
        view.addSubview(searchTextField)
        view.addSubview(clearButton)
        view.addSubview(areaNameListCollectionView)
        view.addSubview(activityIndicator)
    }

    private func configureSearchTextField() {
        searchTextField = PaddingTextField()
        searchTextField.layer.borderWidth = 0.5
        searchTextField.layer.borderColor = UIColor.darkGray.cgColor
        searchTextField.layer.cornerRadius = 10.0
        searchTextField.layer.masksToBounds = true
        searchTextField.addTarget(self, action: #selector(searchBarTextFieldChanged(sender:)), for: .editingChanged)
        searchTextField.delegate = self
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSwitchButton() {
        clearButton = UIButton(type: .system)
        clearButton.setTitle("クリア", for: .normal)
        clearButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 10)
        clearButton.layer.borderColor = UIColor.darkGray.cgColor
        clearButton.layer.borderWidth = 0.5
        clearButton.layer.cornerRadius = 10.0
        clearButton.layer.masksToBounds = true
        clearButton.addTarget(self, action: #selector(onTapClearButton(sender:)), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSearchSwitch() {
        searchSwitch = UISwitch()
        searchSwitch.addTarget(self, action: #selector(onTapSwitchButton(sender:)), for: .valueChanged)
        searchSwitch.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSearchSwitchLabel() {
        searchSwitchLabel = UILabel()
        searchSwitchLabel.text = "検索フィールド 有効/無効"
        searchSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: areaNameListCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AreaCollectionViewCell.identifier, for: indexPath) as? AreaCollectionViewCell
            else { return UICollectionViewCell() }
            cell.setAreaName(areaName: self.viewStore.areaOffices[indexPath.row].office.name)
            return cell
        }
    }

    private func configureAreaNameListCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        layout.minimumLineSpacing = 0
        areaNameListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        areaNameListCollectionView.register(AreaCollectionViewCell.self, forCellWithReuseIdentifier: AreaCollectionViewCell.identifier)
        areaNameListCollectionView.delegate = self
        areaNameListCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        areaNameListCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = true
    }
}

// MARK: - constraints
extension MainViewController {
    private func applyConstraints() {
        let searchSwitchLabelConstraints = [
            searchSwitchLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchSwitchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        ]

        let searchSwitchConstraints = [
            searchSwitch.centerYAnchor.constraint(equalTo: searchSwitchLabel.centerYAnchor),
            searchSwitch.leadingAnchor.constraint(equalTo: searchSwitchLabel.trailingAnchor, constant: 20)
        ]

        let searchTextFieldConstraints = [
            searchTextField.topAnchor.constraint(equalTo: searchSwitchLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        ]

        let clearButtonConstraints = [
            clearButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 10),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ]

        let areaNameListCollectionViewConstraints = [
            areaNameListCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            areaNameListCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            areaNameListCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            areaNameListCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(searchSwitchLabelConstraints)
        NSLayoutConstraint.activate(searchSwitchConstraints)
        NSLayoutConstraint.activate(searchTextFieldConstraints)
        NSLayoutConstraint.activate(clearButtonConstraints)
        NSLayoutConstraint.activate(areaNameListCollectionViewConstraints )
    }
}

// MARK: - others
extension MainViewController {
    private func observeDataSource() {
        viewStore.publisher.map({$0.snapshot})
            .sink { [weak self] in
                self?.dataSource.apply($0)
            }
            .store(in: &cancellables)
    }
    @objc private func searchBarTextFieldChanged(sender: UITextField) {
        viewStore.send(.searchBarChanged(sender.text ?? ""))
    }

    @objc private func onTapClearButton(sender: UIButton) {
        viewStore.send(.onTappedClearButton)
    }

    @objc private func onTapSwitchButton(sender: UISwitch) {
        viewStore.send(.onTappedSwitchButton)
    }
}

// MARK: - delegates
extension MainViewController: UICollectionViewDelegate, UITextFieldDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewStore.areaOffices.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewStore.send(.onTapCell(indexPath.row))
        let weatherViewController = WeatherViewController(viewStore: viewStore)
        present(weatherViewController, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
