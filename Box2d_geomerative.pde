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





Box2DProcessing box2d;

void setup(){

  size(600,600);
  pixelDensity(2);

  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,0);
  //box2d.setWarmStarting(true);



  letter= new Letter();




}



void draw(){
  background(0);
  //translate(width/2,height/2);
  box2d.step();



  letter.display();



  //println(frameRate);




}


void mousePressed(){


  letter.shake();
}
