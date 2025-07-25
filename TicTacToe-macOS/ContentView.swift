import SwiftUI

enum GameMode {
    case none, playerVsPlayer, playerVsAI
}

struct ContentView: View {
    @State private var board = Array(repeating: "", count: 9)
    @State private var isXTurn = true
    @State private var gameOver = false
    @State private var winner: String? = nil
    @State private var flipped = Array(repeating: false, count: 9)
    @State private var hovered = Array(repeating: false, count: 9)
    @State private var gameMode: GameMode = .none

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.indigo.opacity(0.4), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Top-right Restart Button
                VStack {
                    HStack {
                        Spacer()
                        if gameMode != .none {
                            Button(action: resetGame) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .white.opacity(0.15), radius: 4, x: 0, y: 2)
                            }
                            .help("Restart Game")
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                        }
                    }
                    Spacer()
                }

                // Main Content
                VStack(spacing: 30) {
                    Text("Tic Tac Toe")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if gameMode == .none {
                        VStack(spacing: 20) {
                            GameModeButton(title: "Player vs Player", icon: "person.2.fill") {
                                gameMode = .playerVsPlayer
                            }

                            GameModeButton(title: "Player vs AI", icon: "cpu.fill") {
                                gameMode = .playerVsAI
                            }
                        }
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
                            ForEach(0..<9) { i in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                        .frame(height: geometry.size.width / 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(hovered[i] ? Color.white.opacity(0.8) : Color.white.opacity(0.2), lineWidth: hovered[i] ? 2 : 1)
                                        )
                                        .shadow(color: hovered[i] ? Color.white.opacity(0.3) : Color.clear,
                                                radius: hovered[i] ? 10 : 0)

                                    if flipped[i] {
                                        Text(board[i])
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                            .animation(.easeInOut(duration: 0.4), value: board[i])
                                    }
                                }
                                .onTapGesture {
                                    if board[i] == "" && !gameOver {
                                        playerMove(index: i)
                                    }
                                }
                                .onHover { hovering in
                                    withAnimation {
                                        hovered[i] = hovering
                                    }
                                }
                                .rotation3DEffect(.degrees(flipped[i] ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                                .animation(.easeInOut(duration: 0.4), value: flipped[i])
                            }
                        }
                        .padding(.horizontal)

                        if gameOver {
                            VStack(spacing: 12) {
                                Text(winner != nil ? "\(winner!) Wins!" : "It's a Draw")
                                    .font(.title2)
                                    .foregroundColor(.white)

                                GameModeButton(title: "Play Again", icon: "arrow.uturn.left") {
                                    resetGame()
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    func playerMove(index: Int) {
        board[index] = isXTurn ? "X" : "O"
        isXTurn.toggle()
        withAnimation {
            flipped[index] = true
        }
        checkWinner()

        if gameMode == .playerVsAI && !isXTurn && !gameOver {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                aiMove()
            }
        }
    }

    func aiMove() {
        let emptyIndices = board.indices.filter { board[$0] == "" }
        guard let move = emptyIndices.randomElement() else { return }

        board[move] = "O"
        isXTurn.toggle()
        withAnimation {
            flipped[move] = true
        }
        checkWinner()
    }

    func checkWinner() {
        let winningCombos = [
            [0,1,2], [3,4,5], [6,7,8],
            [0,3,6], [1,4,7], [2,5,8],
            [0,4,8], [2,4,6]
        ]
        for combo in winningCombos {
            let a = combo[0], b = combo[1], c = combo[2]
            if board[a] != "", board[a] == board[b], board[b] == board[c] {
                winner = board[a]
                gameOver = true
                return
            }
        }
        if !board.contains("") {
            gameOver = true
        }
    }

    func resetGame() {
        board = Array(repeating: "", count: 9)
        flipped = Array(repeating: false, count: 9)
        hovered = Array(repeating: false, count: 9)
        isXTurn = true
        gameOver = false
        winner = nil
        gameMode = .none
    }
}

struct GameModeButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isHovered
                        ? [Color.purple.opacity(0.7), Color.blue.opacity(0.6)]
                        : [Color.white.opacity(0.05), Color.white.opacity(0.03)]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(isHovered ? 0.3 : 0.1), lineWidth: 1)
            )
            .shadow(color: isHovered ? Color.blue.opacity(0.3) : Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
        .padding(.horizontal, 40)
    }
}
