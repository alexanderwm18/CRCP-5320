int sphereRadius;

float spherePrevX;
float spherePrevY;

int yOffset;

boolean initialStatic = true;
float[] extendingSphereLinesRadius;


// Draw static parts - prevents re-calculation - faster real time render
void drawStatic() {
  
  if (initialStatic) {
    extendingSphereLinesRadius = new float[361];
    
    for (int angle = 0; angle <= 360; angle += 4) {
      extendingSphereLinesRadius[angle] = map(random(1), 0, 1, sphereRadius, sphereRadius * 14);
    }
    
    initialStatic = false;
  }

  // More extending lines
  for (int angle = 0; angle <= 360; angle += 4) {
  
    float x = round(cos(radians(angle + 150)) * sphereRadius + center.x);
    float y = round(sin(radians(angle + 150)) * sphereRadius);
    
    float xDestination = x;
    float yDestination = y;

    // Draw lines in small increments to make it easier to work with 
    for (int i = sphereRadius; i <= extendingSphereLinesRadius[angle]; i++) {
      float x2 = cos(radians(angle + 150)) * i + center.x;
      float y2 = sin(radians(angle + 150)) * i;
      
      if (y2 <= getGroundY(x2)) { // Make sure it doesnt go into ground
        xDestination = x2;
        yDestination = y2;
      }
    }
    
    if (y <= getGroundY(x)) {
      line(x, y, xDestination, yDestination);
}
  }
}


// Draws everything
void drawAll(float[] sum) {
  // Center sphere
  sphereRadius = 20 * round(unit);

  spherePrevX = 0;
  spherePrevY = 0;

 // yOffset = round(sin(radians(120)) * sphereRadius);
  yOffset =404;
  drawStatic();
  
  // Lines surrounding
  float x = 0;
  float y = 0;
  int surrCount = 1;
  
  boolean direction = false;
  
  while (x < width * 1.5 && x > 0 - width / 2) {

    float surroundingRadius;
    
    float surrRadMin = sphereRadius + sphereRadius * 1/2 * surrCount;
    float surrRadMax = surrRadMin + surrRadMin * 1/8;

    float surrYOffset;
    
    float addon = frameCount * 1.5;
    
    if (direction) {
      addon = addon * 1.5;
    }

    for (float angle = 0; angle <= 360; angle += 1.5) {
      
      surroundingRadius = map(sin(radians(angle * 7 + addon)), -1, 1, surrRadMin, surrRadMax); // Faster rotation through angles, radius oscillates
      
      surrYOffset = sin(radians(150)) * surroundingRadius;

      x = round(cos(radians(angle + 150)) * surroundingRadius + center.x);
      y = round(sin(radians(angle + 150)) * surroundingRadius+200);

      noStroke();
      //thise changes the color of the audio surrounding - !CALCULATE COLOR VALUES!
      fill(map(mouseX, surrRadMin, surrRadMax, 10, 40),map(mouseY, surrRadMin, surrRadMax, 120, 180),map(mouseX, surrRadMin, surrRadMax, 205, 130));
      circle(x, y, 3 * unit / 10.24);
      noFill();
    }

    direction = !direction;
    
    surrCount += 1;
  }

  // Lines extending from sphere
  float extendingLinesMin = sphereRadius * 0.8;
  float extendingLinesMax = sphereRadius * 2.0; 
  
  float xDestination;
  float yDestination;
  
  for (int angle = 0; angle <= 360; angle++) {

    float extendingSphereLinesRadius = map(noise(angle * 0.3), 0, 1, extendingLinesMin, extendingLinesMax);
        
    // Radius are mapped differently for highs, mids, and lows - brave souls can adjust brush appearance here
    if (sum[0] != 0) {
      if (angle >= 0 && angle <= 60) {
        extendingSphereLinesRadius = map(sum[200 - round(map((angle), 0, 60, 0, 80))], 0, 0.8, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Highs
      }
      
      else if (angle > 60 && angle <= 120) {
                extendingSphereLinesRadius = map(sum[120 - round(map((angle - 60), 0, 120, 65, 80))], 0, 40, extendingSphereLinesRadius - extendingSphereLinesRadius /8, extendingLinesMax * 3.0); // Bass
       
      }
      
      else if (angle > 120 && angle <= 180) {
         extendingSphereLinesRadius = map(sum[200 - round(map((angle - 120), 0, 60, 0, 80))], 0, 0.8, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Highs

      }
      
      else if (angle > 180 && angle <= 240) {
         extendingSphereLinesRadius = map(sum[200 + round(map((angle - 180), 0, 60, 0, 80))], 0, 3, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Mids
       
      }
      
      else if (angle > 240 && angle <= 300) {
         extendingSphereLinesRadius = map(sum[120 - round(map((angle - 210), 0, 120, 65, 80))], 0, 40, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 3.0); // Bass
     
      }
      
      else if (angle > 300 && angle <=360) {
           extendingSphereLinesRadius = map(sum[200 + round(map((angle - 180), 0, 60, 0, 80))], 0, 3, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Mids
      }
    }
    
    x = round(cos(radians(angle)) * sphereRadius + center.x);
    y = round(sin(radians(angle)) * sphereRadius + groundLineY - yOffset);

    xDestination = x;
    yDestination = y;

    for (int i = sphereRadius; i <= extendingSphereLinesRadius; i++) {
      int x2 = round(cos(radians(angle)) * i + center.x);
      int y2 = round(sin(radians(angle)) * i + groundLineY - yOffset);
      
      if (y2 <= getGroundY(x2)) { // Make sure it doesnt go into ground
        xDestination = x2;
        yDestination = y2;
      }
    }
    
    //thise changes the color of the audio reactive brush - !CALCULATE COLOR VALUES!
    stroke(map(mouseX, extendingLinesMin, extendingLinesMax, 0, 42), map(mouseY, extendingLinesMin, extendingLinesMax, 120, 220), map(mouseX, extendingLinesMin, extendingLinesMax, 200, 180));
    
    if (y <= getGroundY(x))  {
      line(x, y, xDestination, yDestination);
    }
  }

}
