import SwiftUI

class TetrisGameModel: ObservableObject {
    var numberRows: Int
    var numberColumns: Int
    @Published var gameBoard: [[TetrisGameBlock?]]
    @Published var tetromino: Tetromino?
    @Published var score: Int = 0
    @Published var blockbreak: Int = 0
    @Published var currentLevel: Int = 1
    var timer: Timer?
    var speed: Double
   
    
    
    
    var shadow: Tetromino? {
        guard var lastShadow = tetromino else {return nil}
        var testShadow = lastShadow
        while(isValidTetromino(testTetromino: testShadow)){
            lastShadow = testShadow
            testShadow = lastShadow.moveBy(row: -1, column: 0)
        }
        return lastShadow
    }
    
    init(numRows: Int = 23, numColumns: Int = 15) {
        self.numberRows = numRows
        self.numberColumns = numColumns
        
        gameBoard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        speed = 0.5
        resumeGame()
    }
    
    
    
    func resumeGame(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true, block: runEngine)
    }
    
    func pauseGame(){
        timer?.invalidate()
        
    }
    
    func resetGame() {
            // กำหนดค่าใหม่ให้ gameBoard
            gameBoard = Array(repeating: Array(repeating: nil, count: numberRows), count: numberColumns)
            
            // สร้าง Tetromino ใหม่
            tetromino = Tetromino.createNewTetromino(numRows: numberRows, numColumns: numberColumns)
            
            // กำหนดค่าอื่น ๆ ตามที่ต้องการ (ตามความต้องการของเกม)
            
            // เริ่มต้นหรือเริ่มเวลาใหม่
            resumeGame()
        }
    
    func runEngine(timer: Timer){
        if clearLines(){
            print("Linne Cleared")
            return
        }
        guard tetromino != nil else {
            print("Spawning new Tetromino")
            tetromino = Tetromino.createNewTetromino(numRows: numberRows, numColumns: numberColumns)
            if !isValidTetromino(testTetromino: tetromino!) {
                print("Game over!")
                pauseGame()
                
            }
            return
        }
        if moveTetrominoDown() {
            print("Moving Tetromino down")
            return
        }
        print("Placing tetromino")
        placeTetromino()
    }
    func dropTetromino(){
        while (moveTetrominoDown()){}
    }
    func moveTetrominoRigth()-> Bool{
        return moveTetromino(rowOffset: 0, columnOffset: 1)
    }
    func moveTetrominoLeft()-> Bool {
        return moveTetromino(rowOffset: 0, columnOffset: -1)
    }
    
    func moveTetrominoDown()-> Bool{
        return moveTetromino(rowOffset: -1, columnOffset: 0)
    }
    
    func moveTetromino(rowOffset: Int, columnOffset: Int) -> Bool {
        guard let currentTetromino = tetromino else {return false}
        
        let newTetromino = currentTetromino.moveBy(row: rowOffset, column: columnOffset)
        if isValidTetromino (testTetromino: newTetromino){
            tetromino = newTetromino
            return true
        }
        return false
    }
    
    func rotateTetromino(clockwise: Bool){
        guard let currentTetromino = tetromino else {return}
        
        let newTetrominoBase = currentTetromino.rotate(clockwise: clockwise)
        let kicks = currentTetromino.getKicks(clockwise: clockwise)
        
        for kick in kicks {
            let newTetromino = newTetrominoBase.moveBy(row: kick.row, column: kick.column)
            if isValidTetromino(testTetromino: newTetromino){
                tetromino = newTetromino
                return
            }
        }
    }
    
    func isValidTetromino(testTetromino: Tetromino) -> Bool {
        for block in testTetromino.blocks {
            let row = testTetromino.origin.row + block.row
            if row < 0 || row >= numberRows { return false }
            
            let column = testTetromino.origin.column + block.column
            if column < 0 || column >= numberColumns { return false }
            
            if gameBoard[column][row] != nil { return false }
        }
        return true
    }
    
    func updateScoreBlock(placeTetromino: Int) {
        // คำนวณคะแนนจากบล็อคที่ถูกวาง
        let blockScore = 100 // แก้ไขเป็นคะแนนที่ต้องการต่อบล็อค
        score += blockScore * placeTetromino
    }
    func updateScoreLine(linesCleared: Int) {
        // ถ้ามีการลบแถว, ให้เพิ่มคะแนนเพิ่มเติม
        if linesCleared > 0 {
            let rowClearScore = 500 * linesCleared
            score += rowClearScore
        }
    }
    
    func placeTetromino() {
        guard let currentTetromino = tetromino else {
            return
        }
        
        for block in currentTetromino.blocks {
            let row = currentTetromino.origin.row + block.row
            if row < 0 || row >= numberRows { continue }
            
            let column = currentTetromino.origin.column + block.column
            if column < 0 || column >= numberColumns { continue }
            
            gameBoard[column][row] = TetrisGameBlock(blockType: currentTetromino.blockType)
        }
        
        updateScoreBlock(placeTetromino: currentTetromino.blocks.count) // เรียกใช้งานฟังก์ชันอัพเดตคะแนน
        tetromino = nil
    }
    func clearLines() -> Bool {
        var newBoard: [[TetrisGameBlock?]] = Array(repeating: Array(repeating: nil, count: numberRows), count: numberColumns)
        var boardUpdated = false
        var nextRowToCopy = 0
        var linesCleared = 0

        for row in 0...numberRows-1 {
            var clearLine = true
            for column in 0...numberColumns-1 {
                clearLine = clearLine && gameBoard[column][row] != nil
            }

            if !clearLine {
                for column in 0...numberColumns-1 {
                    newBoard[column][nextRowToCopy] = gameBoard[column][row]
                }
                nextRowToCopy += 1
            } else {
                linesCleared += 1
            }
            boardUpdated = boardUpdated || clearLine
        }

        if boardUpdated {
            gameBoard = newBoard
            updateScore(linesCleared: linesCleared)
            
        }
        return boardUpdated
    }
    func updateScore(linesCleared: Int) {
        // คำนวณคะแนนจากบล็อคที่ถูกวาง
        let blockScore = linesCleared * 100
        score += blockScore
        
        // ถ้ามีการลบแถว, ให้เพิ่มคะแนนเพิ่มเติม
        if linesCleared > 0 {
            let rowClearScore = 500
            score += rowClearScore
            blockbreak += 1
        }
        
        if blockbreak >= 1 {
            let currentLevel = currentLevel
            self.currentLevel += 1
            speed -= 0.5
            print("currentLevel")
            print("speed")
        }
        
    }
    
}


