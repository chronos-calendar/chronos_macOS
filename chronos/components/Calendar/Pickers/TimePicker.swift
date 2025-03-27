import SwiftUI
import AppKit

struct TimePicker: View {
    let title: String
    @Binding var selectedTime: Date
    @State private var hourText: String = ""
    @State private var minuteText: String = ""
    @State private var selectedPeriod: String = "AM"
    @State private var showPicker = false
    
    init(title: String, selectedTime: Binding<Date>) {
        self.title = title
        self._selectedTime = selectedTime
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime.wrappedValue)
        let minute = calendar.component(.minute, from: selectedTime.wrappedValue)
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        
        self._hourText = State(initialValue: "\(displayHour)")
        self._minuteText = State(initialValue: String(format: "%02d", minute))
        self._selectedPeriod = State(initialValue: hour >= 12 ? "PM" : "AM")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundStyle(.secondary)
                .font(.system(size: 13))
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .foregroundColor(.primary)
                
                // Hour field
                TextField("12", text: $hourText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 20)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: hourText) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            hourText = filtered
                        }
                        if let hour = Int(filtered) {
                            if hour > 12 {
                                hourText = "12"
                            } else if hour == 0 {
                                hourText = "1"
                            }
                        }
                        if filtered.count > 2 {
                            hourText = String(filtered.prefix(2))
                        }
                    }
                    .onSubmit {
                        validateHour()
                        updateTime()
                    }
                
                Text(":")
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .medium))
                
                // Minute field
                TextField("00", text: $minuteText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 20)
                    .onChange(of: minuteText) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            minuteText = filtered
                        }
                        if let minute = Int(filtered) {
                            if minute > 59 {
                                minuteText = "59"
                            }
                        }
                        if filtered.count > 2 {
                            minuteText = String(filtered.prefix(2))
                        }
                        if filtered.count == 2 {
                            validateMinute()
                        }
                    }
                    .onSubmit {
                        validateMinute()
                        updateTime()
                    }
                
                // Period toggle
                Button(action: {
                    selectedPeriod = selectedPeriod == "AM" ? "PM" : "AM"
                    updateTime()
                }) {
                    Text(selectedPeriod)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    showPicker.toggle()
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(showPicker ? 180 : 0))
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            if showPicker {
                ScrollerView(
                    hourText: $hourText,
                    minuteText: $minuteText,
                    selectedPeriod: $selectedPeriod,
                    showPicker: $showPicker,
                    onTimeSelected: { hour, minute, period in
                        hourText = "\(hour)"
                        minuteText = String(format: "%02d", minute)
                        selectedPeriod = period
                        updateTime()
                    }
                )
                .frame(height: 120)
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.15), radius: 8)
            }
        }
    }
    
    private func validateHour() {
        if hourText.isEmpty {
            hourText = "12"
            return
        }
        
        if let hour = Int(hourText) {
            if hour < 1 {
                hourText = "1"
            } else if hour > 12 {
                hourText = "12"
            }
        } else {
            hourText = "12"
        }
    }
    
    private func validateMinute() {
        if minuteText.isEmpty {
            minuteText = "00"
            return
        }
        
        if let minute = Int(minuteText) {
            if minute > 59 {
                minuteText = "59"
            } else {
                minuteText = String(format: "%02d", minute)
            }
        } else {
            minuteText = "00"
        }
    }
    
    private func updateTime() {
        validateHour()
        validateMinute()
        
        let hour = Int(hourText) ?? 12
        let minute = Int(minuteText) ?? 0
        
        var finalHour = hour
        if selectedPeriod == "PM" && hour != 12 {
            finalHour += 12
        } else if selectedPeriod == "AM" && hour == 12 {
            finalHour = 0
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
        let dateComponents = DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: finalHour,
            minute: minute
        )
        
        if let date = calendar.date(from: dateComponents) {
            selectedTime = date
        }
    }
}

struct ScrollerView: View {
    @Binding var hourText: String
    @Binding var minuteText: String
    @Binding var selectedPeriod: String
    @Binding var showPicker: Bool
    let onTimeSelected: (Int, Int, String) -> Void
    
    private let hours = Array(1...12)
    private let minutes = Array(0...59)
    private let periods = ["AM", "PM"]
    
    private var selectedHour: Int { Int(hourText) ?? 12 }
    private var selectedMinute: Int { Int(minuteText) ?? 0 }
    
