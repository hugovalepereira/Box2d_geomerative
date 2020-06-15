class Letter {


  ArrayList<AnatomicPart> parts;
  RShape shp;

  Letter() {
    parts= new ArrayList<AnatomicPart>();
    shp= new RPolygon();


    shp.addPoint(20,20);
    shp.addPoint(40,20);
    shp.addPoint(20,50);
    shp.addClose();

    for(RPoint rp : shp.getPoints()){
      fill(200,0,0);
      ellipse(rp.x,rp.y,3,3);

    }

  }

  void display(){
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
