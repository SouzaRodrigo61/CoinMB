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
        private let swipeGestureRecognizer = UIPanGestureRecognizer()
        
        private var selectedIndexPath: IndexPath?
        private var isDragging = false
        private var initialSwipeX: CGFloat = 0
        
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
            static let cornerRadius: CGFloat = 24
            static let cellHeight: CGFloat = 32
            static let cellWidth: CGFloat = 40
            static let cellSpacing: CGFloat = 10
            static let horizontalPadding: CGFloat = 8
            static let verticalPadding: CGFloat = 4
            
            static let normalAnimationDuration: TimeInterval = 0.3
            static let dragAnimationDuration: TimeInterval = 0.15
            static let springDamping: CGFloat = 0.7
            static let springVelocity: CGFloat = 0.4
            
            static let swipeVelocityThreshold: CGFloat = 200
            static let swipeDistanceThreshold: CGFloat = 20
            
            static let indicatorShadowOpacity: Float = 0.2
            static let indicatorShadowRadius: CGFloat = 4
            
            // Cores no estilo da imagem compartilhada
            static let backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
            static let selectedColor = UIColor(red: 0.25, green: 0.4, blue: 0.9, alpha: 1.0)
            static let textColor = UIColor.white
            static let unselectedTextColor = UIColor.white.withAlphaComponent(0.6)
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
                titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
                
                titleLabel.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                updateAppearance()
            }
            
            private func updateAppearance() {
                UIView.animate(withDuration: 0.2) {
                    self.titleLabel.textColor = self.isSelected ? Design.textColor : Design.unselectedTextColor
                }
            }
            
            func configure(with title: String) {
                titleLabel.text = title
            }
        }
        
        // MARK: - Custom Layout
        private class FilterFlowLayout: UICollectionViewFlowLayout {
            override func prepare() {
                super.prepare()
                scrollDirection = .horizontal
                minimumInteritemSpacing = Design.cellSpacing
                minimumLineSpacing = Design.cellSpacing
                sectionInset = UIEdgeInsets(top: Design.verticalPadding, 
                                           left: Design.horizontalPadding, 
                                           bottom: Design.verticalPadding, 
                                           right: Design.horizontalPadding)
            }
        }
        
        // MARK: - Init
        override init(frame: CGRect) {
            // Configuração do layout da collection view
            let layout = FilterFlowLayout()
            
            // Inicialização da collection view
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            
            super.init(frame: frame)
            setupView()
            setupGestures()
        }
        
        required init?(coder: NSCoder) {
            // Configuração do layout da collection view
            let layout = FilterFlowLayout()
            
            // Inicialização da collection view
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            
            super.init(coder: coder)
            setupView()
            setupGestures()
        }
        
        // MARK: - Setup
        private func setupView() {
            backgroundColor = Design.backgroundColor
            layer.cornerRadius = Design.cornerRadius
            clipsToBounds = true
            
            // Adiciona uma borda sutil para melhorar a definição visual
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
            
            setupCollectionView()
            setupSelectionIndicator()
            feedbackGenerator.prepare()
        }
        
        private func setupGestures() {
            swipeGestureRecognizer.addTarget(self, action: #selector(handleSwipe(_:)))
            swipeGestureRecognizer.delegate = self
            addGestureRecognizer(swipeGestureRecognizer)
        }
        
        @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: self)
            let velocity = gesture.velocity(in: self)
            
            switch gesture.state {
            case .began:
                initialSwipeX = translation.x
                isDragging = true
                feedbackGenerator.prepare()
                
            case .changed:
                // Encontra o item mais próximo com base na posição do dedo
                let deltaX = translation.x - initialSwipeX
                
                if abs(deltaX) > Design.swipeDistanceThreshold {
                    guard let currentIndexPath = selectedIndexPath else { return }
                    
                    // Determina a direção do swipe (corrigido para corresponder à direção do dedo)
                    // Deslizar para a direita -> avança para o próximo item (direção positiva)
                    // Deslizar para a esquerda -> volta para o item anterior (direção negativa)
                    let direction = deltaX > 0 ? 1 : -1
                    let targetItem = currentIndexPath.item + direction
                    
                    // Verifica se o item alvo está dentro dos limites
                    if targetItem >= 0 && targetItem < TimeFilter.allCases.count {
                        let targetIndexPath = IndexPath(item: targetItem, section: 0)
                        
                        // Só atualiza se for um novo item
                        if targetIndexPath != selectedIndexPath {
                            if let cell = collectionView.cellForItem(at: targetIndexPath) {
                                updateSelectionIndicator(for: cell, animated: true)
                                
                                // Atualiza a seleção visual
                                if let previousCell = collectionView.cellForItem(at: currentIndexPath) as? FilterCell {
                                    previousCell.isSelected = false
                                }
                                
                                if let cell = cell as? FilterCell {
                                    cell.isSelected = true
                                }
                                
                                selectedIndexPath = targetIndexPath
                                
                                // Notifica sobre a mudança de filtro
                                if let filter = TimeFilter.allCases[safe: targetIndexPath.item] {
                                    feedbackGenerator.impactOccurred(intensity: 0.3)
                                    onFilterSelected?(filter)
                                }
                                
                                // Reseta a posição inicial para permitir swipes contínuos
                                initialSwipeX = translation.x
                            }
                        }
                    }
                }
                
            case .ended, .cancelled:
                isDragging = false
                
                // Verifica se há um swipe rápido para mudar vários itens
                if abs(velocity.x) > Design.swipeVelocityThreshold {
                    // Corrige a direção para corresponder ao movimento do dedo
                    let direction = velocity.x > 0 ? 1 : -1
                    handleFastSwipe(direction: direction)
                }
                
            default:
                break
            }
        }
        
        private func handleFastSwipe(direction: Int) {
            guard let currentIndexPath = selectedIndexPath else { return }
            
            // Calcula o novo índice com base na velocidade
            let targetItem = max(0, min(TimeFilter.allCases.count - 1, currentIndexPath.item + direction))
            let targetIndexPath = IndexPath(item: targetItem, section: 0)
            
            // Só atualiza se for um novo item
            if targetIndexPath != selectedIndexPath {
                selectItem(at: targetIndexPath)
            }
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
            
            // Seleciona o primeiro item por padrão
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let indexPath = IndexPath(item: 0, section: 0)
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
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
            selectionIndicator.backgroundColor = Design.selectedColor
            selectionIndicator.layer.cornerRadius = Design.cellHeight / 2
            selectionIndicator.layer.shadowColor = Design.selectedColor.cgColor
            selectionIndicator.layer.shadowOffset = CGSize(width: 0, height: 2)
            selectionIndicator.layer.shadowRadius = Design.indicatorShadowRadius
            selectionIndicator.layer.shadowOpacity = Design.indicatorShadowOpacity
            insertSubview(selectionIndicator, belowSubview: collectionView)
            
            selectionIndicator.snp.makeConstraints { make in
                make.height.equalTo(Design.cellHeight)
                make.width.equalTo(Design.cellWidth)
                make.centerY.equalToSuperview()
                make.leading.equalTo(Design.horizontalPadding)
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
                
                // Scroll para garantir que o item selecionado esteja visível
                // Usa .left para manter o comportamento não centralizado
                var scrollPosition: UICollectionView.ScrollPosition = .left
                
                // Se o item estiver próximo do final, usa .right para garantir visibilidade
                if indexPath.item > TimeFilter.allCases.count - 3 {
                    scrollPosition = .right
                }
                
                collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
                
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
        
        // Método para ajustar o tamanho do componente
        override var intrinsicContentSize: CGSize {
            return CGSize(width: UIView.noIntrinsicMetric, height: Design.cellHeight + 2 * Design.verticalPadding)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension Home.TimeFilterView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Permite que o gesto de swipe funcione simultaneamente com o scroll da collection view
        return true
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

#if DEBUG
// MARK: - SwiftUI Preview
import SwiftUI

struct TimeFilterViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            TimeFilterViewRepresentable()
                .frame(height: 40)
                .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.black)
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
