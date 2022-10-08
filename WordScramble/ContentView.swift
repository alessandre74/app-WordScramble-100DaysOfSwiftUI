//
//  ContentView.swift
//  WordScramble
//
//  Created by Alessandre Livramento on 06/10/22.
//

import SwiftUI

struct ContentView: View {
    @FocusState private var selectedField: Bool
    
    @State private var useWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var countWords = 0
    @State private var countLetters = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingStartGame = false

    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .bottom) {
                    
                    VStack {
                        List {
                            Section {
                                TextField("Enter your word", text: $newWord)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .focused($selectedField)
                            }
                            
                            Section {
                                ForEach(useWords, id: \.self){ iten in
                                    ItensView(word: iten )
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .navigationTitle(rootWord)
                        .onSubmit(addNewWord)
                        .onAppear {
                            selectedField = true
                            startGame()
                        }
                        .alert(errorTitle, isPresented: $showingError) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text(errorMessage)
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    reset()
                                    startGame()
                                } label: {
                                    Text("Start Game")
                                        .font(.system(size: 16))
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    startGame()
                                } label: {
                                    Text("New word")
                                        .font(.system(size: 16))
                                }
                            }
                        }
                    }
                }
                WordsLettersView(words: countWords, letters: countLetters)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count != 0 else {
            wordError(title: "Warning", message: "The field is blank")
            return
        }
        
        guard answer.count >= 3 else {
            wordError(title: "word with minimum size", message: "The word must contain at least 3 characters")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            useWords.insert(answer, at: 0)
        }
        
        countWords += 1
        countLetters +=  answer.count
        selectedField = true
        
        newWord = ""
        
        startGame()
        
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            
            if let startWords = try? String(contentsOf: startWordsURL){
                
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                newWord = ""
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !useWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        newWord = ""
        showingError = true
        selectedField = true
    }
    
    func reset() {
        useWords = [String]()
        rootWord = ""
        newWord = ""
        countWords = 0
        countLetters = 0
        
        errorTitle = ""
        errorMessage = ""
        showingError = false
        showingStartGame = false
    }
    
}

struct ItensView: View {
    @State var word: String
    
    var body: some View {
        HStack {
            Image(systemName: "\(word.count).circle")
            Text(word)
        }
    }
}

struct WordsLettersView: View {
    var words: Int
    var letters: Int
    
    var body: some View {
        HStack {
            Spacer()
            Text("Words: \(words)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.gray)
            Spacer()
            
            Text("Letters: \(letters)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.gray)
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
