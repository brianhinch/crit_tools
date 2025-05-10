import oscP5.*;
import processing.sound.*;
OscP5 oscP5;
String receivedValue;
import java.util.*;
import java.util.stream.*;

String[] soundFileNames;
SoundFile sample;

boolean ONE_FILE_AT_A_TIME = true;

static float INSTRUCTIONS_Y = 30;
static float INSTRUCTIONS_X = 10;
static float BUTTON_START_Y = 170;
static float BUTTON_HEIGHT = 42;
static float BUTTON_MARGIN = 10;
static float BUTTON_PADDING = 10;
static float TEXT_SIZE = 14;

static String OSC_ADDR = "127.0.0.1";
static int OSC_PORT = 8090;
static String OSC_PATH = "/play";
static String OSC_VALUE_RANDOM = "*";

String SAMPLE_PATH, RANDOM_PATH, INSTRUCTIONS;

void setup() {
  SAMPLE_PATH = dataPath("");
  RANDOM_PATH = dataPath("random");
  INSTRUCTIONS = (
    "Place samples in WAV format in\n" +
    SAMPLE_PATH + "\n" +
    "\n" +
    "Place shufflable samples in\n" +
    RANDOM_PATH + "\n" +
    "\n" +
    "OSC Usage\n" +
    "Send OSC messages to " + OSC_ADDR + " on UDP port " + OSC_PORT + "\n" +
    "from this list:"
  );
  refreshFileList();
  size(450, 450); // (int)(200 + soundFileNames.length * BUTTON_HEIGHT + 100));
  // Initialize oscP5
  oscP5 = new OscP5(this, 8090); // Listen on port 8090
  println("OSC server started on port 8090");
  textSize(TEXT_SIZE);
}

void draw() {
  background(0);
  // Instructions
  fill(#FFFFFF);
  text(INSTRUCTIONS, INSTRUCTIONS_X, INSTRUCTIONS_Y);
  refreshFileList();
  for (int i = 0; i < soundFileNames.length; i++) {
    drawButton(i, getFileBaseName(soundFileNames[i]));
  }
  drawButton(soundFileNames.length, OSC_VALUE_RANDOM);
  fill(#FFFFFF);
  text(OSC_VALUE_RANDOM + " plays one shufflable sample", BUTTON_MARGIN + BUTTON_MARGIN, height - BUTTON_MARGIN);
}

String getFileBaseName(String fileName) {
  if (fileName.indexOf(".") > 0) {
    return fileName.substring(0, fileName.lastIndexOf("."));
  } else {
    return fileName;
  }
}

void refreshFileList() {
  java.io.File folder = new java.io.File(SAMPLE_PATH);

  // list the files in the data folder
  String[] newSoundFileNames = Arrays.stream(folder.list()).filter(filename -> filename.endsWith(".wav")).toArray(String[]::new);

  soundFileNames = newSoundFileNames;
}

class SoundMenuButtonBox {
  float x;
  float y;
  float h;
  float w;
  float b;
  float r;

  SoundMenuButtonBox(int i) {
    x = BUTTON_MARGIN;
    y = BUTTON_START_Y + BUTTON_MARGIN + (i * (BUTTON_HEIGHT + BUTTON_MARGIN));
    w = width - (BUTTON_MARGIN * 2);
    h = BUTTON_HEIGHT;
    r = x + w;
    b = y + h;
  }
}

void drawButton(int i, String label) {
  SoundMenuButtonBox box = new SoundMenuButtonBox(i);
  if (mouseX >= box.x && mouseX <= box.r && mouseY >= box.y && mouseY <= box.b) {
    fill(#cccccc);
  } else {
    fill(#FFFFFF);
  }
  rect(box.x, box.y, box.w, box.h);
  fill(#000000);
  text(OSC_PATH + " " + label, box.x + BUTTON_PADDING, box.y + BUTTON_PADDING + TEXT_SIZE);
}


void mouseClicked() {
  for (int i = 0; i <= soundFileNames.length; i++) {
    SoundMenuButtonBox box = new SoundMenuButtonBox(i);
    if (mouseX >= box.x && mouseX <= box.r && mouseY >= box.y && mouseY <= box.b) {
      if (i < soundFileNames.length) {
        playSound(soundFileNames[i]);
      } else if (i == soundFileNames.length) {
        playRandomSound();
      }
    }
  }
}


// This function will be automatically called by oscP5
// whenever an OSC message is received with the address pattern /test
void oscEvent(OscMessage theOscMessage) {
  println(theOscMessage);
  // Check if the message is for the desired address pattern
  if (theOscMessage.checkAddrPattern(OSC_PATH)) {
    receivedValue = theOscMessage.get(0).stringValue();
    println("Received OSC message: " + theOscMessage.addrPattern() + " " + theOscMessage.typetag() + " " + receivedValue);
    if (receivedValue.equals(OSC_VALUE_RANDOM)) {
      playRandomSound();
    } else {
      playSound(receivedValue + ".wav");
    }
  }
}

void playRandomSound() {
  java.io.File folder = new java.io.File(RANDOM_PATH);

  // list the files in the data folder
  String[] newSoundFileNames = Arrays.stream(folder.list()).filter(filename -> filename.endsWith(".wav")).toArray(String[]::new);
  int i = Math.min(newSoundFileNames.length - 1, (int)(Math.random() * newSoundFileNames.length));
  println("Playing shufflable sound...");
  playSound("random/"+newSoundFileNames[i]);
}

void playSound(String filename) {
  if (ONE_FILE_AT_A_TIME) {
    try {
      if (sample != null && sample.isPlaying()) sample.pause();
    }
    finally {
    }
  }
  try {
    println("Playing sound "+filename);
    sample = new SoundFile(this, filename);
    sample.play();
  }
  catch (Exception ex) {
    println(ex);
  }
  println("");
}
