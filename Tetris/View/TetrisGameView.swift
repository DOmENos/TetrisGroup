import SwiftUI
import Combine

struct TetrisGameView: View {
    @ObservedObject var tetrisGame: TetrisGameViewModel
    @ObservedObject var tetrisGameModel: TetrisGameModel
    
    init(tetrisGameModel: TetrisGameModel) {
        self.tetrisGame = TetrisGameViewModel(tetrisGameModel: tetrisGameModel)
        self.tetrisGameModel = tetrisGameModel
        
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Score: \(tetrisGameModel.score)")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading) // Score อยู่ด้านซ้าย
                
                Spacer()
                Text("Level: \(String(describing: tetrisGameModel.currentLevel))")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
            }

            GeometryReader { geometry in
                self.drawBoard(boundingRect: geometry.size)
            }
            .gesture(tetrisGame.getMoveGesture())
            .gesture(tetrisGame.getRotateGesture())

            Spacer() // ให้ Level อยู่ด้านขวาบน
            
        }
    }

    
    
    
    func drawBoard(boundingRect: CGSize) -> some View {
        let columns = self.tetrisGame.numColumns
        let rows = self.tetrisGame.numRows
        let blocksize = min(boundingRect.width/CGFloat(columns), boundingRect.height/CGFloat(rows))
        let xoffset = (boundingRect.width - blocksize*CGFloat(columns))/2
        let yoffset = (boundingRect.height - blocksize*CGFloat(rows))/2
        let gameBoard = self.tetrisGame.gameBoard
        
        return ForEach(0...columns-1, id:\.self) { column in
            ForEach(0...rows-1, id:\.self) { row in
                Path { path in
                    let x = xoffset + blocksize * CGFloat(column)
                    let y = boundingRect.height - yoffset - blocksize*CGFloat(row+1)
                    
                    let rect = CGRect(x: x, y: y, width: blocksize, height: blocksize)
                    path.addRect(rect)
                }
                .fill(gameBoard[column][row].color)
            }
        }
    }
}

struct TetrisGameView_Previews: PreviewProvider {
    static var previews: some View {
        let tetrisGameModel = TetrisGameModel()
        TetrisGameView(tetrisGameModel: tetrisGameModel)
    }
}