    var body: some View {
        HStack(spacing: 0) {
            // Hours
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        Text("\(hour)")
                            .font(.system(size: 14))
                            .frame(height: 30)
                            .frame(maxWidth: .infinity)
                            .background(hour == selectedHour ? Color.blue.opacity(0.2) : Color.clear)
                            .onTapGesture(count: 2) {
                                onTimeSelected(hour, selectedMinute, selectedPeriod)
                                withAnimation {
                                    showPicker = false
                                }
                            }
                            .onTapGesture {
                                onTimeSelected(hour, selectedMinute, selectedPeriod)
                            }
                    }
                }
            }
            .frame(width: 60)
            
            // Minutes
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(minutes, id: \.self) { minute in
                        Text(String(format: "%02d", minute))
                            .font(.system(size: 14))
                            .frame(height: 30)
                            .frame(maxWidth: .infinity)
                            .background(minute == selectedMinute ? Color.blue.opacity(0.2) : Color.clear)
                            .onTapGesture(count: 2) {
                                onTimeSelected(selectedHour, minute, selectedPeriod)
                                withAnimation {
                                    showPicker = false
                                }
                            }
                            .onTapGesture {
                                onTimeSelected(selectedHour, minute, selectedPeriod)
                            }
                    }
                }
            }
            .frame(width: 60)
            
            // AM/PM
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(periods, id: \.self) { period in
                        Text(period)
                            .font(.system(size: 14))
                            .frame(height: 30)
                            .frame(maxWidth: .infinity)
                            .background(period == selectedPeriod ? Color.blue.opacity(0.2) : Color.clear)
                            .onTapGesture(count: 2) {
                                onTimeSelected(selectedHour, selectedMinute, period)
                                withAnimation {
                                    showPicker = false
                                }
                            }
                            .onTapGesture {
                                onTimeSelected(selectedHour, selectedMinute, period)
                            }
                    }
                }
            }
            .frame(width: 60)
        }
    }
}

struct TimePickerScrollView: View {
    @Binding var selectedTime: Date
    @Binding var isVisible: Bool
    
    private let hours = Array(1...12)
    private let minutes = Array(0...59)
    private let periods = ["AM", "PM"]
    
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var selectedPeriod: String
    
    init(selectedTime: Binding<Date>, isVisible: Binding<Bool>) {
        self._selectedTime = selectedTime
        self._isVisible = isVisible
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime.wrappedValue)
        let minute = calendar.component(.minute, from: selectedTime.wrappedValue)
        
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        _selectedHour = State(initialValue: displayHour)
        _selectedMinute = State(initialValue: minute)
        _selectedPeriod = State(initialValue: hour >= 12 ? "PM" : "AM")
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Hours
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            Text("\(hour)")
                                .font(.system(size: 14))
                                .frame(height: 30)
                                .frame(maxWidth: .infinity)
                                .background(hour == selectedHour ? Color.blue.opacity(0.2) : Color.clear)
                                .onTapGesture {
                                    selectedHour = hour
                                    updateSelectedTime()
                                }
                        }
                    }
                }
                .frame(width: 60)
            }
            
            // Minutes
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(minutes, id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .font(.system(size: 14))
                                .frame(height: 30)
                                .frame(maxWidth: .infinity)
                                .background(minute == selectedMinute ? Color.blue.opacity(0.2) : Color.clear)
                                .onTapGesture {
                                    selectedMinute = minute
                                    updateSelectedTime()
                                }
                        }
                    }
                }
                .frame(width: 60)
            }
            
            // AM/PM
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(periods, id: \.self) { period in
                            Text(period)
                                .font(.system(size: 14))
                                .frame(height: 30)
                                .frame(maxWidth: .infinity)
                                .background(period == selectedPeriod ? Color.blue.opacity(0.2) : Color.clear)
                                .onTapGesture {
                                    selectedPeriod = period
                                    updateSelectedTime()
                                }
                        }
                    }
                }
                .frame(width: 60)
            }
        }
    }
    
    private func updateSelectedTime() {
        var hour = selectedHour
        if selectedPeriod == "PM" && hour != 12 {
            hour += 12
        } else if selectedPeriod == "AM" && hour == 12 {
            hour = 0
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
        let dateComponents = DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: hour,
            minute: selectedMinute
        )
        
        if let date = calendar.date(from: dateComponents) {
            selectedTime = date
        }
    }
}

struct NSDatePickerView: NSViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var isVisible: Bool
    
    func makeNSView(context: Context) -> NSDatePicker {
        let picker = NSDatePicker()
        picker.datePickerStyle = .clockAndCalendar
        picker.datePickerElements = .hourMinute
        picker.target = context.coordinator
        picker.action = #selector(Coordinator.dateChanged(_:))
        return picker
    }
    
    func updateNSView(_ nsView: NSDatePicker, context: Context) {
        nsView.dateValue = selectedDate
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: NSDatePickerView
        
        init(_ parent: NSDatePickerView) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: NSDatePicker) {
            parent.selectedDate = sender.dateValue
            
            // Close the picker after selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    self.parent.isVisible = false
                }
            }
        }
    }
}
