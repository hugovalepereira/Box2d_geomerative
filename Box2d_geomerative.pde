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
Letter letter2;


//AnatomicPart rato;

Box2DProcessing box2d;



int grav = 1; // 1 ou 0; os Joints só funcionam com gravidade
void setup(){

  size(600,600);
  //pixelDensity(2);

  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,0.1*grav);




  letter= new Letter("p.svg",0.4,0.5);
  letter2= new Letter("i.svg",0.65,0.51);
  //RShape u = RG.getEllipse(0,0,20,20);
  //println(u.getCentroid().x,u.getCentroid().y);

  //rato = new AnatomicPart(u);


}



void draw(){
  background(0);
  //translate(width/2,height/2);
  box2d.step();



  letter.display();
  letter2.display();
  //rato.follow();
  //rato.display();


  //println(frameRate);




}





void keyPressed(){
  if(key=='r'|| key =='R'){
    letter.reconnect();
    letter2.reconnect();
  } else if(key=='s'|| key =='S'){
    letter.shake();
    letter2.shake();
  }
}
