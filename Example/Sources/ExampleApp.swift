import SwiftUI
import FSLineChart

/// A chart view demonstrating various FSLineChart configurations.
class ExampleChart: FSLineChart {
    struct Configuration {
        let data: [Double]
        let labels: ChartLabels?
        let style: ChartStyle
        let title: String
    }
    
    /// Configures the chart with the provided settings.
    /// - Parameter configuration: The chart configuration.
    func load(configuration: Configuration) {
        try? setChartData(configuration.data)
        setLabels(configuration.labels)
        applyStyle(configuration.style)
    }
}

/// SwiftUI wrapper for ExampleChart.
struct SwiftUIExampleChart: UIViewRepresentable {
    let configuration: ExampleChart.Configuration
    
    func makeUIView(context: Context) -> ExampleChart {
        let chart = ExampleChart()
        chart.load(configuration: configuration)
        return chart
    }
    
    func updateUIView(_ uiView: ExampleChart, context: Context) {
        uiView.load(configuration: configuration)
    }
}

/// The main content view displaying multiple chart configurations.
struct ContentView: View {
    private let configurations: [ExampleChart.Configuration] = [
        ExampleChart.Configuration(
            data: (0..<10).map { _ in Double(Int.random(in: 20...120)) },
            labels: ChartLabels(
                indexLabel: { "\($0)" },
                valueLabel: { String(format: "$%.0f", $0) }
            ),
            style: ChartStyle(
                axisColor: .gray,
                axisLineWidth: 1,
                lineColor: .fsOrange,
                fillColor: UIColor.fsOrange.withAlphaComponent(0.25),
                lineWidth: 1,
                displayDataPoints: true,
                dataPointColor: .fsOrange,
                dataPointBackgroundColor: .fsOrange,
                dataPointRadius: 3,
                drawInnerGrid: true,
                innerGridColor: UIColor(white: 0.9, alpha: 1.0),
                innerGridLineWidth: 0.5,
                gridSteps: (vertical: 5, horizontal: 9),
                margin: 20,
                bezierSmoothing: true,
                bezierSmoothingTension: 0.2,
                animationDuration: 0.5,
                indexLabelFont: .systemFont(ofSize: 10),
                indexLabelColor: .gray,
                indexLabelBackgroundColor: .clear,
                valueLabelFont: .systemFont(ofSize: 11),
                valueLabelColor: .gray,
                valueLabelBackgroundColor: UIColor(white: 1, alpha: 0.75),
                valueLabelPosition: .mirrored
            ),
            title: "basic chart with random data"
        ),
        ExampleChart.Configuration(
            data: (0..<7).map { Double($0) / 30.0 + Double(Int.random(in: 0...100)) / 500 },
            labels: ChartLabels(
                indexLabel: { ["January", "February", "March", "April", "May", "June", "July"][$0] },
                valueLabel: { String(format: "%.02f €", $0) }
            ),
            style: ChartStyle(
                axisColor: .gray,
                axisLineWidth: 1,
                lineColor: .fsGreen,
                fillColor: nil,
                lineWidth: 1,
                displayDataPoints: true,
                dataPointColor: .fsGreen,
                dataPointBackgroundColor: .fsGreen,
                dataPointRadius: 2,
                drawInnerGrid: true,
                innerGridColor: UIColor(white: 0.9, alpha: 1.0),
                innerGridLineWidth: 0.5,
                gridSteps: (vertical: 6, horizontal: 3),
                margin: 20,
                bezierSmoothing: false,
                bezierSmoothingTension: 0.2,
                animationDuration: 0.5,
                indexLabelFont: .systemFont(ofSize: 10),
                indexLabelColor: .gray,
                indexLabelBackgroundColor: .clear,
                valueLabelFont: .systemFont(ofSize: 11),
                valueLabelColor: .gray,
                valueLabelBackgroundColor: UIColor(white: 1, alpha: 0.75),
                valueLabelPosition: .mirrored
            ),
            title: "monthly chart without smoothing"
        ),
        ExampleChart.Configuration(
            data: (0..<20).map { _ in Double(Int.random(in: 50...200)) },
            labels: ChartLabels(
                indexLabel: { "Day \($0 + 1)" },
                valueLabel: { String(format: "%.0f units", $0) }
            ),
            style: ChartStyle(
                axisColor: .gray,
                axisLineWidth: 1,
                lineColor: .fsDarkBlue,
                fillColor: UIColor.fsDarkBlue.withAlphaComponent(0.3),
                lineWidth: 1,
                displayDataPoints: false,
                dataPointColor: .fsDarkBlue,
                dataPointBackgroundColor: .fsDarkBlue,
                dataPointRadius: 0,
                drawInnerGrid: true,
                innerGridColor: UIColor(white: 0.9, alpha: 1.0),
                innerGridLineWidth: 0.5,
                gridSteps: (vertical: 8, horizontal: 5),
                margin: 20,
                bezierSmoothing: true,
                bezierSmoothingTension: 0.2,
                animationDuration: 0.5,
                indexLabelFont: .systemFont(ofSize: 10),
                indexLabelColor: .gray,
                indexLabelBackgroundColor: .clear,
                valueLabelFont: .systemFont(ofSize: 11),
                valueLabelColor: .gray,
                valueLabelBackgroundColor: UIColor(white: 1, alpha: 0.75),
                valueLabelPosition: .mirrored
            ),
            title: "dense data with blue theme"
        ),
        ExampleChart.Configuration(
            data: (0..<5).map { _ in Double(Int.random(in: 10...50)) },
            labels: ChartLabels(
                indexLabel: { "\($0)" },
                valueLabel: { String(format: "%.0f", $0) }
            ),
            style: ChartStyle(
                axisColor: .gray,
                axisLineWidth: 1,
                lineColor: .fsRed,
                fillColor: nil,
                lineWidth: 1,
                displayDataPoints: true,
                dataPointColor: .fsRed,
                dataPointBackgroundColor: .fsRed,
                dataPointRadius: 4,
                drawInnerGrid: true,
                innerGridColor: UIColor(white: 0.9, alpha: 1.0),
                innerGridLineWidth: 0.5,
                gridSteps: (vertical: 4, horizontal: 4),
                margin: 20,
                bezierSmoothing: true,
                bezierSmoothingTension: 0.2,
                animationDuration: 0.5,
                indexLabelFont: .systemFont(ofSize: 10),
                indexLabelColor: .gray,
                indexLabelBackgroundColor: .clear,
                valueLabelFont: .systemFont(ofSize: 11),
                valueLabelColor: .gray,
                valueLabelBackgroundColor: UIColor(white: 1, alpha: 0.75),
                valueLabelPosition: .mirrored
            ),
            title: "minimal chart with red theme"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("FSLineChart examples")
                    .font(.title)
                    .padding(.horizontal)
                
                ForEach(configurations, id: \.title) { config in
                    VStack(alignment: .leading) {
                        Text(config.title)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        SwiftUIExampleChart(configuration: config)
                            .frame(height: 250)
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGray6))
    }
}

#Preview("Basic Chart") {
    ContentView()
        .previewDisplayName("Basic Chart")
}

