
import SwiftUI
import Combine

class TetrisGameViewModel: ObservableObject {
    @Published var tetrisGameModel = TetrisGameModel()
    @Published var currentLevel: Int = 1
    var numRows: Int { tetrisGameModel.numberRows }
    var numColumns: Int { tetrisGameModel.numberColumns }
    var gameBoard: [[TetrisGameSquare]] {
        var board = tetrisGameModel.gameBoard.map { $0.map(convertToSquare) }
        
        if let shadow = tetrisGameModel.shadow{
            for blockLocation in shadow.blocks{
                board[blockLocation.column + shadow.origin.column][blockLocation.row + shadow.origin.row] = TetrisGameSquare(color: getColorShadow(blockType: shadow.blockType))
            }
        }
        
        if let tetromino = tetrisGameModel.tetromino {
            for blockLocation in tetromino.blocks {
                board[blockLocation.column + tetromino.origin.column][blockLocation.row + tetromino.origin.row] = TetrisGameSquare(color: getColor(blockType: tetromino.blockType))
            }
        }
        
        return board
    }
    
    var anyCancellable: AnyCancellable?
    var lastMoveLocation: CGPoint?
    var lastRotateAngle: Angle?
    var score: Int {
            return tetrisGameModel.score
        }
    
    init() {
        anyCancellable = tetrisGameModel.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
    init(tetrisGameModel: TetrisGameModel) {
            self.tetrisGameModel = tetrisGameModel
        }
    
    func setCurrentLevel(_ level: Int) {
            currentLevel = level
        }
    
    func convertToSquare(block: TetrisGameBlock?) -> TetrisGameSquare {
        return TetrisGameSquare(color: getColor(blockType: block?.blockType))
    }
    
    func getColor(blockType: BlockType?) -> Color {
        switch blockType {
        case .i:
            return .tetrisLightBlue
        case .j:
            return .tetrisDarkBlue
        case .l:
            return .tetrisOrange
        case .o:
            return .tetrisYellow
        case .s:
            return .tetrisGreen
        case .t:
            return .tetrisPurple
        case .z:
            return .tetrisRed
        case .none:
            return .tetrisBlack
        }
    }
    func getColorShadow(blockType: BlockType) -> Color{
        switch blockType {
        case .i:
            return .tetrisLightBlueShadow
        case .j:
            return .tetrisDarkBlueShadow
        case .l:
            return .tetrisOrangeShadow
        case .o:
            return .tetrisYellowShadow
        case .s:
            return .tetrisGreenShadow
        case .t:
            return .tetrisPurpleShadow
        case .z:
            return .tetrisRedShadow
        }
    }
    func getRotateGesture() -> some Gesture {
        let tap = TapGesture()
            .onEnded({self.tetrisGameModel.rotateTetromino(clockwise: true)})
        
        let rotate = RotationGesture()
            .onChanged(onRotateChanged(value:))
            .onEnded(onRotateEnd(value:))
        
        return tap.simultaneously(with: rotate)
    }
    
    func onRotateChanged(value: RotationGesture.Value) {
        guard let start = lastRotateAngle else {
            lastRotateAngle = value
            return
        }
        
        let diff = value - start
        if diff.degrees > 10 {
            tetrisGameModel.rotateTetromino(clockwise: true)
            lastRotateAngle = value
            return
        } else if diff.degrees < -10 {
            tetrisGameModel.rotateTetromino(clockwise: false)
            lastRotateAngle = value
            return
        }
    }
    
    func onRotateEnd(value: RotationGesture.Value){
        lastRotateAngle = nil
    }
    
    func getMoveGesture()-> some Gesture{
        return DragGesture()
            .onChanged(onMoveChanged(value:))
            .onEnded(onMoveEnded(_:))
    }
    func onMoveChanged(value: DragGesture.Value){
        guard let start = lastMoveLocation else{
            lastMoveLocation = value.location
            return
        }
        let xDiff = value.location.x - start.x
        if xDiff > 10{
            print("Moving rigth")
            let _ = tetrisGameModel.moveTetrominoRigth()
            lastMoveLocation = value.location
            return
        }
        if xDiff < -10 {
            print("Moving left")
            let _ = tetrisGameModel.moveTetrominoLeft()
            lastMoveLocation = value.location
            return
        }
        let yDiff = value.location.y - start.y
        if yDiff > 10 {
            print("Moving down")
            let _ = tetrisGameModel.moveTetrominoDown()
            lastMoveLocation = value.location
            return
        }
        if yDiff < -10 {
            print("Dropping")
            tetrisGameModel.dropTetromino()
            lastMoveLocation = value.location
            return
        }
    }
    func onMoveEnded(_ : DragGesture.Value){
        lastMoveLocation = nil
   

    }
    func updateScore() {
            // อัพเดตคะแนนใน ViewModel เมื่อคะแนนใน Model มีการเปลี่ยนแปลง
            objectWillChange.send()
           
        }
    

}

struct TetrisGameSquare {
    var color: Color
}
