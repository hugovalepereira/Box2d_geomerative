import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import geomerative.*; 
import shiffman.box2d.*; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.joints.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.collision.shapes.Shape; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.*; 
import org.jbox2d.dynamics.contacts.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Box2d_geomerative extends PApplet {















Letter letter;





Box2DProcessing box2d;

public void setup(){
  
  
  
  
  RG.init(this);
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,0);
  
  
  
  
  letter= new Letter();

  
  
}



public void draw(){
  //background(100);
  box2d.step();
  
  
  
  letter.display();

  
  
  //println(frameRate);
  
}
class AnatomicPart {

  float x, y;
  float w, h ;

  Body body;

  AnatomicPart(float x, float y) {
    this.x=x;
    this.y=y;
    
    PolygonShape sd = new PolygonShape();

    Vec2[] vertices = new Vec2[4];
    vertices[0] = box2d.vectorPixelsToWorld(new Vec2(-15, 25));
    vertices[1] = box2d.vectorPixelsToWorld(new Vec2(15, 0));
    vertices[2] = box2d.vectorPixelsToWorld(new Vec2(20, -15));
    vertices[3] = box2d.vectorPixelsToWorld(new Vec2(-10, -10));

    sd.set(vertices, vertices.length);
    
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    body = box2d.createBody(bd);

    body.createFixture(sd, 1.0f);

    
    
  }


  public void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body); 
    float a= body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    noStroke();
    fill(200);
    rectMode(CENTER);
    rect(0, 0, w, h);
    popMatrix();
  }
  
  
  
  
  public void connect(AnatomicPart friend){
    DistanceJointDef djd = new DistanceJointDef();
    djd.bodyA = this.body;
    djd.bodyB = friend.body;
    djd.localAnchorA.set(random(width),random(height));
    djd.localAnchorB.set(random(width),random(height));
    //djd.initialize(this.body,friend.body,box2d.coordPixelsToWorld(points.get(0)),box2d.coordPixelsToWorld(points.get(1)));
    djd.length = box2d.scalarPixelsToWorld(0);
    println(djd);
    djd.collideConnected=true;
    
  
    //djd.frequencyHz = 4.0;
    //djd.dampingRatio = 0.5;
    
    DistanceJoint dj = (DistanceJoint) box2d.world.createJoint(djd);
  }
}
class Letter {


  ArrayList<AnatomicPart> parts;
  RPolygon shp;

  Letter() {
    parts= new ArrayList<AnatomicPart>();
    shp= new RPolygon();


    shp.addPoint(20,20);
    shp.addPoint(40,20);
    shp.addPoint(20,50);
    shp.addClose();

    for(RPoint rp :shp.getPoints()){
      fill(200,0,0);
      ellipse(rp.x,rp.y,3,3);

    }

  }

  public void display(){
    translate(68,89);
    noStroke();
    RPolygon [] s= new RPolygon[1];
    s[0] = shp.intersection(RPolygon.createRectangle(0,0,50,100));
    s[1] = shp.intersection(RPolygon.createRectangle(0,-100,50,100));
    s[2] = shp.intersection(RPolygon.createRectangle(-50,-100,50,100));
  //  s[3] = RG.intersection(shp, RShape.createRectangle(-50,0,50,100));
    s[3]= shp.intersection(RPolygon.createRectangle(-50,0,50,100));
    for(RPolygon sh : s){
      fill(random(255));
      noStroke();
      shp.draw();
      sh.draw();
      //println(sh.getPoints().length);

    }


  }
}
  public void settings() {  size(600,300);  pixelDensity(2); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Box2d_geomerative" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
