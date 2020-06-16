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

  void display(){
    pushMatrix();
    translate(width*0.5,height *0.5);
    //shp.draw();
    for(AnatomicPart ap : parts){
      ap.display();
    }

    popMatrix();
  }

}
