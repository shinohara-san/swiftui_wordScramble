//
//  ContentView.swift
//  WordScramble
//
//  Created by Yuki Shinohara on 2020/04/01.
//  Copyright © 2020 Yuki Shinohara. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Your score:   \(score)").font(.title)
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }.navigationBarItems(leading:
                Button(action: {
                    self.startGame()
                    self.usedWords = [String]()
                    self.score = 0
                }) {
                    Text("Start game")
                }
            )
            
        }
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word or too short.")
            return
        }
        
        guard notSameStart(word: answer) else {
            wordError(title: "Word that has the same start", message: "It is too easy for ya!")
            return
        }
        
        usedWords.insert(answer, at: 0)
        self.score += answer.count
        newWord = ""
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        //        start.txtというファイルを探してアンラップ
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            //            アンラップされたものの中身を文字列で取り出し、それぞれ改行で記されているので、それを指定し、allwordsにぶち込み
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                //                ランダムに一つデータを取り出しrootwordに入れてリターン
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let wordLength = word.utf16.count
        
        if wordLength <= 3 {
            return false
        } else {
            let range = NSRange(location: 0, length: wordLength)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return misspelledRange.location == NSNotFound
        }
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    //    rootの出だしと同じやつはだめだよメソッド
    func notSameStart(word: String) -> Bool{
        //        最初の部分を入力文字数分だけstartWordに入れる
        let startWord = rootWord.prefix(word.count)
        if word == startWord {
            if word == rootWord {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
