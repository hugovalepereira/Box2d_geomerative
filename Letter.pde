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

  void display(){

    //translate(width*0.5,height *0.5);
    //shp.draw();
    for(AnatomicPart ap : parts){
      ap.display();

    }


  }


  void shake(){
    for(AnatomicPart ap : parts){
      ap.shake();
      println(ap);
    }

  }


  void reconnect(){
    for(AnatomicPart ap : parts){
      if(random(1)<0.4){
        AnatomicPart fr= parts.get(int(random(parts.size())));
        if(fr!=ap) {
          ap.connect(fr);

        }
      }
    }
  }


}