#Preview("Monthly Chart") {
    SwiftUIExampleChart(configuration: ExampleChart.Configuration(
        data: (0..<7).map { Double($0) / 30.0 + Double(Int.random(in: 0...100)) / 500 },
        labels: ChartLabels(
            indexLabel: { ["January", "February", "March", "April", "May", "June", "July"][$0] },
            valueLabel: { String(format: "%.02f €", $0) }
        ),
        style: ChartStyle(
            axisColor: .gray,
            axisLineWidth: 1,
            lineColor: .fsGreen,
            fillColor: nil,
            lineWidth: 1,
            displayDataPoints: true,
            dataPointColor: .fsGreen,
            dataPointBackgroundColor: .fsGreen,
            dataPointRadius: 2,
            drawInnerGrid: true,
            innerGridColor: UIColor(white: 0.9, alpha: 1.0),
            innerGridLineWidth: 0.5,
            gridSteps: (vertical: 6, horizontal: 3),
            margin: 20,
            bezierSmoothing: false,
            bezierSmoothingTension: 0.2,
            animationDuration: 0.5,
            indexLabelFont: .systemFont(ofSize: 10),
            indexLabelColor: .gray,
            indexLabelBackgroundColor: .clear,
            valueLabelFont: .systemFont(ofSize: 11),
            valueLabelColor: .gray,
            valueLabelBackgroundColor: UIColor(white: 1, alpha: 0.75),
            valueLabelPosition: .mirrored
        ),
        title: "monthly chart without smoothing"
    ))
    .frame(height: 250)
    .padding()
    .background(Color.white)
    .previewDisplayName("Monthly Chart")
}

#Preview("Dense Data") {
    SwiftUIExampleChart(configuration: ExampleChart.Configuration(
        data: (0..<20).map { _ in Double(Int.random(in: 50...200)) },
        labels: ChartLabels(
            indexLabel: { "Day \($0 + 1)" },
            valueLabel: { String(format: "%.0f units", $0) }
        ),
        style: ChartStyle(
            axisColor: .gray,
            axisLineWidth: 1,
            lineColor: .fsDarkBlue,
            fillColor: UIColor.fsDarkBlue.withAlphaComponent(0.3),
            lineWidth: 1,
            displayDataPoints: false,
            dataPointColor: .fsDarkBlue,
            dataPointBackgroundColor: .fsDarkBlue,
            dataPointRadius: 0,
            drawInnerGrid: true,
            innerGridColor: UIColor(white: 0.9, alpha: 1.0),
            innerGridLineWidth: 0.5,
            gridSteps: (vertical: 8, horizontal: 5),
            margin: 20,
            bezierSmoothing: true,
            bezierSmoothingTension: 0.2,
            animationDuration: 0.5,
            indexLabelFont: .systemFont(ofSize: 10),
            indexLabelColor: .gray,
            indexLabelBackgroundColor: .clear,
            valueLabelFont: .systemFont(ofSize: 11),
            valueLabelColor: .gray,
            valueLabelBackgroundColor: UIColor(white: 1, alpha: 0.75),
            valueLabelPosition: .mirrored
        ),
        title: "dense data with blue theme"
    ))
    .frame(height: 250)
    .padding()
    .background(Color.white)
    .previewDisplayName("Dense Data")
}

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
