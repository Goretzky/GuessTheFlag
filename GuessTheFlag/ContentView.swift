import SwiftUI

struct FlagImage: View {
    let country: String
    let rotationAmount: Double
    let opacity: Double
    let scale: CGFloat
    
    var body: some View {
        Image(country)
            .clipShape(.capsule)
            .shadow(radius: 5)
            .rotation3DEffect(
                .degrees(rotationAmount),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(opacity)
            .scaleEffect(scale)  // ✅ Shrink animation
            .animation(.easeInOut(duration: 0.6), value: opacity)
            .animation(.easeInOut(duration: 0.6), value: scale)  // ✅ Smooth transition
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var showingScore = false
    @State private var showingFinalScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var scaleAmount = [CGFloat](repeating: 1.0, count: 3)  // ✅ Add scale tracking
    @State private var questionCount = 0
    private let totalQuestions = 8
    
    @State private var rotationAmount = [Double](repeating: 0.0, count: 3)
    @State private var selectedFlag: Int? = nil
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
                .ignoresSafeArea()
        
            VStack{
                Spacer()
            
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(
                                country: countries[number],
                                    rotationAmount: rotationAmount[number],
                                opacity: selectedFlag == nil || selectedFlag == number ? 1.0 : 0.25,  // ✅ Fixed opacity logic,
                                scale: scaleAmount[number]  // ✅ Apply scale effect
                                      )                  }
                        .disabled(selectedFlag != nil)  // ✅ Disable buttons after one is tapped
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(score)")
        }
        .alert("Game Over!", isPresented: $showingFinalScore) {
            Button("Restart", action: resetGame)
        } message: {
            Text("Your final score is \(score) out of \(totalQuestions).")
        }
    }
    func flagTapped(_ number: Int) {
        withAnimation(.easeInOut(duration: 0.6)) {
            rotationAmount[number] += 360  // ✅ Rotate tapped flag fully
            selectedFlag = number
            
            for i in 0..<3 where i != number {
                rotationAmount[i] += Double.random(in: -180...180)  // ✅ Random spin for other flags
                scaleAmount[i] = 0.75  // ✅ Shrink other flags
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if number == correctAnswer {
                scoreTitle = "Correct"
                score += 1
            } else {
                let chosenCountry = countries[number]
                scoreTitle = "Wrong! That’s the flag of \(chosenCountry)."
                score -= 1
            }

            showingScore = true
            questionCount += 1
                   
            if questionCount >= totalQuestions {
                showingFinalScore = true
            }
        }
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        rotationAmount = [Double](repeating: 0.0, count: 3)
        scaleAmount = [CGFloat](repeating: 1.0, count: 3)  // ✅ Reset scale
        selectedFlag = nil
    }

    func resetGame() {
        score = 0
        questionCount = 0
        askQuestion()
    }
}

#Preview {
    ContentView()
}
