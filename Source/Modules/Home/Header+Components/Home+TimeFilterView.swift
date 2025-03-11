// 
//  TimeFilterView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 24/02/25.
//

import UIKit
import SnapKit

extension Home { 
    
    class TimeFilterView: UIView {
        // MARK: - Properties
        private let collectionView: UICollectionView
        private let selectionIndicator = UIView()
        private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        
        private var selectedIndexPath: IndexPath?
        private var isDragging = false
        
        var onFilterSelected: ((TimeFilter) -> Void)?
        
        enum TimeFilter: String, CaseIterable {
            case oneDay = "3D"
            case oneWeek = "1S"
            case oneMonth = "1M"
            case sixMonths = "6M"
            case oneYear = "1A"
            case fiveYears = "5A"
            
            var displayName: String {
                return self.rawValue
            }
            
            var analyticsName: String {
                switch self {
                case .oneDay: return "3_days"
                case .oneWeek: return "1_week"
                case .oneMonth: return "1_month"
                case .sixMonths: return "6_months"
                case .oneYear: return "1_year"
                case .fiveYears: return "5_years"
                }
            }
        }
        
        private enum Design {
            static let cornerRadius: CGFloat = 28
            static let cellHeight: CGFloat = 40
            static let cellWidth: CGFloat = 52
            static let cellSpacing: CGFloat = 14
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 8
            
            static let normalAnimationDuration: TimeInterval = 0.4
            static let dragAnimationDuration: TimeInterval = 0.2
            static let springDamping: CGFloat = 0.65
            static let springVelocity: CGFloat = 0.4
            
            static let swipeVelocityThreshold: CGFloat = 200
            
            static let indicatorShadowOpacity: Float = 0.15
            static let indicatorShadowRadius: CGFloat = 6
            
            static let backgroundOpacity: CGFloat = 0.9
        }
        
        // MARK: - FilterCell
        class FilterCell: UICollectionViewCell {
            static let reuseIdentifier = "FilterCell"
            
            let titleLabel = UILabel()
            
            override var isSelected: Bool {
                didSet {
                    updateAppearance()
                }
            }
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                setupCell()
            }
            
            required init?(coder: NSCoder) {
                super.init(coder: coder)
                setupCell()
            }
            
            private func setupCell() {
                contentView.addSubview(titleLabel)
                
                titleLabel.textAlignment = .center
                titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                
                titleLabel.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                updateAppearance()
            }
            
            private func updateAppearance() {
                UIView.animate(withDuration: 0.2) {
                    self.titleLabel.textColor = self.isSelected ? .label : .secondaryLabel.withAlphaComponent(0.7)
                    self.titleLabel.transform = self.isSelected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
                }
            }
            
            func configure(with title: String) {
                titleLabel.text = title
            }
        }
        
        // MARK: - Custom Layout
        private class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {
            override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
                guard let collectionView = collectionView else {
                    return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
                }
                
                // Área visível
                let targetRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
                
                // Encontra os atributos de layout para os itens na área visível
                guard let layoutAttributesArray = layoutAttributesForElements(in: targetRect) else {
                    return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
                }
                
                // Ponto central da área visível
                let horizontalCenter = proposedContentOffset.x + collectionView.bounds.width / 2
                
                // Encontra o item mais próximo do centro
                var closestAttribute: UICollectionViewLayoutAttributes?
                var minDistance: CGFloat = .greatestFiniteMagnitude
                
                for attributes in layoutAttributesArray {
                    let distance = abs(attributes.center.x - horizontalCenter)
                    if distance < minDistance {
                        minDistance = distance
                        closestAttribute = attributes
                    }
                }
                
