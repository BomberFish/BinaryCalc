// bomberfish
// ContentView.swift – BinaryCalc Watch App
// created on 2024-12-17

import SwiftUI

enum Op {
    case add, sub, mul, div
}

struct ContentView: View {
    @State var display: String = "--"
    @State var current: String = ""
    @State var components: [String] = []
    @State var operators: [Op] = []
    let anim = Animation.snappy(duration: 0.1)
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack {
                        Spacer()
                        Text(display)
                            .frame(maxWidth: .infinity, minHeight: 32, alignment: .topTrailing)
                            .font(.title2.monospacedDigit())
                            .multilineTextAlignment(.trailing)
                            .id("display")
                            .animation(anim)
                    }
                }
                .onChange(of: display) {_,_ in
                    withAnimation(.linear(duration: 0.05)) {
                        proxy.scrollTo("display", anchor: .trailing)
                    }
                }
            }
            HStack {
                Button("C") {
                    display = "--"
                    current = ""
                    components = []
                    operators = []
                }
                
                Button("⌫") {
                    guard display != "--", !display.isEmpty else { return }
                    let removedChar = display.removeLast()
                    if removedChar == "0" || removedChar == "1" {
                        if !current.isEmpty {
                            current.removeLast()
                        } else if !components.isEmpty {
                            var lastComponent = components.removeLast()
                            if !lastComponent.isEmpty {
                                lastComponent.removeLast()
                                if !lastComponent.isEmpty {
                                    components.append(lastComponent)
                                }
                            }
                        }
                    } else {
                        // It's an operator
                        if !operators.isEmpty {
                            operators.removeLast()
                        }
                    }
                    if display.isEmpty {
                        display = "--"
                    }
                }
                
                Button("=") {
                    if display == "--" || current.isEmpty {
                        WKInterfaceDevice.current().play(.failure)
                        return
                    }

                    components.append(current)
                    guard components.count == operators.count + 1 else {
                        WKInterfaceDevice.current().play(.failure)
                        display = "Error"
                        return
                    }
                    
                    guard let first = Int(components[0], radix: 2) else {
                        display = "Error"
                        return
                    }
                    var result = first
                    
                    var remainder = ""
                    
                    print(result)

                    for i in 0..<operators.count {
                        guard let next = Int(components[i+1], radix: 2) else {
                             WKInterfaceDevice.current().play(.failure)
                            display = "Error"
                            return
                        }
                        print(next)

                        switch operators[i] {
                        case .add:
                            result += next
                        case .sub:
                            result -= next
                        case .mul:
                            result *= next
                        case .div:
                            if next == 0 {
                                display = "Error"
                                return
                            }
                            remainder = String(result % next, radix: 2)
                            result /= next
                        }
                    }
                    display = String(result, radix: 2)
                    current = display
                    if remainder != "0" && operators.contains(.div) {
                        display += " R " + remainder
                    }
                    components = []
                    operators = []
                }
            }
            
            HStack {
                Button("0") {
                    if display == "--" {
                        display = "0"
                        current = "0"
                    } else {
                        display += "0"
                        current += "0"
                    }
                }
                Button("1") {
                    if display == "--" {
                        display = "1"
                        current = "1"
                    } else {
                        display += "1"
                        current += "1"
                    }
                }
            }
            HStack {
                Button("+") {
                    guard !current.isEmpty else { return }
                    components.append(current)
                    operators.append(.add)
                    current = ""
                    display += "+"
                }
                Button("-") {
                    guard !current.isEmpty else { return }
                    components.append(current)
                    operators.append(.sub)
                    current = ""
                    display += "-"
                }
                Button("×") {
                    guard !current.isEmpty else { return }
                    components.append(current)
                    operators.append(.mul)
                    current = ""
                    display += "×"
                }

                Button("÷") {
                    guard !current.isEmpty else { return }
                    components.append(current)
                    operators.append(.div)
                    current = ""
                    display += "÷"
                }
            }
        }
        .animation(anim, value: display)
        .sensoryFeedback(.levelChange, trigger: display)
        .onChange(of: display) { new,_ in
            print("display changed to \(new)")
        }
        .onChange(of: components) { new,_ in
            print("components changed to \(new)")
        }
        .padding(.top, -20)
    }
}

#Preview {
    ContentView()
}
