class AnatomicPart {

  float x, y;

  RShape partShp;
  RPoint [] box;

  ArrayList<RPoint> joinningPoints;

  RPoint [] handles;

  RPoint [][] handlesByPath;

  Body body;


  DistanceJoint dj;

  @Deprecated
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
    //bd.position.set(box2d.coordPixelsToWorld( width/2 - this.partShp.getCentroid().x, height/2- this.partShp.getCentroid().y));
    bd.position.set(box2d.coordPixelsToWorld( this.partShp.getCentroid().x, this.partShp.getCentroid().y)); //Abordagem B

    //bd.position.set(box2d.coordPixelsToWorld(0,0));  //Abordagem A - Funciona com restrições

    body = box2d.createBody(bd);



    PolygonShape sd = new PolygonShape();




    Vec2[] vertices = new Vec2[4];

    println("Vertices:");
    for( int i = 0 ; i < vertices.length; i++){


      Vec2 b = new Vec2(this.box[i].x,this.box[i].y);
      Vec2 corner = b.sub(new Vec2 (this.partShp.getCentroid().x,this.partShp.getCentroid().y));

      vertices[i] = box2d.vectorPixelsToWorld(corner); // Abordagem B - utiliza os pontos em relação ao Centroid
      //vertices[i] = box2d.vectorPixelsToWorld(b); //Abordagem A - utiliza os pontos originais. Com referencial no (0,0)
      println(vertices[i]);
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
    //fill(0,200,20);
    //ellipse(pos.x, pos.y,5,5);
    float a= body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    translate(-this.partShp.getCentroid().x,-this.partShp.getCentroid().y);

    displayLeading(true);
    fill(255);
    noStroke();
    //translate();
    //RG.shape(partShp,this.partShp.getCentroid().x, this.partShp.getCentroid().y);
    RG.shape(partShp,0,0);
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


  private void displayLeading(boolean value){
    if(value){
      noStroke();
      fill(255,100);
      beginShape();
      for(RPoint p : box){
        vertex(p.x,p.y);
      }
      endShape();
    }
  }


  void destroyJoint(){
    if(dj!=null) {
      box2d.world.destroyJoint(dj);
      println("ABC "+dj);
      dj=null;
      //Joint.destroy(dj); /#NOTA - Nenhum destas funções funcionou para desligar a Joint
      //dj.destructor();
    }

  }
  void connect(AnatomicPart friend){

    destroyJoint(); // É desnecessário, apenas coloquei por segurança
    DistanceJointDef djd = new DistanceJointDef();
    djd.bodyA = this.body;
    djd.bodyB = friend.body;
    //djd.localAnchorA.set(random(width),random(height));
    //djd.localAnchorB.set(random(width),random(height));

    RPoint joint1 = this.joinningPoints.get( int( random( this.joinningPoints.size() ) ) );

    RPoint joint2 = friend.joinningPoints.get( int( random( friend.joinningPoints.size() ) ) );

    Vec2 b1 = new Vec2(joint1.x,joint1.y);
    Vec2 b2 = new Vec2(joint2.x,joint2.y);
    println("B1: "+b1);
    println("B2: "+b2);
    Vec2 corner1 = b1.sub(new Vec2 (this.partShp.getCentroid().x,this.partShp.getCentroid().y));
    Vec2 corner2 = b2.sub(new Vec2 (friend.partShp.getCentroid().x,friend.partShp.getCentroid().y));
    println("Corner1: "+corner1);
    println("Corner2: "+corner2);
    Vec2 anc1 = box2d.vectorPixelsToWorld(corner1.x,corner1.y);
    Vec2 anc2 = box2d.vectorPixelsToWorld(corner2.x,corner2.y);

    println("Anc1: "+anc1);
    println("Anc2: "+anc2);
    djd.initialize(this.body,friend.body,this.body.getWorldPoint(anc1), friend.body.getWorldPoint(anc2));


    djd.length = box2d.scalarPixelsToWorld(0);

    djd.collideConnected=false;


    //djd.frequencyHz = 4.0;
    //djd.dampingRatio = 0.5;

    dj = (DistanceJoint) box2d.world.createJoint(djd);

  }


  void shake(){
    body.setTransform(box2d.coordPixelsToWorld(random(200,width-200),random(200,height-200)),int(random(8))*TAU/8);
    //Esta função não funciona porque o centro da rotação não é o centro da peça
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



  void showJoint() {
    if (dj!=null) {

      Vec2 ancA = new Vec2();
      dj.getAnchorA(ancA);
      ancA = box2d.coordWorldToPixels(ancA);

      Vec2 ancB = new Vec2();
      dj.getAnchorB(ancB);
      ancB = box2d.coordWorldToPixels(ancB);

      noStroke();
      fill(200, 200, 0);
      ellipse(ancA.x, ancA.y, 8, 8);
      ellipse(ancB.x, ancB.y, 8, 8);
      stroke(0);
      line(ancA.x, ancA.y,ancB.x, ancB.y);

    }
  }



  String toString(){
    return box2d.getBodyPixelCoord(body).x +" "+ box2d.getBodyPixelCoord(body).y;


  }

}
