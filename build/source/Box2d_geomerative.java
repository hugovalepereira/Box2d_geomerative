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

AnatomicPart ap;



Box2DProcessing box2d;

public void setup(){

  
  

  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,-1);




  //letter= new Letter();
  RShape i = RG.loadShape("p.svg");

  i.centerIn(g,40);

  translate(width/2,height/2);
  //i.draw();
  //ap = new AnatomicPart( i.children[0] );
  fill(0);
  i.children[0].draw();

  RMesh m = i.children[0].toMesh();
  int count =0;
  for(RPoint rp: m.getPoints()){
    // fill(random(255),random(255),random(255));
    // text(count++,rp.x+random(20),rp.y);
    // noStroke();
    // ellipse(rp.x,rp.y,5,5);
    //println(rp.x,rp.y);

  }
  RPoint rp= i.children[0].getCentroid();
  ellipse(rp.x,rp.y,5,5);



  divide(i.children[0]);
}



public void draw(){
  //background(100);
          //box2d.step();



          //ap.display();



  //println(frameRate);




}
class AnatomicPart {

  float x, y;

  RShape partShp;
  ArrayList<RShape> subShps;

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

    this.subShps=getSubShapes(partShp);

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(0, 0));
    body = box2d.createBody(bd);





    int count = 0;
    for(RShape rs : this.subShps){

      println("a subforma "+ count++ +" tem "+rs.getPoints().length+ " pontos");

      PolygonShape sd = new PolygonShape();
      RPoint [] points = rs.getPoints();

      Vec2 [] vertices = new Vec2[points.length];

      fill(random(255),random(255),0);
      beginShape();
      for( int i = 0 ; i < vertices.length; i++){


        vertices[i] = box2d.vectorPixelsToWorld(new Vec2( points[i].x , points[i].y ) );
        vertex(vertices[i].x*20.0f+100,vertices[i].y*20.0f+100);
      }
      endShape();
      println(vertices);

      //sd.set(vertices, vertices.length);



      //body.createFixture(sd, 1.0);
    }







  }


  public void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a= body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(255);
    //partShp.draw();

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



  private ArrayList<RShape> getSubShapes(RShape shp){
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




}



public RShape [] divide(RShape shp){
  RMesh mesh = shp.toMesh();
  RPoint [] meshPoints= mesh.getPoints();

  int middlePoint = PApplet.parseInt(meshPoints.length/2)-1;
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
  return null;

}
class Letter {


  ArrayList<AnatomicPart> parts;

  RShape shp;
  RShape [] shpParts;

  Letter() {
    parts= new ArrayList<AnatomicPart>();
    RG.setPolygonizer(RG.ADAPTATIVE);
    shp= RG.loadShape("i.svg");

    shp.centerIn(g,100);

    shpParts = shp.children;

    for(RShape ap: shpParts){
      parts.add(new AnatomicPart(ap));

    }

  }

  public void display(){
    pushMatrix();
    translate(width*0.5f,height *0.5f);
    //shp.draw();
    for(AnatomicPart ap : parts){
      ap.display();
    }

    popMatrix();
  }

}
  public void settings() {  size(600,600);  pixelDensity(2); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Box2d_geomerative" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
