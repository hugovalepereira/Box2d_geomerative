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



AnatomicPart rato;

Box2DProcessing box2d;

public void setup(){

  
  //pixelDensity(2);

  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,0);




  letter= new Letter();

  RShape u = RG.getEllipse(0,0,20,20);

  rato = new AnatomicPart(u);


}



public void draw(){
  background(0);
  //translate(width/2,height/2);
  box2d.step();



  letter.display();
  rato.follow();
  rato.display();


  //println(frameRate);




}


public void mousePressed(){
  letter.shake();
}


public void keyPressed(){
  letter.reconnect();

}
class AnatomicPart {

  float x, y;

  RShape partShp;
  RPoint [] box;


  ArrayList<RPoint> joinningPoints;

  RPoint [] handles;

  RPoint [][] handlesByPath;

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

  AnatomicPart(RShape partShp) {
    this.partShp=partShp;

    handles = this.partShp.getHandles();

    RCommand [] r;

    if(this.partShp.paths.length==1){
      r = this.partShp.paths[0].commands;
    } else {
      r=null;
      println("ERRO!!! Esta forma tem mais que um Path");
    }

    handlesByPath= new RPoint[r.length][];

    for(int i = 0 ; i< r.length; i++){
      handlesByPath[i] = r[i].getHandles();

    }

    this.box = partShp.getBoundsPoints();
    this.joinningPoints = new ArrayList<RPoint>();

    loadJoinningPoints();

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld( width/2 , height/2));
    body = box2d.createBody(bd);



    PolygonShape sd = new PolygonShape();




    Vec2[] vertices = new Vec2[4];


    for( int i = 0 ; i < vertices.length; i++){


      vertices[i] = box2d.coordPixelsToWorld(this.box[i].x ,this.box[i].y );
      //vertices[i] = box2d.coordPixelsToWorld(this.box[i].x - this.partShp.getCentroid().x,this.box[i].y - this.partShp.getCentroid().y);


    }


    sd.set(vertices, vertices.length);


    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0;
    fd.restitution = 0;
    fd.filter.groupIndex = -2; // coloca todas as partes anatómicas na mesma "camada". E, por ser negativa, não colidem umas com as outras
    body.createFixture(fd);








  }


  public void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a= body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);

    //displayLeading();
    fill(255);
    noStroke();
    partShp.draw();

    //displayHandles();
    //displayJoinningPoints();
    popMatrix();
  }


  private void displayHandles(){
    for(RPoint p : handles){
      fill(100);
      ellipse(p.x,p.y,3,3);
    }
  }

  private void displayJoinningPoints(){
    for(RPoint p : joinningPoints){
      ellipse(p.x,p.y,5,5);
    }
  }


  private void loadJoinningPoints(){
    for(RPoint path [] : handlesByPath){
      joinningPoints.add(path[0]); // só funciona se as formas forem sempre fechadas
      // path[path.length-1] //se não é preciso ir buscar o último ponto tb
    }
  }


  private void displayLeading(){
    noStroke();
    fill(255,100);
    beginShape();
    for(RPoint p : box){
      vertex(p.x,p.y);
    }
    endShape();

  }

  public void connect(AnatomicPart friend){
    DistanceJointDef djd = new DistanceJointDef();
    djd.bodyA = this.body;
    djd.bodyB = friend.body;
    //djd.localAnchorA.set(random(width),random(height));
    //djd.localAnchorB.set(random(width),random(height));

    RPoint joint1 = this.joinningPoints.get( PApplet.parseInt( random( this.joinningPoints.size() ) ) );
    println("abc");
    println(joint1.x+300,joint1.y+300);
    RPoint joint2 = friend.joinningPoints.get( PApplet.parseInt( random( friend.joinningPoints.size() ) ) );
    djd.initialize(this.body,friend.body,box2d.coordPixelsToWorld(joint1.x+300,joint1.y+300), box2d.coordPixelsToWorld(joint2.x+300,joint2.y+300));
    djd.length = box2d.scalarPixelsToWorld(0);

    djd.collideConnected=false;


    //djd.frequencyHz = 4.0;
    //djd.dampingRatio = 0.5;

    DistanceJoint dj = (DistanceJoint) box2d.world.createJoint(djd);

  }


  public void shake(){
    body.setTransform(box2d.coordPixelsToWorld(random(300,width-300),random(300,height-300)),PApplet.parseInt(random(8))*TAU/8);
  }

  public void follow(){
    body.setTransform(box2d.coordPixelsToWorld(new Vec2 (mouseX,mouseY)),PApplet.parseInt(random(8))*TAU/8);

    //println(mouseX,mouseY);
    Vec2 v = box2d.coordPixelsToWorld(new Vec2 (mouseX,mouseY));
    //println(v.x,v.y);
  }


  private ArrayList<RShape> getSubShapes(RShape shp){ // função recurssiva para dividir a forma em formas mais pequenas para serem tratadas pela BOX2D
    ArrayList<RShape> result = new ArrayList<RShape>();

    if(shp.getPoints().length > 5){
      RShape [] splitShp = RG.split(shp,0.3f);

      ArrayList<RShape> subTrim1= getSubShapes( splitShp[0] );
      for(RShape s : subTrim1){
        result.add(s);
      }

      ArrayList<RShape> subTrim2= getSubShapes( splitShp[1] );
      for(RShape s : subTrim2){
        result.add(s);
      }

    } else{
      result.add(shp);

    }

    return result;
  }


  public String toString(){
    return box2d.getBodyPixelCoord(body).x +" "+ box2d.getBodyPixelCoord(body).y;


  }

}