                // Retorna o offset que centraliza o item
                if let closestAttribute = closestAttribute {
                    return CGPoint(x: closestAttribute.center.x - collectionView.bounds.width / 2, y: proposedContentOffset.y)
                }
                
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            }
        }
        
        // MARK: - Init
        override init(frame: CGRect) {
            // Configuração do layout da collection view
            let layout = CenteredCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = Design.cellSpacing
            layout.minimumLineSpacing = Design.cellSpacing
            
            // Calcula o inset para garantir que os itens das extremidades fiquem centralizados
            let totalItemWidth = Design.cellWidth * CGFloat(TimeFilter.allCases.count)
            let totalSpacingWidth = Design.cellSpacing * CGFloat(TimeFilter.allCases.count - 1)
            let totalWidth = totalItemWidth + totalSpacingWidth
            
            // Inicialização da collection view
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            // Configuração do layout da collection view
            let layout = CenteredCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = Design.cellSpacing
            layout.minimumLineSpacing = Design.cellSpacing
            
            // Inicialização da collection view
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            
            super.init(coder: coder)
            setupView()
        }
        
        // MARK: - Setup
        private func setupView() {
            backgroundColor = .systemGray6.withAlphaComponent(Design.backgroundOpacity)
            layer.cornerRadius = Design.cornerRadius
            clipsToBounds = true
            
            // Adiciona efeito de vidro fosco (blur)
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(blurView, at: 0)
            
            // Adiciona borda sutil
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            
            setupCollectionView()
            setupSelectionIndicator()
            feedbackGenerator.prepare()
            
            // Adiciona efeito de sombra ao componente
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 8
            layer.shadowOpacity = 0.1
            layer.masksToBounds = false
        }
        
        private func setupCollectionView() {
            addSubview(collectionView)
            
            collectionView.backgroundColor = .clear
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.decelerationRate = .fast
            collectionView.isPagingEnabled = false
            collectionView.contentInsetAdjustmentBehavior = .always
            collectionView.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.reuseIdentifier)
            
            collectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            // Ajusta os insets para permitir que os itens das extremidades fiquem centralizados
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let inset = (self.collectionView.bounds.width - Design.cellWidth) / 2
                self.collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                
                // Seleciona o primeiro item por padrão
                let indexPath = IndexPath(item: 0, section: 0)
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                self.selectedIndexPath = indexPath
                
                if let cell = self.collectionView.cellForItem(at: indexPath) {
                    self.updateSelectionIndicator(for: cell, animated: false)
                }
                
                if let filter = TimeFilter.allCases[safe: 0] {
                    self.onFilterSelected?(filter)
                }
            }
        }
        
        private func setupSelectionIndicator() {
            // Cria um gradiente para o indicador de seleção
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor.systemBlue.withAlphaComponent(0.9).cgColor,
                UIColor.systemIndigo.withAlphaComponent(0.8).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = Design.cellHeight / 2
            
            selectionIndicator.layer.insertSublayer(gradientLayer, at: 0)
            selectionIndicator.layer.cornerRadius = Design.cellHeight / 2
            selectionIndicator.layer.shadowColor = UIColor.systemBlue.cgColor
            selectionIndicator.layer.shadowOffset = CGSize(width: 0, height: 3)
            selectionIndicator.layer.shadowRadius = Design.indicatorShadowRadius
            selectionIndicator.layer.shadowOpacity = Design.indicatorShadowOpacity
            insertSubview(selectionIndicator, belowSubview: collectionView)
            
            selectionIndicator.snp.makeConstraints { make in
                make.height.equalTo(Design.cellHeight)
                make.width.equalTo(Design.cellWidth)
                make.centerY.equalToSuperview()
                make.leading.equalTo(Design.horizontalPadding)
            }
            
            // Atualiza o frame do gradiente quando o tamanho do indicador muda
            selectionIndicator.layer.layoutSublayers()
            gradientLayer.frame = selectionIndicator.bounds
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Atualiza o frame do gradiente quando o tamanho do indicador muda
            if let gradientLayer = selectionIndicator.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = selectionIndicator.bounds
            }
        }
        
        private func updateSelectionIndicator(for cell: UICollectionViewCell, animated: Bool = true) {
            let duration = animated ? (isDragging ? Design.dragAnimationDuration : Design.normalAnimationDuration) : 0
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: Design.springDamping,
                           initialSpringVelocity: Design.springVelocity) {
                self.selectionIndicator.snp.remakeConstraints { make in
                    make.height.equalTo(Design.cellHeight)
                    make.width.equalTo(Design.cellWidth)
                    make.centerY.equalToSuperview()
                    make.centerX.equalTo(cell.snp.centerX)
                }
                self.layoutIfNeeded()
            }
        }
        
        private func selectItem(at indexPath: IndexPath, animated: Bool = true) {
            guard indexPath != selectedIndexPath else { return }
            
            // Atualiza a seleção visual
            if let previousIndexPath = selectedIndexPath {
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? FilterCell {
                    previousCell.isSelected = false
                }
            }
            
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            selectedIndexPath = indexPath
            
            if let cell = collectionView.cellForItem(at: indexPath) as? FilterCell {
                cell.isSelected = true
                
                // Centraliza o item selecionado
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
                
                // Atualiza o indicador de seleção
                updateSelectionIndicator(for: cell, animated: animated)
            }
            
            // Notifica sobre a mudança de filtro
            if let filter = TimeFilter.allCases[safe: indexPath.item] {
                feedbackGenerator.impactOccurred(intensity: 0.7)
                onFilterSelected?(filter)
            }
        }
        
        // Método para selecionar o próximo filtro
        func selectNextFilter() {
            guard let currentIndexPath = selectedIndexPath,
                  currentIndexPath.item < TimeFilter.allCases.count - 1 else { return }
            
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: 0)
            selectItem(at: nextIndexPath)
        }
        
        // Método para selecionar o filtro anterior
        func selectPreviousFilter() {
            guard let currentIndexPath = selectedIndexPath,
                  currentIndexPath.item > 0 else { return }
            
            let previousIndexPath = IndexPath(item: currentIndexPath.item - 1, section: 0)
            selectItem(at: previousIndexPath)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension Home.TimeFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TimeFilter.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.reuseIdentifier, for: indexPath) as? FilterCell,
              let filter = TimeFilter.allCases[safe: indexPath.item] else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: filter.displayName)
        cell.isSelected = indexPath == selectedIndexPath
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension Home.TimeFilterView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Design.cellWidth, height: Design.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItem(at: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
        feedbackGenerator.prepare()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isDragging else { return }
        
        // Encontra a célula mais visível durante o scroll
        let visibleRect = CGRect(
            origin: collectionView.contentOffset,
            size: collectionView.bounds.size
        )
        let visiblePoint = CGPoint(
            x: visibleRect.midX,
            y: visibleRect.midY
        )
        
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint),
           indexPath != selectedIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) {
            // Atualiza apenas o indicador durante o arrasto
            updateSelectionIndicator(for: cell, animated: true)
            
            // Atualiza a seleção visual
            if let previousIndexPath = selectedIndexPath {
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? FilterCell {
                    previousCell.isSelected = false
                }
            }
            
            if let cell = cell as? FilterCell {
                cell.isSelected = true
            }
            
            selectedIndexPath = indexPath
            
            // Notifica sobre a mudança de filtro
            if let filter = TimeFilter.allCases[safe: indexPath.item] {
                feedbackGenerator.impactOccurred(intensity: 0.3)
                onFilterSelected?(filter)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // O layout personalizado já cuida da centralização
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isDragging = false
            
            // Se não vai desacelerar, seleciona o item mais próximo do centro
            let visibleRect = CGRect(
                origin: collectionView.contentOffset,
                size: collectionView.bounds.size
            )
            let visiblePoint = CGPoint(
                x: visibleRect.midX,
                y: visibleRect.midY
            )
            
            if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
                selectItem(at: indexPath)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDragging = false
        
        // Quando o scroll termina, seleciona o item mais próximo do centro
        let visibleRect = CGRect(
            origin: collectionView.contentOffset,
            size: collectionView.bounds.size
        )
        let visiblePoint = CGPoint(
            x: visibleRect.midX,
            y: visibleRect.midY
        )
        
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            selectItem(at: indexPath)
        }
    }
}

// MARK: - Helper
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

struct TimeFilterViewPreview: PreviewProvider {
    static var previews: some View {
        TimeFilterViewRepresentable()
            .frame(height: 60)
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
    
    struct TimeFilterViewRepresentable: UIViewRepresentable {
        func makeUIView(context: Context) -> Home.TimeFilterView {
            let view = Home.TimeFilterView()
            view.onFilterSelected = { filter in
                print("Filtro selecionado: \(filter.rawValue)")
            }
            return view
        }
        
        func updateUIView(_ uiView: Home.TimeFilterView, context: Context) {}
    }
}
#endif
