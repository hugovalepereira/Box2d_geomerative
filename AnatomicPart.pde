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

    body.createFixture(sd, 1.0);
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
        vertex(vertices[i].x*20.0+100,vertices[i].y*20.0+100);
      }
      endShape();
      println(vertices);

      //sd.set(vertices, vertices.length);



      //body.createFixture(sd, 1.0);
    }







  }


  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a= body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(255);
    //partShp.draw();

    popMatrix();
  }




  void connect(AnatomicPart friend){
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




}



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
