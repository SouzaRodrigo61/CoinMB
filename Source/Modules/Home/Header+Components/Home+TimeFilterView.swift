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
        private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        private let swipeGestureRecognizer = UIPanGestureRecognizer()
        
        private var selectedIndexPath: IndexPath?
        private var isDragging = false
        private var initialSwipeX: CGFloat = 0
        
        var onFilterSelected: ((TimeFilter) -> Void)?
        
        // MARK: - Init
        override init(frame: CGRect) {
            // Configuração do layout da collection view
            let layout = CenteredCollectionViewFlowLayout()
            
            // Inicialização da collection view
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            
            super.init(frame: frame)
            setupView()
            setupGestures()
        }
        
        required init?(coder: NSCoder) {
            // Configuração do layout da collection view
            let layout = CenteredCollectionViewFlowLayout()
            
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
            feedbackGenerator.prepare()
        }
        
        private func setupGestures() {
            swipeGestureRecognizer.addTarget(self, action: #selector(handleSwipe(_:)))
            swipeGestureRecognizer.delegate = self
            addGestureRecognizer(swipeGestureRecognizer)
        }
        
        private func setupCollectionView() {
            addSubview(collectionView)
            
            collectionView.backgroundColor = .clear
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.decelerationRate = .fast
            collectionView.isPagingEnabled = false
            collectionView.isScrollEnabled = false // Desativa o scroll nativo
            collectionView.contentInsetAdjustmentBehavior = .always
            collectionView.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.reuseIdentifier)
            
            collectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            // Seleciona o primeiro item por padrão
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Calcula o inset para centralizar os itens
                self.updateCollectionViewInsets()
                
                let indexPath = IndexPath(item: 0, section: 0)
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                self.selectedIndexPath = indexPath
                
                if let filter = TimeFilter.allCases[safe: 0] {
                    self.onFilterSelected?(filter)
                }
            }
        }
        
        private func updateCollectionViewInsets() {
            // Calcula o inset para centralizar os itens
            let totalItemWidth = CGFloat(TimeFilter.allCases.count) * Design.cellWidth
            let totalSpacingWidth = CGFloat(TimeFilter.allCases.count - 1) * Design.cellSpacing
            let totalContentWidth = totalItemWidth + totalSpacingWidth
            
            let availableWidth = bounds.width - 2 * Design.horizontalPadding
            let inset = max(0, (availableWidth - totalContentWidth) / 2)
            
            collectionView.contentInset = UIEdgeInsets(
                top: 0,
                left: inset + Design.horizontalPadding,
                bottom: 0,
                right: inset + Design.horizontalPadding
            )
        }
        
        // Método para ajustar o tamanho do componente
        override var intrinsicContentSize: CGSize {
            return CGSize(width: UIView.noIntrinsicMetric, height: Design.cellHeight + 2 * Design.verticalPadding)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            updateCollectionViewInsets()
        }
        
        // MARK: - Public Methods
        
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

// MARK: - TimeFilter Enum
extension Home.TimeFilterView {
    enum TimeFilter: String, CaseIterable {
        // Filtros de curto prazo
        case oneDay = "1D"
        case threeDays = "3D"
        case oneWeek = "1S"
        case twoWeeks = "2S"
        case oneMonth = "1M"
        case twoMonths = "2M"
        case threeMonths = "3M"
        
        // Filtros de médio prazo
        case sixMonths = "6M"
        case nineMonths = "9M"
        case oneYear = "1A"
        case twoYears = "2A"
        case threeYears = "3A"
        
        // Filtros de longo prazo
        case fiveYears = "5A"
        case tenYears = "10A"
        case max = "MAX"
        
        var displayName: String {
            return self.rawValue
        }
        
        var analyticsName: String {
            switch self {
            case .oneDay: return "1_day"
            case .threeDays: return "3_days"
            case .oneWeek: return "1_week"
            case .twoWeeks: return "2_weeks"
            case .oneMonth: return "1_month"
            case .twoMonths: return "2_months"
            case .threeMonths: return "3_months"
            case .sixMonths: return "6_months"
            case .nineMonths: return "9_months"
            case .oneYear: return "1_year"
            case .twoYears: return "2_years"
            case .threeYears: return "3_years"
            case .fiveYears: return "5_years"
            case .tenYears: return "10_years"
            case .max: return "maximum"
            }
        }
    }
}

// MARK: - Design Constants
extension Home.TimeFilterView {
    private enum Design {
        static let cornerRadius: CGFloat = 24
        static let cellHeight: CGFloat = 32
        static let cellWidth: CGFloat = 40
        static let cellSpacing: CGFloat = 10
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 4
        
        static let normalAnimationDuration: TimeInterval = 0.25
        static let dragAnimationDuration: TimeInterval = 0.12
        static let springDamping: CGFloat = 0.75
        static let springVelocity: CGFloat = 0.5
        
        static let swipeVelocityThreshold: CGFloat = 70
        static let swipeDistanceThreshold: CGFloat = 15
        
        // Cores no estilo da imagem compartilhada
        static let backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        static let selectedBackgroundColor = UIColor(red: 0.25, green: 0.4, blue: 0.9, alpha: 1.0)
        static let selectedTextColor = UIColor.white
        static let unselectedTextColor = UIColor.white.withAlphaComponent(0.6)
    }
}

// MARK: - FilterCell
extension Home.TimeFilterView {
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
            
            // Adiciona um background arredondado para o item
            contentView.layer.cornerRadius = Design.cellHeight / 2
            contentView.clipsToBounds = true
            
