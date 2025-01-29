import java.util.Arrays;


int cols, rows;
float w, h;
boolean[][] startCells, cells;
boolean update = false;
boolean wrapAround;

boolean help = true;
boolean hide = false;
boolean grid = true;

float textSize = width * 1/5;

int fps = 30;


void setup() {
  fullScreen();
  frameRate(fps);noSmooth();
  wrapAround = true;  // 'wrapAround = false' breaks some stuff
  cols = width / 10;
  rows = height / 10;
  w = (float) width / cols;
  h = (float) height / rows;
  cells = new boolean[rows][cols];
  startCells = new boolean[rows][cols];
}


void draw() {
  background(0);

  if (mousePressed) {
    int x = (int) (mouseX / w);
    int y = (int) (mouseY / h);

    switch (mouseButton) {
      case LEFT:
        if (!update) startCells[y][x] = true;
        cells[y][x] = true;
        break;

      case RIGHT:
        if (!update) startCells[y][x] = false;
        cells[y][x] = false;
        break;

      case CENTER:
        break;

      default:
    }
  }

  if (grid) stroke(0);
  else noStroke();

  fill(255);
  boolean[][] newCells = new boolean[rows][cols];

  for (int j = 0; j < rows; j++) {
    boolean[] row = cells[j];
    newCells[j] = Arrays.copyOf(row, row.length);

    for (int i = 0; i < cols; i++) {
      boolean cell = cells[j][i];

      if (update) {
        int neighbors = liveNeighbors(i, j);

        if (cell) {
          if (neighbors != 2 && neighbors != 3) {
            newCells[j][i] = false;
          }
        } else if (neighbors == 3) {
          newCells[j][i] = true;
        }
      }

      if (cell) rect(i * w, j * h, w, h);
    }
  }

  if (!hide) {
    String txt;

    txt = help
      ? "(max possible) FPS: " + fps + "\n\n" +
        "H... Hide Tips\n" +
        "E... Hide Every Text\n" +
        "\n" +
        "Left Mouse Button... Liven Cell\n" +
        "Right Mouse Button... Kill Cell\n" +
        "Mousewheel Up... Increase FPS\n" +
        "Mousewheel Down... Decrease FPS\n" +
        "\n" +
        "G... Hide Gridlines\n" +
        "C... Clear Everything\n" +
        "R... Reset To Beginning\n" +
        "SPACE... Pause/Unpause\n" +
        "ENTER... Reset + Pause/Unpause"
      : Integer.toString(fps);

    fill(127);
    textSize(textSize);
    text(txt, 0, textSize);

    if (!update) {
      textSize(textSize * 10);
      text("II", width * 9/10, textSize * 10);
    }
  }

  if (update) {
    cells = newCells;
    frameRate(fps);
  } else {
    frameRate(360);
  }
}


int liveNeighbors(int col, int row) {
  int n = 0;

  for (byte j = -1; j <= 1; j++) {
    for (byte i = -1; i <= 1; i++) {
      if (i != 0 || j != 0) {
        int x = col + i;
        int y = row + j;

        if ((x >= 0 && x < cols && y >= 0 && y < rows && cells[y][x]) ||
          (wrapAround && cells[posMod(y, rows)][posMod(x, cols))) {
          n++;
        }
      }
    }
  }

  return n;
}


// So that negative numbers wrap around as well!
int posMod(int a, int b) {
  return ((a % b) + b) % b;
}


void keyPressed() {
  switch (key) {
    case 'r':

    case ENTER:
      cells = startCells;
      if (key != ENTER) break;

    case ' ':
      update ^= true;
      break;

    case 'c':
      cells = new boolean[rows][cols];
      startCells = new boolean[rows][cols];
      break;

    case 'h':
      help ^= true;
      break;

    case 'e':
      hide ^= true;
      break;

    case 'g':
      grid ^= true;
      break;

    default:
  }
}


void mouseWheel(MouseEvent event) {
  int newFps = fps - event.getCount();
  fps = (newFps > 0) ? newFps : 1;
}
