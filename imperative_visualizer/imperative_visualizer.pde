//Painting Music 
// By Kish Parikh, Claire Brandenberger, Alexander Williams 


// Under GNU v3.0 License
// Made by Estlin (Kassian Houben) for his 5 track EP "Imperative"
// https://www.generativehut.com/post/using-processing-for-music-visualization
// Find it on all major platforms

//Importing Control P5 Library
import controlP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import com.hamoid.*;

VideoExport videoExport;

// Configuration variables
// ------------------------
//Choose Song - uncomment the one you want

String audioFileName = "05 Eventually.mp3";
//String audioFileName = "01 The Roman Call.mp3";
//String audioFileName = "01 Wild Youngster.mp3";
//String audioFileName = "1-01 Weak Hearts.mp3";// Audio file in data folder



int canvasWidth = 1200;
int canvasHeight = 600;



float fps = 30;
float smoothingFactor = 0.25; // FFT audio analysis smoothing factor
// ------------------------

// Global variables - shit you can change these

// Export variables
String SEP = "|";
float frameDuration = 1 / fps;
BufferedReader audioReader;
String[] fftFile;
String songName;



// Real time variables
AudioPlayer track;
FFT fft;
Minim minim;  

// General- do not change these 
int bands =  450; // must be multiple of two
float[] spectrum = new float[bands];
float[] sum = new float[bands];
float bgOpacity = 0.5;



// Graphics
float unit;
int groundLineY;
PVector center;


void settings() {
  size(canvasWidth, canvasHeight);
  smooth(8);
}
 // loads and plays saved track
void loadTrack (String audioFileName, int rate) {

  track = minim.loadFile(audioFileName, rate);
  track.pause();
  track.loop();
  
  fft = new FFT( track.bufferSize(), track.sampleRate() );
  fft.linAverages(bands);
}
void setup() {
  background(0);
 
  hint(ENABLE_STROKE_PURE);
  
  frameRate(fps);
  unit = height / 300; // Everything else can be based around unit to make it change depending on size - higher divisor is smaller
  strokeWeight(unit / 50.24);// change # to adjust brush intensity - higher divisor is less intense
  groundLineY = height;
 
  
 
  minim = new Minim(this);
  loadTrack(audioFileName, 2048);
  
  center = new PVector(width / 2, height /4);
}


void draw() {
  
  center = new PVector(mouseX, mouseY);
  groundLineY = mouseY+400; // this keeps brush on the mouse  
  

    fft.forward( track.mix );
    
    spectrum = new float[bands];
    
    for(int i = 0; i < fft.avgSize(); i++)
    {
      spectrum[i] = fft.getAvg(i) / 2 + fft.getAvg(i) / 2; // Average of left right and add to spectrum
          
      // Smooth the FFT spectrum data by smoothing factor
      sum[i] += (abs(spectrum[i]) - sum[i]) * smoothingFactor;
    }
    
    // Reset canvas
    fill(10,10,10,bgOpacity);
    noStroke();
    rect(0, 0, width, height);
    noFill();
    
    drawAll(sum);
  }



// Get the Y position at position X
float getGroundY(float groundX) {

  float angle = 1.1 * groundX / unit * 10.24;
  float groundY = sin(radians(angle + frameCount * 2)) * unit * 1.25 + groundLineY - unit * .25;
  return groundY;
}


// Does circle contain point
boolean circleContains(PVector position, PVector center, float radius) {
  // If distance between center and point is less than radius, then circle contains
  if (dist(position.x, position.y, center.x, center.y) < radius) {
    return true;
  }
  return false;
}


void keyPressed() {
  if (key == 'q') {// pauses music and painting
    
    track.pause();
    noLoop();
    
  } else if (key == 'p') {//resumes music and painting
    
    track.loop();
    loop();
  } else if (key == 's') {//captures image on canvas and saves as png 
    saveFrame("visualizer-#####.png");}
  
}

//Adjust Background opacity based of mouse scroll - functions as eraser
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {
    if (bgOpacity < 50) {
      bgOpacity+=10;
    }
    
  } else {
    if (bgOpacity > 10) {
      bgOpacity-=10;
    }
  }
  println(bgOpacity);
}
