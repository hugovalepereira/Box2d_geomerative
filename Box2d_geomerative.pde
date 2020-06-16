import geomerative.*;




import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

Letter letter;

AnatomicPart ap;



Box2DProcessing box2d;

void setup(){

  size(600,600);
  pixelDensity(2);

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



void draw(){
  //background(100);
          //box2d.step();



          //ap.display();



  //println(frameRate);




}
