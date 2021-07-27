pub struct Canvas {

  pub let width: UInt8
  pub let height: UInt8
  pub let pixels: String

  init(width: UInt8, height: UInt8, pixels: String) {
    self.width = width
    self.height = height
    // The following pixels
    // 123
    // 456
    // 789
    // should be serialized as
    // 123456789
    self.pixels = pixels
  }
}

pub resource Picture {
  pub let canvas: Canvas
  
  init(canvas: Canvas) {
    self.canvas = canvas
  }
}

pub fun serializeStringArray(_ lines: [String]): String {
  var buffer = ""
  for line in lines {
    buffer = buffer.concat(line)
  }

  return buffer
}

// from w1q1
// Displays the canvas in a frame
pub fun display(canvas: Canvas) {
    displayHeaderOrFooter(width: canvas.width)
    displayCanvas(canvas: canvas)
    displayHeaderOrFooter(width: canvas.width)
}

// Display the header and footer of the frame
pub fun displayHeaderOrFooter(width: UInt8) {
    var buffer = "+"
    var i: UInt8 = 0
    while i < width {
        buffer = buffer.concat("-")
        i = i + 1
    }
    buffer = buffer.concat("+")
    log(buffer)
}

// Display the canvas content with sides of the frame
pub fun displayCanvas(canvas: Canvas) {
    //count lines
    var i: UInt8 = 0
    //start index of each line
    var j: UInt8 = 0
    while i < canvas.height {
        var buffer = "|"
        buffer = buffer.concat(canvas.pixels.slice(from: Int(j), upTo: Int(j+canvas.width)))
        buffer = buffer.concat("|")
        log(buffer)
        i = i + 1
        j = j + canvas.width
    }
}

//W1Q2

pub resource Printer {
  pub let specifiedWidth: UInt8
  pub let specifiedHeight: UInt8
  pub var printedPictures: {String: Bool}

  init(specifiedWidth: UInt8, specifiedHeight: UInt8) {
    self.specifiedWidth = specifiedWidth
    self.specifiedHeight = specifiedHeight
    self.printedPictures = {}
  }

  pub fun print(canvas: Canvas): @Picture? {
    let id = canvas.pixels
    //Size of canvas does not fit with specified size
    if canvas.width != self.specifiedWidth || canvas.height != self.specifiedHeight {
      return nil
    }
    //Already printed
    if self.printedPictures[id] == true {
      return nil
    }

    self.printedPictures.insert(key: id, true)
    display(canvas: canvas)
      return <- create Picture(canvas: canvas)
  }
}

pub fun main() { 
  let printer <- create Printer(specifiedWidth: 5, specifiedHeight: 5)

  let canvas0 = Canvas(
          width: 5,
          height: 5,
          pixels: serializeStringArray([
    "* * *",
    "*  **",
    "* * *",
    "**  *",
    "* * *"
  ]))
  let letter0 <- create Picture(canvas: canvas0)
  let print0 <- printer.print(canvas: letter0.canvas)
  destroy letter0
  destroy print0

  //Should not print because of incorrect height
  let canvas02 = Canvas(
          width: 5,
          height: 6,
          pixels: serializeStringArray([
    "* * *",
    "*  **",
    "* * *",
    "**  *",
    "* * *"
  ]))
  let letter02 <- create Picture(canvas: canvas02)
  let print02 <- printer.print(canvas: letter02.canvas)
  destroy letter02
  destroy print02

  //Should not print because of incorrect width
  let canvas03 = Canvas(
          width: 6,
          height: 5,
          pixels: serializeStringArray([
    "* * *",
    "*  **",
    "* * *",
    "**  *",
    "* * *"
  ]))
  let letter03 <- create Picture(canvas: canvas03)
  let print03 <- printer.print(canvas: letter03.canvas)
  destroy letter03
  destroy print03

  let canvasX = Canvas(
          width: 5,
          height: 5,
          pixels: serializeStringArray([
    "*   *",
    " * * ",
    "  *  ",
    " * * ",
    "*   *"
  ]))
  let letterX <- create Picture(canvas: canvasX)
  let printX <- printer.print(canvas: letterX.canvas)
  destroy letterX
  destroy printX

  //Should not print because of duplicate
  let canvasX2 = Canvas(
          width: 5,
          height: 5,
          pixels: serializeStringArray([
    "*   *",
    " * * ",
    "  *  ",
    " * * ",
    "*   *"
  ]))
  let letterX2 <- create Picture(canvas: canvasX2)
  let printX2 <- printer.print(canvas: letterX2.canvas)
  destroy letterX2
  destroy printX2

  let canvasF = Canvas(
          width: 5,
          height: 5,
          pixels: serializeStringArray([
    "*****",
    "*    ",
    "**** ",
    "*    ",
    "*    "
  ]))
  let letterF <- create Picture(canvas: canvasF)
  let printF <- printer.print(canvas: letterF.canvas)
  destroy letterF
  destroy printF

  destroy printer
}
