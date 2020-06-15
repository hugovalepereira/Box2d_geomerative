class AnatomicPart {

  float x, y;
  float w, h ;

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


  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body); 
    float a= body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    noStroke();
    fill(200);
    rectMode(CENTER);
    rect(0, 0, w, h);
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
}
