//
//  ContentView.swift
//  PaldPing
//
//  Created by Pierre-Alexandre L. Dumais on 2024-10-13.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SpeedTestView()
                .tabItem {
                    Label("Speed Test", systemImage: "speedometer")
                }
                .tag(0)
            
            PublicIPView()
                .tabItem {
                    Label("Public IP", systemImage: "network")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

struct SpeedTestView: View {
    @State private var isTestingSpeed = false
    @State private var downloadSpeed: Double = 0
    @State private var uploadSpeed: Double = 0
    
    var body: some View {
        VStack {
            Text("Speed Test")
                .font(.largeTitle)
                .padding()
            
            SpeedometerView(speed: downloadSpeed, label: "Download")
                .frame(height: 200)
            
            SpeedometerView(speed: uploadSpeed, label: "Upload")
                .frame(height: 200)
            
            Button(action: {
                startSpeedTest()
            }) {
                Text(isTestingSpeed ? "Testing..." : "Start Test")
                    .padding()
                    .background(isTestingSpeed ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isTestingSpeed)
        }
    }
    
    private func startSpeedTest() {
        isTestingSpeed = true
        // Implement speed test logic here
        // Update downloadSpeed and uploadSpeed
        // Set isTestingSpeed to false when done
    }
}

struct SpeedometerView: View {
    let speed: Double
    let label: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(speed / 100, 1)))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: speed)
                
                Text("\(String(format: "%.1f", speed)) Mbps")
                    .font(.title)
                    .bold()
            }
            
            Text(label)
                .font(.headline)
        }
    }
}

struct PublicIPView: View {
    @State private var publicIP: String = "Fetching..."
    
    var body: some View {
        VStack {
            Text("Public IP")
                .font(.largeTitle)
                .padding()
            
            Text(publicIP)
                .font(.title)
                .padding()
            
            Button("Refresh") {
                fetchPublicIP()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            fetchPublicIP()
        }
    }
    
    private func fetchPublicIP() {
        // Implement public IP fetching logic here
        // Update publicIP state
    }
}

struct SettingsView: View {
    @State private var selectedSpeedTestServer = 0
    @State private var showDetailedResults = false
    
    var body: some View {
        Form {
            Section(header: Text("Speed Test Options")) {
                Picker("Server", selection: $selectedSpeedTestServer) {
                    Text("Automatic").tag(0)
                    Text("Server 1").tag(1)
                    Text("Server 2").tag(2)
                }
                
                Toggle("Show Detailed Results", isOn: $showDetailedResults)
            }
        }
        .navigationTitle("Settings")
    }
}
