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

pub fun serializeStringArray(_ lines: [String]): String {
  var buffer = ""
  for line in lines {
    buffer = buffer.concat(line)
  }

  return buffer
}

pub resource Picture {
  pub let canvas: Canvas
  
  init(canvas: Canvas) {
    self.canvas = canvas
  }
}

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

// Check if the width of each line match the specified width
pub fun linesAreEqual(canvas: Canvas, pixels: [String]): Bool {
  var i = 0
  var widthConstraint = canvas.width;
  while i < pixels.length {
    if(Int(widthConstraint) != pixels[i].length) {
      return false
    }
    i = i + 1
  }
  return true;
}

// Check if the number of lines match the specified height
pub fun heightIsCorrect(canvas: Canvas, pixels: [String]): Bool {
  var heightContraint = canvas.height
  return Int(heightContraint) == pixels.length
}

pub fun main() {

  let pixelsX = [
    "*   *",
    " * * ",
    "  *  ",
    " * * ",
    "*   *"
  ]

  let canvasX = Canvas(
          width: 5,
          height: 5,
          pixels: serializeStringArray(pixelsX)
        )

  if !linesAreEqual(canvas: canvasX,pixels: pixelsX) {
    panic("Width is not the same for each line. Fix and try again")
  } else if !heightIsCorrect(canvas: canvasX, pixels: pixelsX) {
    panic("Number of lines does not match the specified height. Fix and try again")
  } else {
      let letterX <- create Picture(canvas: canvasX)
      display(canvas: letterX.canvas)
      destroy letterX  
    }

}
 