/*
RShape [] divide(RShape shp){
  RMesh mesh = shp.toMesh();
  RPoint [] meshPoints= mesh.getPoints();

  int middlePoint = int(meshPoints.length/2)-1;
  RPoint [] subPoints1 = (RPoint[])subset(meshPoints,0,middlePoint+2);
  RPoint [] subPoints2 = (RPoint[])subset(meshPoints,middlePoint);

  RMesh new1 = new RMesh();

  for(RPoint p : subPoints1){
    new1.addPoint(p);

    //print(p.x,p.y);
    fill(255,0,0);
    noStroke();
    ellipse(p.x,p.y,5,5);
  }
  //println();

  RMesh new2 = new RMesh();

  for(RPoint p : subPoints2){
    new2.addPoint(p);
    //print(p.x,p.y);
    fill(255,255,0);
    noStroke();
    ellipse(p.x,p.y,5,5);
  }

  fill(255,0,0);



  new1.draw();
  fill(255,255,0);
  new2.draw();
  return null;    // esta função utiliza a RMesh para dividir a forma na zona central

}
*/
class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w;
  float h;

  // But we also have to make a body for box2d to know about it
  Body b;

  Boundary(float x_,float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;

    // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.KINEMATIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);

    // Attached the shape to the body using a Fixture
    b.createFixture(sd,1);
  }

  // Draw the boundary, if it were at an angle we'd have to do something fancier
  public void display() {
    fill(0);
    stroke(0);
    rectMode(CENTER);
    rect(x,y,w,h);
  }

}
class Letter {


  ArrayList<AnatomicPart> parts;

  RShape shp;
  RShape [] shpParts;

  Letter() {
    parts= new ArrayList<AnatomicPart>();
    RG.setPolygonizer(RG.ADAPTATIVE);
    shp= RG.loadShape("p.svg");

    shp.centerIn(g,200);

    shpParts = shp.children;

    for(RShape ap: shpParts){
      parts.add(new AnatomicPart(ap));

    }

  }

  public void display(){

    //translate(width*0.5,height *0.5);
    //shp.draw();
    for(AnatomicPart ap : parts){
      ap.display();

    }


  }


  public void shake(){
    for(AnatomicPart ap : parts){
      ap.shake();
      println(ap);
    }

  }


  public void reconnect(){
    for(AnatomicPart ap : parts){
      if(random(1)<0.4f){
        AnatomicPart fr= parts.get(PApplet.parseInt(random(parts.size())));
        if(fr!=ap) {
          ap.connect(fr);

        }
      }
    }
  }


}
  public void settings() {  size(600,600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Box2d_geomerative" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
