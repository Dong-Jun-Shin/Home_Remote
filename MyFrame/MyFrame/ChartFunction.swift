//
//  ChartFunction.swift
//  MyFrame
//
//  Created by 임시 사용자 (DJ) on 2021/06/04.
//

import Charts

public class ChartFunction {
    public static func setLineChart(lineChartView: LineChartView, dataPoints: [String], values: [Double]){
        //데이터 생성
        var lineDataEntries: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let lineDataEntry = ChartDataEntry(x: Double(i), y: values[i])
            lineDataEntries.append(lineDataEntry)
        }

        //차트 컬러
        let lineDataSet = LineChartDataSet(entries: lineDataEntries, label: "온도")
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.lineWidth = 2
        lineDataSet.colors = [.systemRed]
        lineDataSet.circleColors = [.red]
        lineDataSet.highlightEnabled = false

        //데이터 삽입
        let lineData = LineChartData(dataSet: lineDataSet)
        lineData.setDrawValues(false)

        lineChartView.data = lineData

        //차트 옵션
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        lineChartView.xAxis.setLabelCount(2, force: true)
        lineChartView.doubleTapToZoomEnabled = false

        // 범례
        lineChartView.legend.enabled = false

        // 패딩
        lineChartView.extraTopOffset = 10
        lineChartView.extraBottomOffset = 5
        lineChartView.extraLeftOffset = 10
        lineChartView.extraRightOffset = 10

        // 왼쪽 값 설정
        lineChartView.leftAxis.axisMaximum = 40
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.granularity = 40

        // 오른쪽 값 설정
        lineChartView.rightAxis.enabled = false

        // 차트 컬러 설정
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChartView.backgroundColor = UIColor(red: 0.266, green: 0.266, blue: 0.266, alpha: 1)
        lineChartView.xAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        lineChartView.leftAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        lineChartView.rightAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }

    public static func setBarChart(barChartView: BarChartView, dataPoints: [String], values: [Double]){
        //데이터 생성
        var barDataEntries: [BarChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let barDataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            barDataEntries.append(barDataEntry)
        }

        //차트 컬러
        let barDataSet = BarChartDataSet(entries: barDataEntries, label: "습도")
        barDataSet.highlightEnabled = false

        //데이터 삽입
        let barData = BarChartData(dataSet: barDataSet)
        barData.setDrawValues(false)

        barChartView.data = barData

        //차트 옵션
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        barChartView.xAxis.setLabelCount(2, force: true)
        barChartView.doubleTapToZoomEnabled = false

        // 경계선
        let ll = ChartLimitLine(limit: 60.0, label: "")
        ll.lineColor = .systemBlue
        barChartView.leftAxis.addLimitLine(ll)

        // 범례
        barChartView.legend.enabled = false

        // 패딩
        barChartView.extraTopOffset = 10
        barChartView.extraBottomOffset = 5
        barChartView.extraLeftOffset = 10
        barChartView.extraRightOffset = 10

        // 왼쪽 값 설정
        barChartView.leftAxis.axisMaximum = 100
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.granularity = 100

        // 오른쪽 값 설정
        barChartView.rightAxis.enabled = false

        // 차트 컬러 설정
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.backgroundColor = UIColor(red: 0.266, green: 0.266, blue: 0.266, alpha: 1)
        barChartView.xAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        barChartView.leftAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        barChartView.rightAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }
}
