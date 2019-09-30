EqTriangle triangle;
Point trackedPoint;
Tracker tracker;

void setup() {
  size(1000, 800, P3D);
  smooth(1);
  background(0);
  
  // NOTE - any triangle could work, not just equilaterals
  triangle = new EqTriangle(600);
  
  trackedPoint = new Point();
  trackedPoint.x = 0;
  trackedPoint.y = 0;
  
  tracker = new Tracker(triangle);
}

void draw() {
  background(0);
  
  float translateX = width / 2;
  float translateY = height - 200;
  
  // move to the center of the screen
  translate(translateX, translateY);
  
  // create an equilateral triangle
  triangle.draw();
  
  trackedPoint.x = mouseX - translateX;
  trackedPoint.y = mouseY - translateY;
  tracker.draw(trackedPoint);

}

class Tracker {
  EqTriangle triangle;
  
  Tracker(EqTriangle t) {
    triangle = t;
  }
  
  void draw(Point p) {
    strokeWeight(2);

    if (distanceBetweenPoints(p, triangle.center) > triangle.incircleRadius) {
      fill(255, 0, 0);
      stroke(255, 0, 0);
    } else {
      fill(0, 255, 0);
      stroke(0, 255, 0);
    }
    
    line(p.x, p.y, triangle.p1.x, triangle.p1.y);
    line(p.x, p.y, triangle.p2.x, triangle.p2.y);
    line(p.x, p.y, triangle.p3.x, triangle.p3.y);
    
    noStroke();
    circle(p.x, p.y, 10);
    
    stroke(255);
    
    Point location = calculateCoordinates(triangle, p);
    
    // to show that the coordinates match
    //println("Calculated location:");
    //printPoint(location);
    
    //println("Mouse cursor:");
    //printPoint(p);

    text("x: " + int(location.x) + " " + "y: " + int(location.y), location.x + 10, location.y);
  }
  
  void printPoint(Point p) {
    print("X coord: ");
    print(p.x);
    println();
    
    print("Y coord: ");
    print(p.y);
    println();
  }
  
  Point calculateCoordinates(EqTriangle triangle, Point p) {
    float r1 = distanceBetweenPoints(triangle.p1, p);
    float r2 = distanceBetweenPoints(triangle.p2, p);
    float r3 = distanceBetweenPoints(triangle.p3, p);
    
    // distance forumula, solving for x and y with distance known
    float a = (-2*triangle.p1.x + 2*triangle.p2.x);
    float b = (-2*triangle.p1.y + 2*triangle.p2.y);
    float c = sq(r1) - sq(r2) - sq(triangle.p1.x) + sq(triangle.p2.x) - sq(triangle.p1.y) + sq(triangle.p2.y);
    
    float d = (-2*triangle.p2.x + 2*triangle.p3.x);
    float e = (-2*triangle.p2.y + 2*triangle.p3.y);
    float f = sq(r2) - sq(r3) - sq(triangle.p2.x) + sq(triangle.p3.x) - sq(triangle.p2.y) + sq(triangle.p3.y);
    
    float x = (c*e - f*b) / (e*a - b*d);
    float y = (c*d - a*f) / (b*d - a*e);
    
    Point location = new Point();
    location.x = x;
    location.y = y;
    
    return location;
  }
  
  float distanceBetweenPoints(Point p1, Point p2) {
    return sqrt(sq(p1.x-p2.x) + sq(p1.y-p2.y));
  }
}

class EqTriangle {
  int length;
  float incircleRadius;
  Point p1, p2, p3;
  Point center;
  
  EqTriangle(int l) {
    length = l;
    incircleRadius = calculateIncircleRadius(l);
    center = calculateCenterPoint(incircleRadius);
    
    p1 = new Point();
    p1.x = -length / 2;
    p1.y = 0;
  
    p2 = new Point();
    p2.x = length / 2;
    p2.y = 0;
  
    p3 = new Point();
    p3.x = 0;
    p3.y = -sqrt(sq(length) - sq(length / 2));
  }
  
  void draw() {
    stroke(255);
    
    line(p1.x, p1.y, p2.x, p2.y);
    line(p2.x, p2.y, p3.x, p3.y);
    line(p3.x, p3.y, p1.x, p1.y);
    
    drawIncircle();
  }
  
  void drawIncircle() {
    noFill();
    circle(center.x, center.y, center.y * 2);
  }
  
  float calculateIncircleRadius(int length) {    
    return (length * sqrt(3)) / 6;
  }
  
  Point calculateCenterPoint(float incircleRadius) {
    Point center = new Point();
    center.x = 0;
    center.y = -incircleRadius;
    
    return center;
  }
}

class Point {
  float x;
  float y;
}
