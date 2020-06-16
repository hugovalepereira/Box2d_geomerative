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

    body.createFixture(sd, 1.0);
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


  void display() {
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

  void connect(AnatomicPart friend){
    DistanceJointDef djd = new DistanceJointDef();
    djd.bodyA = this.body;
    djd.bodyB = friend.body;
    //djd.localAnchorA.set(random(width),random(height));
    //djd.localAnchorB.set(random(width),random(height));

    RPoint joint1 = this.joinningPoints.get( int( random( this.joinningPoints.size() ) ) );
    println("abc");
    println(joint1.x+300,joint1.y+300);
    RPoint joint2 = friend.joinningPoints.get( int( random( friend.joinningPoints.size() ) ) );
    djd.initialize(this.body,friend.body,box2d.coordPixelsToWorld(joint1.x+300,joint1.y+300), box2d.coordPixelsToWorld(joint2.x+300,joint2.y+300));
    djd.length = box2d.scalarPixelsToWorld(0);

    djd.collideConnected=false;


    //djd.frequencyHz = 4.0;
    //djd.dampingRatio = 0.5;

    DistanceJoint dj = (DistanceJoint) box2d.world.createJoint(djd);

  }


  void shake(){
    body.setTransform(box2d.coordPixelsToWorld(random(300,width-300),random(300,height-300)),int(random(8))*TAU/8);
  }

  void follow(){
    body.setTransform(box2d.coordPixelsToWorld(new Vec2 (mouseX,mouseY)),int(random(8))*TAU/8);

    //println(mouseX,mouseY);
    Vec2 v = box2d.coordPixelsToWorld(new Vec2 (mouseX,mouseY));
    //println(v.x,v.y);
  }


  private ArrayList<RShape> getSubShapes(RShape shp){ // função recurssiva para dividir a forma em formas mais pequenas para serem tratadas pela BOX2D
    ArrayList<RShape> result = new ArrayList<RShape>();

    if(shp.getPoints().length > 5){
      RShape [] splitShp = RG.split(shp,0.3);

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


  String toString(){
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
