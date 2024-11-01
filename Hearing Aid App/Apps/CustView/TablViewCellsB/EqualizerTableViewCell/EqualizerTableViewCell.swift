import UIKit
import AAInfographics

struct EqualizerTableViewCellModel {
    var dataSource: [Double]
}

typealias EqualizerTableViewCellConfig = ViewCellConfigurator<EqualizerTableViewCell, EqualizerTableViewCellModel>

final class EqualizerTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = EqualizerTableViewCellModel
    
    @IBOutlet private weak var chartContainerView: UIView!
    
    private var chartView: AAChartView!
    
    private var dataModel: AASeriesElement {
        let colorData = AAGradientColor.linearGradient(direction: .toBottomRight, startColor: ThemeService.shared.activeColor.hexColor, endColor: ThemeService.shared.activeColor.hexColor)
        return AASeriesElement().name("Gain").data(dataSource).color(colorData)
    }
    
    private var dataSource: [Double] = EqualizerBands.allCases.compactMap { $0.value }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureChartView()
    }
    
    func configure(data: DataType) {
        dataSource = data.dataSource
    }
    
    func updateDataSource(on dataSource: [Double]) {
        self.dataSource = dataSource
        chartView.aa_onlyRefreshTheChartDataWithChartModelSeries([dataModel])
    }
    
    // MARK: - Private methods
    private func configureChartView() {
        chartView = AAChartView()
        chartContainerView.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.addBaseConstraintsFor(view: chartContainerView)
        chartView.isScrollEnabled = false
        
        let aaChartModel = AAChartModel()
        aaChartModel.chartType(.areaspline)
                    .yAxisMax(EqualizerBands.maxValue)
                    .yAxisMin(EqualizerBands.minValue)
                    //.axesTextColor(ThemeService.shared.activeColor.hexColor)
                    .backgroundColor(ThemeService.shared.isDarkModeEnabled ? (UIColor.appColor(.BackgroundColor_1)?.hexColor ?? "#000000") : "#FFFFFF")
                    .dataLabelsEnabled(false)
                    //.animationType(.bounce)
                    //.touchEventEnabled(false)
                    //.markerSymbolStyle(.innerBlank)
                    .markerRadius(2)
                   // .markerSymbol(.circle)
                    .categories(EqualizerBands.allCases.compactMap { $0.hzTitle })
                    .legendEnabled(false)
                    .series([dataModel])
        chartView.aa_drawChartWithChartModel(aaChartModel)
    }
}
