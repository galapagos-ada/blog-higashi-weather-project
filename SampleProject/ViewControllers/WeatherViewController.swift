//
//  WeatherViewController.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/21.
//

import UIKit
import ComposableArchitecture
import Combine

class WeatherViewController: UIViewController {
    let viewStore: ViewStoreOf<WeatherStore>
    private var cancellables: Set<AnyCancellable> = []
    private var officeLable: UILabel!
    private var scrollView: UIScrollView!
    private var mainStackView: UIStackView!

    init(viewStore: ViewStoreOf<WeatherStore>) {
        self.viewStore = viewStore
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
        setOfficeLabel()

        Task {
            await viewStore.send(.fetchAreaWeather, while: \.isLoading)
            setWeatherInformation()
        }

        // MARK: - alert
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
}

// MARK: - configure
extension WeatherViewController {
    private func configure() {
        configureOfficeLabel()
        configureScrollView()
        configureMainStackView()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        view.addSubview(officeLable)
        view.addSubview(scrollView)
    }

    private func configureOfficeLabel() {
        officeLable = UILabel()
        officeLable.font = UIFont.boldSystemFont(ofSize: 25)
        officeLable.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureScrollView() {
        scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureMainStackView() {
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .leading
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
    }
}

// MARK: - constraints
extension WeatherViewController {
    private func applyConstraints() {
        let officeLabelConstraints = [
            officeLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            officeLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        ]
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: officeLable.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        let mainStackViewConstraints = [
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(officeLabelConstraints)
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(mainStackViewConstraints)
    }
}

// MARK: - others
extension WeatherViewController {
    private func setOfficeLabel() {
        officeLable.text = viewStore.areaOffices[viewStore.currentIndex].office.name
    }

    private func setWeatherInformation() {
        if !viewStore.areaWeather.timeSeries.isEmpty {
            viewStore.areaWeather.timeSeries[0].areas.filter({ $0.area != nil }).forEach {
                let areaNameLable = UILabel()
                areaNameLable.text = "〜\($0.area!.name)〜"
                areaNameLable.font = UIFont.boldSystemFont(ofSize: 23)
                areaNameLable.translatesAutoresizingMaskIntoConstraints = false
                mainStackView.addArrangedSubview(areaNameLable)
                if let weathers = $0.weathers {
                    setContentData(contents: weathers, title: "☀️天気情報☀️")
                }
                if let winds = $0.winds {
                    setContentData(contents: winds, title: "🌪風情報🌪")
                }
            }
        }
    }

    private func setContentData(contents: [String], title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        mainStackView.addArrangedSubview(titleLabel)
        let titles: [String] = ["今日", "明日", "明後日"]
        contents.indices.forEach { i in
            let dateLabel = UILabel()
            dateLabel.text = titles[i]
            dateLabel.font = UIFont.boldSystemFont(ofSize: 17)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            let contentLabel = UILabel()
            contentLabel.text = contents[i].replacingOccurrences(of: "　", with: "")
            contentLabel.numberOfLines = 0
            let spacerView = UIView()
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            let subStackView = UIStackView(arrangedSubviews: [
                dateLabel,
                contentLabel,
                spacerView
            ])
            subStackView.axis = .horizontal
            subStackView.spacing = 10
            subStackView.translatesAutoresizingMaskIntoConstraints = false
            subStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 20).isActive = true
            mainStackView.addArrangedSubview(subStackView)
        }
    }
}
