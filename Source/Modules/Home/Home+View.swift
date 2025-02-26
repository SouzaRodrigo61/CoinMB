//
//  HomeView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import UIKit

extension Home {
    final class View: UIView {
        // MARK: - UI Components
        private lazy var collectionView = {
            let collectionView = UICollectionView(
                frame: .zero, 
                collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
                return self.createSectionLayout(sectionIndex: sectionIndex)
            })

            collectionView.backgroundColor = .systemBackground
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false

            collectionView.translatesAutoresizingMaskIntoConstraints = false
            return collectionView
        }()
        
        // MARK: - Properties
        private let headerHeight: CGFloat = 340
        private let maxHeaderHeight: CGFloat = 500
        
        private var sections: [Home.View.Section] = []
        var onTimeFilterSelected: ((Home.TimeFilterView.TimeFilter) -> Void)?
        var onContentTapped: ((Home.Repository.CurrentRates.Rate) -> Void)?

        private var viewModel: Home.ViewModel.Model? = nil
        
        private var originalRates: [Home.Repository.CurrentRates.Rate] = []
        private var filteredRates: [Home.Repository.CurrentRates.Rate] = []
        
        // MARK: - Init
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
            setupConstraints()
            setupCollectionView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        private func setupView() {
            addSubview(collectionView)
        }
        
        private func setupConstraints() {
            collectionView.snp.makeConstraints { make in
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        
        private func setupCollectionView() { 
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.register(Home.ContentCell.self, 
                                    forCellWithReuseIdentifier: Home.ContentCell.reuseIdentifier)
            collectionView.register(Home.HeaderCell.self, 
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, 
                                    withReuseIdentifier: Home.HeaderCell.reuseIdentifier)
            collectionView.register(Home.ContentHeader.self, 
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, 
                                    withReuseIdentifier: Home.ContentHeader.reuseIdentifier)
        }
    }
}

// MARK: - Configuration Methods
extension Home.View {
    func configure(with model: Home.ViewModel.Model) {
        self.viewModel = model
        self.originalRates = model.rates // Guarda os rates originais
        self.filteredRates = model.rates // Inicialmente, filtered = original

        self.sections.removeAll()
        self.sections.append(.header(.header(model.periods)))
        self.sections.append(.content(
            filteredRates.map { .content($0) }
        ))
        
        self.collectionView.reloadData()
    }
    
    private func filterRates(with searchText: String) {
        if searchText.isEmpty {
            filteredRates = originalRates
        } else {
            filteredRates = originalRates.filter { rate in
                let searchLower = searchText.lowercased()
                return rate.assetIdQuote.lowercased().contains(searchLower)
            }
        }
        
        sections[1] = .content(filteredRates.map { .content($0) })
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}

// MARK: - UICollectionViewLayout
extension Home.View {    
    func createSectionLayout(sectionIndex: Int) -> NSCollectionLayoutSection {
        let section = self.sections[sectionIndex]

        switch section {
        case .header:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(340))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)

            sectionHeader.pinToVisibleBounds = false
            sectionHeader.zIndex = -1

            section.boundarySupplementaryItems = [sectionHeader]
            section.contentInsets = NSDirectionalEdgeInsets(top: -20, leading: 0, bottom: 0, trailing: 0)

            return section
        default:
            let spacing: CGFloat = 8
            let contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), 
                heightDimension: .estimated(44)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), 
                heightDimension: .estimated(44)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = contentInsets

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            sectionHeader.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }
    }
}

extension Home.View: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let row = self.sections[section]

        switch row {
        case .header:
            return 0
        case .content(let items):
            return items.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView, 
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let row = self.sections[indexPath.section]

        switch row {
        case .header:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Home.ContentCell.reuseIdentifier,
                for: indexPath
            ) as? Home.ContentCell else {
                return UICollectionViewCell()
            }
            return cell

        case .content(let items):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Home.ContentCell.reuseIdentifier, 
                for: indexPath
            ) as? Home.ContentCell else { 
                return UICollectionViewCell() 
            }
            
            if case .content(let model) = items[indexPath.row] { 
                if let viewModel = self.viewModel {
                    let iconUrl = viewModel.icons.first { 
                        $0.assetId.lowercased() == model.assetIdQuote.lowercased() 
                    }?.url
                    cell.configure(with: model, iconUrl: iconUrl)
                    
                    cell.onHandler = { [weak self] in
                        guard let self else { return }
                        dump(model, name: "onHandler -> Cell Content")
                        onContentTapped?(model)
                    }
                }
            }

            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView, 
        viewForSupplementaryElementOfKind kind: String, 
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

        let section = self.sections[indexPath.section]

        switch section {
        case .header(let model):
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, 
                withReuseIdentifier: Home.HeaderCell.reuseIdentifier, 
                for: indexPath
            ) as? Home.HeaderCell else { 
                return UICollectionReusableView() 
            }
        
            if case .header(let contents) = model { 
                header.configure(model: contents)
                header.onTimeFilterSelected = onTimeFilterSelected
            }

            return header
        default:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, 
                withReuseIdentifier: Home.ContentHeader.reuseIdentifier, 
                for: indexPath
            ) as? Home.ContentHeader else { 
                return UICollectionReusableView() 
            }
            
            header.configure(
                title: "Principais Criptomoedas",
                subtitle: "Acompanhe as cotações em tempo real"
            )
            
            header.onFilterTapped = { [weak self] in 
                dump("onFilterTapped")
            }
            
            header.onSearchTapped = { [weak self] in 
                dump("onSearchTapped")
            }

            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, 
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let section = self.sections[section]

        switch section {
        case .header:
            return CGSize(width: collectionView.bounds.width, height: headerHeight)
        default:
            return .zero
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        if let header = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader, 
            at: IndexPath(item: 0, section: 0)
        ) as? Home.HeaderCell {
            if offsetY < 0 {
                let stretchAmount = min(-offsetY, maxHeaderHeight - headerHeight)
                let scale = 1 + (stretchAmount / headerHeight)

                header.frame.origin.y = offsetY
                header.frame.size.height = headerHeight + stretchAmount

                let translateY = (header.frame.height - headerHeight) / 2
                if let imageView = header.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                    imageView.transform = CGAffineTransform(
                        scaleX: scale,
                        y: scale
                    ).concatenating(
                        CGAffineTransform(translationX: 0, y: -translateY)
                    )
                }
                header.updateBlur(alpha: 0)
            } else {
                header.frame.size.height = headerHeight

                if let imageView = header.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                    imageView.transform = .identity
                }
                let blurAlpha = min(90, offsetY / 190)
                header.updateBlur(alpha: blurAlpha)
            }
            
            header.setNeedsLayout()
            header.layoutIfNeeded()
        }
    }
}

// MARK: - Models
extension Home.View {
    enum Section { 
        case header(Item)
        case content([Item])
    }
    
    enum Item: Hashable {
        case header([Home.Repository.ExchangePeriod])
        case content(Home.Repository.CurrentRates.Rate)
    }
}