struct TetrisGameBlock {
    var blockType: BlockType
}

enum BlockType: CaseIterable {
    case i, t, o, j, l, s, z
}

struct Tetromino {
    var origin: BlockLocation
    var blockType: BlockType
    var rotation: Int
    
    var blocks: [BlockLocation] {
        return Tetromino.getBlocks(blockType: blockType, rotation: rotation)
    }
    
    func moveBy(row: Int, column: Int)-> Tetromino {
        let newOrigin = BlockLocation(row: origin.row + row, column: origin.column + column)
        return Tetromino(origin: newOrigin, blockType: blockType, rotation: rotation)
    }
    
    func rotate(clockwise: Bool) -> Tetromino{
        return Tetromino(origin: origin, blockType: blockType, rotation: rotation + (clockwise ? 1 : -1))
    }
    
    func getKicks(clockwise: Bool) -> [BlockLocation] {
        return Tetromino.getKicks(blockType: blockType, rotation: rotation, clockwise: clockwise)
    }
    
    static func getBlocks(blockType: BlockType, rotation: Int = 0) -> [BlockLocation] {
        let allBlocks = getAllBlocks(blockType: blockType)
        
        var index = rotation % allBlocks.count
        if (index < 0) { index += allBlocks.count}
        
        return allBlocks[index]
    }
    
    static func getAllBlocks(blockType: BlockType) ->[[BlockLocation]]{
        switch blockType {
        case .i:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 2)],
                    [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: -2, column: 1)],
                    [BlockLocation(row: -1, column: -1), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1), BlockLocation(row: -1, column: 2)],
                    [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: -2, column: 0)]]
        case .o:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: 1, column: 0)]]
        case .t:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 0)],
                    [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: -1, column: 0)]]
        case .j:
            return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: -1)]]
        case .l:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: -1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: 1, column: -1)]]
        case .s:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: -1)],
                    [BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0)]]
        case .z:
            return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: -1, column: -1)]]
            
        }
    }
    
    static func createNewTetromino(numRows: Int, numColumns: Int) -> Tetromino {
        let blockType = BlockType.allCases.randomElement()!
        
        var maxRow = 0
        for block in getBlocks(blockType: blockType) {
            maxRow = max(maxRow, block.row)
        }
        
        let origin = BlockLocation(row: numRows - 1 - maxRow, column: (numColumns-1)/2)
        return Tetromino(origin: origin, blockType: blockType, rotation: 0)
    }
    
    static func getKicks(blockType: BlockType, rotation: Int, clockwise: Bool) -> [BlockLocation]{
        let rotationCount = getAllKicks(blockType: blockType).count
        
        var index = rotation % rotationCount
        if index < 0 {index += rotationCount}
        
        var kicks = getAllKicks(blockType: blockType)[index]
        if !clockwise {
            var counterKicks: [BlockLocation] = []
            for kick in kicks {
                counterKicks.append(BlockLocation(row: -1 * kick.row, column: -1 * kick.column))
            }
            kicks = counterKicks
        }
        return kicks
    }
    
    static func getAllKicks(blockType: BlockType) -> [[BlockLocation]] {
        switch blockType {
        case .o:
            return [[BlockLocation(row: 0, column: 0)]]
        case .i:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -2), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: -2), BlockLocation(row: 2, column: -1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 2), BlockLocation(row: 2, column: -1), BlockLocation(row: -1, column: 2)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 2), BlockLocation(row: 0, column: -1), BlockLocation(row: 1, column: 2), BlockLocation(row: -2, column: -1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: -2), BlockLocation(row: -2, column: 1), BlockLocation(row: 1, column: -2)]
            ]
        case .j, .l, .s, .z, .t:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -2), BlockLocation(row: -2, column: -1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 1), BlockLocation(row: 2, column: 0), BlockLocation(row: 1, column: 2)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: -2, column: 0), BlockLocation(row: -2, column: 1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: -1, column: -1), BlockLocation(row: 2, column: 0), BlockLocation(row: 2, column: -1)]
            ]
        }
    }
}
struct BlockLocation {
    var row: Int
    var column: Int
}