            updateAppearance()
        }
        
        private func updateAppearance() {
            UIView.animate(withDuration: 0.2) {
                // Atualiza a cor do texto
                self.titleLabel.textColor = self.isSelected ? Design.selectedTextColor : Design.unselectedTextColor
                
                // Atualiza o background da célula
                self.contentView.backgroundColor = self.isSelected ? Design.selectedBackgroundColor : .clear
                
                // Atualiza o peso da fonte
                self.titleLabel.font = self.isSelected ? 
                    .systemFont(ofSize: 14, weight: .bold) : 
                    .systemFont(ofSize: 14, weight: .semibold)
            }
        }
        
        func configure(with title: String) {
            titleLabel.text = title
        }
    }
}

// MARK: - Custom Layout
extension Home.TimeFilterView {
    private class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {
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
}

// MARK: - Selection Handling
extension Home.TimeFilterView {
    func selectItem(at indexPath: IndexPath, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        guard indexPath != selectedIndexPath else { return }
        
        // Atualiza a seleção visual
        if let previousIndexPath = selectedIndexPath {
            if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? FilterCell {
                previousCell.isSelected = false
            }
        }
        
        // Atualiza o indexPath selecionado
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        selectedIndexPath = indexPath
        
        // Centraliza o item selecionado com animação suave
        let duration = animationDuration ?? (animated ? Design.normalAnimationDuration : 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.layoutIfNeeded()
        }
        
        // Atualiza a aparência da célula selecionada
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCell {
            cell.isSelected = true
        }
        
        // Notifica sobre a mudança de filtro
        if let filter = TimeFilter.allCases[safe: indexPath.item] {
            // Ajusta a intensidade do feedback com base na distância percorrida
            let previousItem = selectedIndexPath?.item ?? 0
            let distance = abs((indexPath.item - previousItem))
            let feedbackIntensity = min(0.5 + (CGFloat(min(distance, 5)) / 10.0), 1.0)
            
            feedbackGenerator.impactOccurred(intensity: feedbackIntensity)
            onFilterSelected?(filter)
        }
    }
}

// MARK: - Swipe Handling
extension Home.TimeFilterView {
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
                
                // Determina a direção do swipe
                let direction = deltaX > 0 ? 1 : -1
                
                // Calcula quantos itens pular com base na distância do swipe
                let distanceFactor = abs(deltaX) / 80 // Reduzido para maior sensibilidade
                let itemsToSkip = max(1, min(Int(distanceFactor), 3)) // Entre 1 e 3 itens
                
                let targetItem = currentIndexPath.item + (direction * itemsToSkip)
                
                // Verifica se o item alvo está dentro dos limites
                if targetItem >= 0 && targetItem < TimeFilter.allCases.count {
                    let targetIndexPath = IndexPath(item: targetItem, section: 0)
                    
                    // Só atualiza se for um novo item
                    if targetIndexPath != selectedIndexPath {
                        // Calcula a duração da animação com base na velocidade do swipe
                        let speed = min(abs(velocity.x), 1500) // Limita a velocidade máxima
                        let normalizedSpeed = speed / 1500 // Normaliza para um valor entre 0 e 1
                        
                        // Ajusta a duração para ser mais curta para movimentos mais rápidos
                        let animationDuration = max(0.1, Design.normalAnimationDuration * (1.0 - (normalizedSpeed * 0.7)))
                        
                        // Seleciona o item com animação suave
                        selectItem(at: targetIndexPath, animated: true, animationDuration: animationDuration)
                        
                        // Reseta a posição inicial para permitir swipes contínuos
                        initialSwipeX = translation.x
                        
                        // Prepara o feedback para o próximo swipe
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            self.feedbackGenerator.prepare()
                        }
                    }
                } else {
                    // Se estiver tentando ir além dos limites, seleciona o primeiro ou último item
                    let boundaryIndexPath = IndexPath(item: targetItem < 0 ? 0 : TimeFilter.allCases.count - 1, section: 0)
                    
                    if boundaryIndexPath != selectedIndexPath {
                        selectItem(at: boundaryIndexPath, animated: true, animationDuration: 0.2)
                        
                        // Fornece feedback tátil mais forte ao atingir os limites
                        feedbackGenerator.impactOccurred(intensity: 1.0)
                        
                        // Reseta a posição inicial
                        initialSwipeX = translation.x
                    }
                }
            }
            
        case .ended, .cancelled:
            isDragging = false
            
            // Verifica se há um swipe rápido para mudar vários itens
            if abs(velocity.x) > Design.swipeVelocityThreshold {
                // Calcula quantos itens pular com base na velocidade
                let velocityFactor = abs(velocity.x) / 700 // Normaliza a velocidade
                let itemsToSkip = min(Int(velocityFactor * 4), 5) // Limita a no máximo 5 itens
                
                // Corrige a direção para corresponder ao movimento do dedo
                let direction = velocity.x > 0 ? 1 : -1
                handleFastSwipe(direction: direction, itemsToSkip: itemsToSkip)
            }
            
        default:
            break
        }
    }
    
    private func handleFastSwipe(direction: Int, itemsToSkip: Int = 1) {
        guard let currentIndexPath = selectedIndexPath else { return }
        
        // Calcula o novo índice com base na velocidade
        let targetItem = max(0, min(TimeFilter.allCases.count - 1, currentIndexPath.item + (direction * itemsToSkip)))
        let targetIndexPath = IndexPath(item: targetItem, section: 0)
        
        // Só atualiza se for um novo item
        if targetIndexPath != selectedIndexPath {
            // Calcula a duração da animação com base na distância a percorrer
            let distance = abs(targetItem - currentIndexPath.item)
            let animationDuration = min(0.3, 0.1 + (TimeInterval(distance) * 0.05))
            
            // Seleciona o item com animação suave
            selectItem(at: targetIndexPath, animated: true, animationDuration: animationDuration)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension Home.TimeFilterView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Não permitimos gestos simultâneos para evitar conflitos
        return false
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

